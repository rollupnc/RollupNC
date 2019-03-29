pragma solidity >=0.4.21;

import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';
import './TransferVerifier.sol';
import './WithdrawVerifier.sol';

contract RollupNC {        
    TransferVerifier public transferVerifier;
    WithdrawVerifier public withdrawVerifier;

    uint256 depositMerkleRoot;

    uint256 merkleRoot;
    address operator;
    
    event DepositAdded(address indexed sender, uint indexed pubKey, address indexed tokenAddr, uint amount);
    event DepositRootUpdated(uint256 indexed newRoot, uint256 indexed oldRoot);

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

    /// @notice Deposit ERC20 tokens into contract and alert Operator. Tokens must be previously approved for this contract by the sender.
    /// @param tokenAddr Address of ERC20 contract for token to be deposited
    /// @param amount Amount of tokens to deposit
    /// @param pubKey rollup public key to associate with this deposit
    /// TODO: We'll want to check signature of rollup pubkey to verify ownership?
    function depositTokens(address tokenAddr, uint amount, uint pubKey) public {
        require(IERC20(tokenAddr).allowance(msg.sender, address(this)) >= amount, "Not enough allowance");
        require(IERC20(tokenAddr).transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        emit DepositAdded(msg.sender, pubKey, tokenAddr, amount);
    }
    /// @notice Operator publishes deposits root after incorporating new deposits.
    /// @dev Will replace params these with the proper inputs and proof.
    /// @param newMerkleRoot New root for deposit merkle tree
    /// TODO Validate Proof
    function publishDeposits(uint256 newMerkleRoot) external onlyOperator {        
        depositMerkleRoot = newMerkleRoot;
        emit DepositRootUpdated(newMerkleRoot, depositMerkleRoot);
    }
}