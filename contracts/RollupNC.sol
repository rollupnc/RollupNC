pragma solidity >=0.4.21;

import "./Verifier.sol";
import "./WithdrawSigVerifier.sol";


contract IMiMC {

    function MiMCpe7(uint256,uint256) public pure returns(uint256) {}

}

contract IMiMCMerkle {

    function verifyMerkleProof(
        uint256,
        uint256[2] memory,
        uint256[2] memory,
        uint256)
    public view returns(bool) {}
    function hashTx(uint[6] memory array) public returns(uint) {}

}

contract RollupNC is Verifier, WithdrawSigVerifier {

    IMiMC public mimc;
    IMiMCMerkle public mimcMerkle;

    uint256 merkleRoot;
    address coordinator;
    mapping(uint256 => uint256) txRootToOldBalanceRoot;

    constructor(
        address _mimcContractAddr,
        address _mimcMerkleContractAddr
    ) public {
        mimc = IMiMC(_mimcContractAddr);
        mimcMerkle = IMiMCMerkle(_mimcMerkleContractAddr);
        coordinator = msg.sender;
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
        merkleRoot = input[0];
        txRootToOldBalanceRoot[input[1]] = input[2];
    }

    function withdraw(
        uint[2] memory pubkey_from,
        uint[2] memory pubkey_to,
        uint[3] memory txInfo, //[nonce, amount, token_type_from]
        uint[2][2] memory positionAndProof, //[[position], [proof]]
        uint txRoot,
        address recipient,
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c
    ) public{
        require(pubkey_to[0] == 0 && pubkey_to[1] == 0,
            "withdraw must be made to zero address");
        uint txLeaf = mimcMerkle.hashTx([
            pubkey_from[0], pubkey_from[1],
            pubkey_to[0], pubkey_to[1],
            txInfo[1], txInfo[2]
        ]);
        require(mimcMerkle.verifyMerkleProof(
            txLeaf, positionAndProof[0], positionAndProof[1], txRoot),
            "transaction does not exist in specified transactions root");

        require(WithdrawSigVerifier.verifyProof(
            a, b, c, [pubkey_from[0], pubkey_from[1], txInfo[0], txRoot, (uint(recipient))]),
            "eddsa signature is not valid");

        
    }

}