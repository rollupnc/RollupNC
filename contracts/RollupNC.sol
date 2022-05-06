// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "./update_state_verifier.sol";
import "./withdraw_signature_verifier.sol";
import "hardhat/console.sol";

contract IMiMC {
    function MiMCpe7(uint256,uint256) public pure returns(uint256) {}
}

contract IMiMCMerkle {

    uint[16] public zeroCache;
    function getRootFromProof(
        uint256,
        uint256[] memory,
        uint256[] memory
    ) public view returns(uint) {}
    function hashMiMC(uint[] memory) public view returns(uint){}
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

contract IERC20 {
    function transferFrom(address from, address to, uint256 value) public returns(bool) {}
	function transfer(address recipient, uint value) public returns (bool) {}
    function balanceOf(address account) external view returns (uint256) {}
    function allowance(address owner, address spender) external view returns (uint256) {}
}

contract RollupNC {

    IMiMC public mimc;
    IMiMCMerkle public mimcMerkle;
    ITokenRegistry public tokenRegistry;
    IERC20 public tokenContract;

    Update_verifier updateVerifier;
    Withdraw_verifier withdrawVerifier;

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

    struct TxInfo {
        uint pubkeyX;
        uint pubkeyY;
        uint index;
        uint toX;
        uint toY;
        uint nonce;
        uint amount;
        uint token_type_from;
        uint txRoot;
        uint[] position;
        uint[] proof;
}

    event RegisteredToken(uint tokenType, address tokenContract);
    event RequestDeposit(uint[2] pubkey, uint amount, uint tokenType);
    event UpdatedState(uint currentRoot, uint oldRoot, uint txRoot);
    event Withdraw(TxInfo accountInfo, address recipient);

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
        updateVerifier = new Update_verifier();
        withdrawVerifier = new Withdraw_verifier();
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
        require(updateVerifier.update_verifyProof(a,b,c,input),
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
      if ( tokenType == 0 ) {
           require(
			   msg.sender == coordinator,
			   "tokenType 0 is reserved for coordinator");
           require(
			   amount == 0 && msg.value == 0,
			   "tokenType 0 does not have real value");
        } else if ( tokenType == 1 ) {
           require(
			   msg.value > 0 && msg.value >= amount,
			   "msg.value must at least equal stated amount in wei");
        } else if ( tokenType > 1 ) {
            require(
				amount > 0,
				"token deposit must be greater than 0");
            address tokenContractAddress = tokenRegistry.registeredTokens(tokenType);
            tokenContract = IERC20(tokenContractAddress);
            require(
                tokenContract.transferFrom(msg.sender, address(this), amount),
                "token transfer not approved"
            );
        }

        uint[] memory depositArray = new uint[](5);
        depositArray[0] = pubkey[0];
        depositArray[1] = pubkey[1];
        depositArray[2] = amount;
        depositArray[3] = 0;
        depositArray[4] = tokenType;

        uint depositHash = mimcMerkle.hashMiMC(
            depositArray
        );
        console.log("depositHash:", depositHash);
        pendingDeposits.push(depositHash);
        emit RequestDeposit(pubkey, amount, tokenType);
        queueNumber++;
        uint tmpDepositSubtreeHeight = 0;
        uint tmp = queueNumber;
        while(tmp % 2 == 0){
            uint[] memory array = new uint[](2);
            array[0] = pendingDeposits[pendingDeposits.length - 2];
            array[1] = pendingDeposits[pendingDeposits.length - 1];
            pendingDeposits[pendingDeposits.length - 2] = mimcMerkle.hashMiMC(
                array
            );
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
        uint subtreeDepth,
        uint[] memory subtreePosition,
        uint[] memory subtreeProof
    ) public onlyCoordinator returns(uint256){
        uint emptySubtreeRoot = mimcMerkle.zeroCache(subtreeDepth); //empty subtree of height 2
        console.log("getRootFromProof:", mimcMerkle.getRootFromProof(
            emptySubtreeRoot, subtreePosition, subtreeProof));
        console.log("currentRoot:", currentRoot);
        require(currentRoot == mimcMerkle.getRootFromProof(
            emptySubtreeRoot, subtreePosition, subtreeProof),
            "specified subtree is not empty");
        console.log("pendingDeposits", pendingDeposits[0]);
        currentRoot = mimcMerkle.getRootFromProof(
            pendingDeposits[0], subtreePosition, subtreeProof);
        console.log("current root:", currentRoot);
        removeDeposit(0);
        queueNumber = queueNumber - 2**depositSubtreeHeight;
        return currentRoot;
    }

    function withdraw(
        TxInfo memory txInfo, //[pubkeyX, pubkeyY, index, toX ,toY, nonce, amount, token_type_from, txRoot]
        // uint[] memory position,
        // uint[] memory proof,
        address payable recipient,
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c
    ) public{
        require(txInfo.token_type_from > 0, "invalid tokenType");
        require(updates[txInfo.txRoot] > 0, "txRoot does not exist");
        uint[] memory txArray = new uint[](8);
        txArray[0] = txInfo.pubkeyX;
        txArray[1] = txInfo.pubkeyY;
        txArray[2] = txInfo.index;
        txArray[3] = txInfo.toX;
        txArray[4] = txInfo.toY;
        txArray[5] = txInfo.nonce;
        txArray[6] = txInfo.amount;
        txArray[7] = txInfo.token_type_from;
        
        uint txLeaf = mimcMerkle.hashMiMC(txArray);
        require(txInfo.txRoot == mimcMerkle.getRootFromProof(
            txLeaf, txInfo.position, txInfo.proof),
            "transaction does not exist in specified transactions root"
        );

        // message is hash of nonce and recipient address
        uint[] memory msgArray = new uint[](2);
        msgArray[0] = txInfo.nonce;
        address tmp = recipient;
        msgArray[1] = uint256(uint160(tmp));
        
        require(withdrawVerifier.withdraw_verifyProof(
            a, b, c,
            [txInfo.pubkeyX, txInfo.pubkeyY, mimcMerkle.hashMiMC(msgArray)]
            ),
            "eddsa signature is not valid");

        // transfer token on tokenContract
        if (txInfo.token_type_from == 1){
            // ETH
            recipient.transfer(txInfo.amount);
        } else {
            // ERC20
            address tokenContractAddress = tokenRegistry.registeredTokens(txInfo.token_type_from);
            tokenContract = IERC20(tokenContractAddress);
            require(
                tokenContract.transfer(recipient, txInfo.amount),
                "transfer failed"
            );
        }

        emit Withdraw(txInfo, recipient);
    }

    //call methods on TokenRegistry contract

    function registerToken(
        address tokenContractAddress
    ) public {
        tokenRegistry.registerToken(tokenContractAddress);
    }

    function approveToken(
        address tokenContractAddress
    ) public onlyCoordinator {
        tokenRegistry.approveToken(tokenContractAddress);
        emit RegisteredToken(tokenRegistry.numTokens(),tokenContractAddress);
    }

    // helper functions
    function removeDeposit(uint index) internal returns(uint[] memory) {
        require(index < pendingDeposits.length, "index is out of bounds");

        for (uint i = index; i<pendingDeposits.length-1; i++){
            pendingDeposits[i] = pendingDeposits[i+1];
        }
        pendingDeposits.pop();
        return pendingDeposits;
    }
}
