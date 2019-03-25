pragma solidity >=0.4.21;

import './Verifier.sol'

contract RollupNC {

    Verifier public verifier;
    uint256 merkleRoot;
    address operator;

    constructor() public {
        verifier = new Verifier();
        operator = msg.sender;
    }

    function snarkTransition (
            uint[2] a,
            uint[2][2] b,
            uint[2] c,
            uint[2] input) internal {
        //make sure only the operator can update the merkle tree
        require(msg.sender == operator);
        //validate proof
        require(verifier.verifyProof(a,b,c,input));
        // update merkle root
        merkle_root = input[0];
        // Do Deposits
        // Do Withdraws
    }

    function withdraw(){
        
    }

}