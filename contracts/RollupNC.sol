pragma solidity >=0.4.21;

import './TransferVerifier.sol';
import './WithdrawVerifier.sol';

contract RollupNC {

    TransferVerifier public transferVerifier;
    WithdrawVerifier public withdrawVerifier;

    uint256 merkleRoot;
    address operator;

    constructor(
        address _transferVerifierContractAddr,
        address _withdrawVerifierContractAddr) 
    public {
        transferVerifier = TransferVerifier(_transferVerifierContractAddr);
        withdrawVerifier = WithdrawVerifier(_withdrawVerifierContractAddr);
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

    function withdraw(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[8] memory input
    ) public{

        //validate withdraw proof
        require(withdrawVerifier.verifyProof(a,b,c,input));
        
        //update merkle root
        merkleRoot = input[0];
    }

}