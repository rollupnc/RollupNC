pragma solidity >=0.4.21;

import "./Verifier.sol";
import "./WithdrawSigVerifier.sol";


contract IMiMC {

    function MiMCpe7(uint256,uint256) public pure returns(uint256) {}

}

contract IMiMCMerkle {

    uint[16] public zeroCache;
    function getRootFromProof2(
        uint256,
        uint256[2] memory,
        uint256[2] memory
    ) public view returns(uint) {}
    function hashBalance(uint[5] memory) public view returns(uint){}
    function hashTx(uint[7] memory) public view returns(uint) {}
    function hashWithdraw(uint[2] memory) public view returns(uint){}
    function hashHeight2Tree(uint[4] memory) public view returns(uint){}

}

contract ITokenRegistry {
    address public coordinator;
    uint256 public numTokens;
    mapping(address => bool) public pendingTokens;
    mapping(uint256 => address) public registeredTokens;
    modifier onlyCoordinator(){
        assert (msg.sender == coordinator);
        _;
    }
    function registerToken(address tokenContract) public {}
    function approveToken(address tokenContract) public onlyCoordinator{}
}

contract RollupNC is Verifier, WithdrawSigVerifier {

    IMiMC public mimc;
    IMiMCMerkle public mimcMerkle;
    ITokenRegistry public tokenRegistry;

    uint256 public currentRoot;
    address public coordinator;
    uint256 public depositQueueNumber;
    uint256 public depositProcessedNumber;
    uint256 public maxDepositQueueSize;
    uint256 public updateNumber;

    uint256 public BAL_DEPTH = 4;
    uint256 public TX_DEPTH = 2;

    // (queueNumber => [pubkey_x, pubkey_y, balance, nonce, token_type])
    mapping(uint256 => uint[5]) public pendingDeposits;
    mapping(uint256 => uint256) public deposits; //leaf idx => leafHash
    mapping(uint256 => uint256) public updates; //txRoot => update idx

    event RegisteredToken(uint tokenType, address tokenContract);
    event RequestDeposit(uint amount, uint tokenType, uint[2] pubkey);
    event UpdatedState(uint currentRoot, uint oldRoot, uint txRoot);
    event Withdraw(uint[2] pubkey_from, address recipient, uint txRoot, uint[3] txInfo);

    constructor(
        address _mimcContractAddr,
        address _mimcMerkleContractAddr,
        address _tokenRegistryAddr
    ) public {
        mimc = IMiMC(_mimcContractAddr);
        mimcMerkle = IMiMCMerkle(_mimcMerkleContractAddr);
        tokenRegistry = ITokenRegistry(_tokenRegistryAddr);
        currentRoot = mimcMerkle.zeroCache(BAL_DEPTH);
        coordinator = msg.sender;
        depositQueueNumber = 0;
        depositProcessedNumber = 0;
        maxDepositQueueSize = 4;
        updateNumber = 0;
    }

    modifier onlyCoordinator(){
        assert(msg.sender == coordinator);
        _;
    }

    function updateState(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[3] memory input
        ) public onlyCoordinator {
        require(currentRoot == input[2], "input does not match current root");
        //validate proof
        require(Verifier.verifyProof(a,b,c,input),
        "SNARK proof is invalid");
        // update merkle root
        currentRoot = input[0];
        updateNumber++;
        updates[input[1]] = updateNumber;
        emit UpdatedState(input[0], input[1], input[2]); //newRoot, txRoot, oldRoot
    }

    // user tries to deposit ERC20 tokens
    function deposit(
        uint[2] memory pubkey,
        uint amount,
        uint tokenType
    ) public payable{
        require(
            (amount > 0 && tokenType > 1) ||
            (msg.value > 0 && tokenType == 1) ||
            msg.sender == coordinator,
            "Deposit must be greater than 0.");
        require(
            tokenType == 0 ||
            tokenType == 1 ||
            tokenRegistry.registeredTokens(tokenType) != address(0),
            "tokenType is not registered.");
        if (tokenType == 1){
            pendingDeposits[depositQueueNumber] = [
                pubkey[0], pubkey[1], amount, 0, 1
            ];
            depositQueueNumber++;
            emit RequestDeposit(msg.value, 1, pubkey);
        } else {
            pendingDeposits[depositQueueNumber] = [
                pubkey[0], pubkey[1], amount, 0, tokenType
            ];
            depositQueueNumber++;
            emit RequestDeposit(amount, tokenType, pubkey);
        }

    }

/*

// TODO: include Stuart's deposit fn
    bytes32[] public currentDeposits;
    uint[] public pendingDeposits;
    uint public cdLength = 0;

     function deposit(uint pk1) public {
        pendingDeposits.push(pk1);
        if(pendingDeposits.length % 2 == 0){
            bytes32 cd = keccak256(abi.encodePacked(pendingDeposits[0], pendingDeposits[1]));
            delete pendingDeposits;
            currentDeposits.push(cd);
            cdLength ++;
            uint tempLength = cdLength;
            while(tempLength % 2 == 0 && cdLength != 0){
                currentDeposits[currentDeposits.length - 2] = keccak256(abi.encodePacked(currentDeposits[currentDeposits.length - 1], currentDeposits[currentDeposits.length -2]));
                currentDeposits.length --;
                tempLength = tempLength / 2;
            }
        }
    }
*/

    // coordinator adds certain number of deposits to balance tree
    // coordinator must specify subtree index in the tree since the deposits
    // are being inserted at a nonzero height
    function processDeposits(
        uint[2] memory subtreePosition,
        uint[2] memory subtreeProof
    ) public onlyCoordinator returns(uint256){
        uint[4] memory array; //process 4 deposits at a time
        for (uint i = 0; i < maxDepositQueueSize; i++){
            uint leafHash = mimcMerkle.hashBalance(
                pendingDeposits[depositProcessedNumber + i]
            );
            array[i] = leafHash;
        }
        uint subtreeRoot = mimcMerkle.hashHeight2Tree(array);
        uint emptySubtreeRoot = mimcMerkle.zeroCache(2); //empty subtree of height 2
        require(currentRoot == mimcMerkle.getRootFromProof2(
            emptySubtreeRoot, subtreePosition, subtreeProof),
            "specified subtree is not empty");
        currentRoot = mimcMerkle.getRootFromProof2(
            subtreeRoot, subtreePosition, subtreeProof);
        for (uint i = 0; i < maxDepositQueueSize; i++){
            deposits[depositProcessedNumber + i] = array[i];
            delete pendingDeposits[depositProcessedNumber + i];
        }
        depositProcessedNumber = depositProcessedNumber + maxDepositQueueSize;
        return currentRoot;
    }

    function withdraw(
        uint[2] memory pubkey_from,
        uint[3] memory txInfo, //[nonce, amount, token_type_from]
        uint[2][2] memory positionAndProof, //[[position], [proof]]
        uint txRoot,
        address recipient,
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c
    ) public{
        require(updates[txRoot] > 0, "txRoot must exist");
        uint txLeaf = mimcMerkle.hashTx([
            pubkey_from[0], pubkey_from[1],
            0, 0, //withdraw to zero address
            txInfo[0], txInfo[1], txInfo[2]
        ]);
        require(txRoot == mimcMerkle.getRootFromProof2(
            txLeaf, positionAndProof[0], positionAndProof[1]),
            "transaction does not exist in specified transactions root"
        );

        // message is hash of nonce and recipient address
        uint m = mimcMerkle.hashWithdraw([txInfo[0], uint(recipient)]);
        require(WithdrawSigVerifier.verifyProof(
            a, b, c, [pubkey_from[0], pubkey_from[1], m]),
            "eddsa signature is not valid");

        emit Withdraw(pubkey_from, recipient, txRoot, txInfo);
    }

    //call methods on TokenRegistry contract

    function registerToken(
        address tokenContract
    ) public {
        tokenRegistry.registerToken(tokenContract);
    }

    function approveToken(
        address tokenContract
    ) public onlyCoordinator {
        tokenRegistry.approveToken(tokenContract);
        emit RegisteredToken(tokenRegistry.numTokens(),tokenContract);
    }
}