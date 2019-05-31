pragma solidity >=0.4.21;

import "./Verifier.sol";
import "./WithdrawSigVerifier.sol";


contract IMiMC {

    function MiMCpe7(uint256,uint256) public pure returns(uint256) {}

}

contract IMiMCMerkle {

    uint[16] public zeroCache;
    function verifyMerkleProof(
        uint256,
        uint256[2] memory,
        uint256[2] memory,
        uint256)
    public view returns(bool) {}
    function hashBalance(uint[5] memory array) public returns(uint){}
    function hashTx(uint[6] memory array) public returns(uint) {}
    function hashWithdraw(uint[2] memory array) public returns(uint){}
}

contract ITokenRegistry {
    address public coordinator;
    mapping(address => bool) public pendingTokens;
    mapping(uint256 => address) public registeredTokens;
    uint256 public numTokens;
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
    uint256 public queueNumber;
    uint256 public maxQueueSize;

    // (queueNumber => [pubkey_x, pubkey_y, balance, nonce, token_type])
    mapping(uint256 => uint[5]) public pendingDeposits;
    mapping(uint256 => uint256) public deposits; //leaf idx => leafHash

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
        currentRoot = 0;
        coordinator = msg.sender;
        queueNumber = 0;
        maxQueueSize = 4;
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
        //validate proof
        require(Verifier.verifyProof(a,b,c,input),
        "SNARK proof is invalid");
        // update merkle root
        currentRoot = input[0];
        emit UpdatedState(input[0], input[1], input[2]); //currentRoot, oldRoot, txRoot
    }

    // user tries to deposit ERC20 tokens
    function deposit(
        uint[2] memory pubkey,
        uint tokenType,
        uint amount
    ) public payable{
        require(
            amount > 0 || msg.value > 0 || msg.sender == coordinator,
            "Deposit must be greater than 0.");
        require(
            tokenType == 1 || tokenRegistry.registeredTokens(tokenType) != address(0),
            "tokenType is not registered.");
        if (tokenType == 1){
            pendingDeposits[queueNumber] = [
                pubkey[0], pubkey[1], msg.value, 0, 1
            ];
            queueNumber++;
            emit RequestDeposit(msg.value, 1, pubkey);
        } else {
            pendingDeposits[queueNumber] = [
                pubkey[0], pubkey[1], amount, 0, tokenType
            ];
            queueNumber++;
            emit RequestDeposit(amount, tokenType, pubkey);
        }
    }

    // coordinator adds certain number of deposits to balance tree
    // coordinator must specify starting leaf index in the tree
    function processDeposits(
        uint startIdx,
        uint[12] memory proof
    ) public onlyCoordinator{
        uint[4] memory array; //process 4 deposits at a time
        for (uint i = 0; i < maxQueueSize; i++){
            uint leafHash = mimcMerkle.hashBalance(
                pendingDeposits[queueNumber + i]
            );
            deposits[startIdx + i] = leafHash;
            array[i] = leafHash;
        }

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
        uint txLeaf = mimcMerkle.hashTx([
            pubkey_from[0], pubkey_from[1],
            0, 0, //withdraw to zero address
            txInfo[1], txInfo[2]
        ]);
        require(mimcMerkle.verifyMerkleProof(
            txLeaf, positionAndProof[0], positionAndProof[1], txRoot),
            "transaction does not exist in specified transactions root");

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