pragma solidity >=0.4.21;

import './Verifier.sol';

contract RollupNC {

    Verifier public verifier;
    // WithdrawVerifier public withdrawVerifier;

    uint256 merkleRoot;
    address operator;

    constructor(address _verifierContractAddr) public {
        verifier = Verifier(_verifierContractAddr);
        // withdrawVerifier = new WithdrawVerifier();
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
        require(verifier.verifyProof(a,b,c,input));
        
        // update merkle root
        merkleRoot = input[0];
    }

    function withdraw(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[2] memory input
    ) public{

        //validate withdraw proof
        // require(withdrawVerifier.verifyProof(a,b,c,input));
        
        //update merkle root
        merkleRoot = input[0];
    }

}