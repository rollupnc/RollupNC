pragma solidity >=0.4.21;

import './TransferVerifier.sol';
import './WithdrawVerifier.sol';

contract MiMC {

    function MiMCpe7(uint256,uint256) public pure returns(uint256) {}

}

contract RollupNC {

    TransferVerifier public transferVerifier;
    WithdrawVerifier public withdrawVerifier;
    // MiMC public mimc; //Rinkeby: 0xbB9da456E4918A450A936dc952F6f5d68EB76F69

    uint256 merkleRoot;
    address operator;

    constructor(
        // address _mimcContractAddr,
        address _transferVerifierContractAddr,
        address _withdrawVerifierContractAddr
    ) public {
        transferVerifier = TransferVerifier(_transferVerifierContractAddr);
        withdrawVerifier = WithdrawVerifier(_withdrawVerifierContractAddr);
        // mimc = MiMC(_mimcContractAddr); 
        operator = msg.sender;
    }

    modifier onlyOperator(){
        assert(msg.sender == operator);
        _;
    }

    function snarkTransition (
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[2] memory input) public onlyOperator {
        
        //validate proof
        require(transferVerifier.verifyProof(a,b,c,input));
        
        // update merkle root
        merkleRoot = input[0];
    }

    // function withdraw(
    //     bytes memory pubkey_from,
    //     bytes memory pubkey_to,
    //     uint amount,
    //     uint token_type_from, 
    //     uint256 tx_merkle_root, 
    //     uint256[24] memory proof, 
    //     bool[24] memory path, 
    //     uint256 leaf,
    //     address recipient
    // ) public{
    //     require(pubkey_to.equals(bytes("0")));
    //     require(membership_proof(tx_merkle_root,leaf,proof,path));

    // }

    // function membership_proof(
    //     uint256 root, 
    //     uint256 leaf, 
    //     uint256[24] memory proof, 
    //     bool[24] memory path
    // ) internal view returns(bool) {
    //     for (uint i=0;i<proof.length;i++) {
    //         if (path[i]) {
    //             leaf = hash(leaf, proof[i]);
    //         }
    //         else {
    //             leaf = hash(proof[i], leaf);
    //         }
    //     }
    //     return(leaf == root);
    // }

    // function hash(uint256 in_x, uint256 in_k) public view returns(uint256) {
    //     uint256 res = mimc.MiMCpe7(in_x,in_k);
    //     return(res);
    // }

}