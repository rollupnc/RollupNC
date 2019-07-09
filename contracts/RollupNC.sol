pragma solidity ^0.5.0;

import "../build/Update_verifier.sol";
import "../build/Withdraw_verifier.sol";

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
    function hashTx(uint[8] memory) public view returns(uint) {}
    function hashPair(uint[2] memory) public view returns(uint){}
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

contract RollupNC is Update_verifier, Withdraw_verifier{

    IMiMC public mimc;
    IMiMCMerkle public mimcMerkle;
    ITokenRegistry public tokenRegistry;

    uint256 public currentRoot;
    address public coordinator;
    uint256[] public pendingDeposits;
    uint public queueNumber;
    uint public depositSubtreeHeight;
    uint256 public updateNumber;

    uint256 public BAL_DEPTH = 4;
    uint256 public TX_DEPTH = 2;

    // (queueNumber => [pubkey_x, pubkey_y, balance, nonce, token_type])
    mapping(uint256 => uint256) public deposits; //leaf idx => leafHash
    mapping(uint256 => uint256) public updates; //txRoot => update idx

    event RegisteredToken(uint tokenType, address tokenContract);
    event RequestDeposit(uint[2] pubkey, uint amount, uint tokenType);
    event UpdatedState(uint currentRoot, uint oldRoot, uint txRoot);
    event Withdraw(uint[3] accountInfo, address recipient, uint txRoot, uint[3] txInfo);

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
        queueNumber = 0;
        depositSubtreeHeight = 0;
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
        require(update_verifyProof(a,b,c,input),
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
    ) public payable {
        require(
            (amount > 0 && tokenType > 1) ||
            (msg.value > 0 && tokenType == 1) ||
            msg.sender == coordinator,
            "Deposit must be greater than 0."
        );
        require(
            tokenType == 0 ||
            tokenType == 1 ||
            tokenRegistry.registeredTokens(tokenType) != address(0),
        "tokenType is not registered.");
        uint depositHash = mimcMerkle.hashBalance(
            [pubkey[0], pubkey[1], amount, 0, tokenType]
        );
        pendingDeposits.push(depositHash);
        emit RequestDeposit(pubkey, amount, tokenType);
        queueNumber++;
        uint tmpDepositSubtreeHeight = 0;
        uint tmp = queueNumber;
        while(tmp % 2 == 0){
            pendingDeposits[pendingDeposits.length - 2] = mimcMerkle.hashPair(
                [pendingDeposits[pendingDeposits.length - 2],
                pendingDeposits[pendingDeposits.length - 1]]);
            removeDeposit(pendingDeposits.length - 1);
            tmp = tmp / 2;
            tmpDepositSubtreeHeight++;
        }
        if (tmpDepositSubtreeHeight > depositSubtreeHeight){
            depositSubtreeHeight = tmpDepositSubtreeHeight;
        }
    }



    // coordinator adds certain number of deposits to balance tree
    // coordinator must specify subtree index in the tree since the deposits
    // are being inserted at a nonzero height
    function processDeposits(
        uint[2] memory subtreePosition,
        uint[2] memory subtreeProof
    ) public onlyCoordinator returns(uint256){
        uint emptySubtreeRoot = mimcMerkle.zeroCache(2); //empty subtree of height 2
        require(currentRoot == mimcMerkle.getRootFromProof2(
            emptySubtreeRoot, subtreePosition, subtreeProof),
            "specified subtree is not empty");
        currentRoot = mimcMerkle.getRootFromProof2(
            pendingDeposits[0], subtreePosition, subtreeProof);
        removeDeposit(0);
        queueNumber = queueNumber - 2**depositSubtreeHeight;
        return currentRoot;
    }

    function withdraw(
        uint[3] memory accountInfo, //[pubkeyX, pubkeyY, index]
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
            accountInfo[0], accountInfo[1], accountInfo[2],
            0, 0, //withdraw to zero address
            txInfo[0], txInfo[1], txInfo[2]
        ]);
        require(txRoot == mimcMerkle.getRootFromProof2(
            txLeaf, positionAndProof[0], positionAndProof[1]),
            "transaction does not exist in specified transactions root"
        );

        // message is hash of nonce and recipient address
        uint m = mimcMerkle.hashPair([txInfo[0], uint(recipient)]);
        require(withdraw_verifyProof(
            a, b, c, [accountInfo[0], accountInfo[1], m]),
            "eddsa signature is not valid");

        emit Withdraw(accountInfo, recipient, txRoot, txInfo);
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

    // helper functions
    function removeDeposit(uint index) internal returns(uint[] memory) {
        require(index < pendingDeposits.length, "index is out of bounds");

        for (uint i = index; i<pendingDeposits.length-1; i++){
            pendingDeposits[i] = pendingDeposits[i+1];
        }
        delete pendingDeposits[pendingDeposits.length-1];
        pendingDeposits.length--;
        return pendingDeposits;
    }
}
