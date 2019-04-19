pragma solidity >=0.4.21;

import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './MerkleTree.sol';
import './TransferVerifier.sol';
import './WithdrawVerifier.sol';

contract RollupNC {      
    using SafeMath for uint;  
    using MerkleTree for MerkleTree.Data;

    TransferVerifier public transferVerifier;
    WithdrawVerifier public withdrawVerifier;

    MerkleTree.Data depositTree;

    struct PendingDeposit {
        uint pubKey_x;
        uint pubKey_y;
        uint token;
        uint balance;
        uint nonce;
    }

    mapping (uint => PendingDeposit) pendingDeposits;
    uint pendingDepositCount;

    uint constant registerTokenCost = 1 ether;
    mapping (address => bool) isTokenRegistered;
    mapping (uint =>  address) tokenRegistry;
    uint tokenRegistryIndex;

    uint256 merkleRoot;
    address operator;
    
    event DepositAdded(address indexed sender, uint indexed pubKey_x, uint pubKey_y, uint token, uint balance, uint nonce);
    event DepositRootUpdated(uint256 indexed newRoot, uint256 indexed oldRoot);
    event TokenRegistered(address tokenAddr, uint tokenIndex);

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

    /// @notice Add token contract to registry. "Listing" a token in this manner costs Ether.
    /// @param _tokenAddr Address of ERC20 contract to add.
    /// @return Index of token in registry
    function registerToken(address _tokenAddr) public payable returns (uint) {
        require(msg.value == registerTokenCost, "Must send appropriate ether amount");
        require(isTokenRegistered[_tokenAddr] == false, "Token address is already registered");

        tokenRegistry[tokenRegistryIndex] == _tokenAddr;
        isTokenRegistered[_tokenAddr] == true;

        emit TokenRegistered(_tokenAddr, tokenRegistryIndex);
        
        tokenRegistryIndex = tokenRegistryIndex.add(1);
    }

    /// @notice Deposit ERC20 tokens into contract and alert Operator. Tokens must be previously approved for this contract by the sender.
    /// TODO: We'll want to check signature of rollup pubkey to verify ownership?
    function depositTokens(uint pubKey_x, uint pubKey_y, uint token, uint balance, uint nonce) public {
        IERC20 tokenContract = IERC20(tokenRegistry[token]);

        require(tokenContract.allowance(msg.sender, address(this)) >= balance, "Not enough allowance");
        require(tokenContract.transferFrom(msg.sender, address(this), balance), "Token transfer failed");
        
        addPendingDeposit(pubKey_x, pubKey_y, token, balance, nonce);

        emit DepositAdded(msg.sender, pubKey_x, pubKey_y, token, balance, nonce);
    }
    /// @notice Operator publishes deposits root after incorporating new deposits.
    /// @dev Will replace params these with the proper inputs and proof.
    /// @param newMerkleRoot New root for deposit merkle tree
    /// TODO Validate Proof
    function publishDeposits(uint256 newMerkleRoot) external onlyOperator {        
        depositMerkleRoot = newMerkleRoot;
        emit DepositRootUpdated(newMerkleRoot, depositMerkleRoot);
    }

    /// @dev Helper method to add pending deposits
    function addPendingDeposit(uint pubKey_x, uint pubKey_y, uint token, uint balance, uint nonce) internal {
        pendingDeposits[pendingDepositCount] = PendingDeposit(pubKey_x, pubKey_y, token, balance, nonce);
        pendingDepositCount = pendingDepositCount.add(1);
        depositTree.Insert(abi.encode(pubKey_x, pubKey_y, token, balance, nonce));
    }

    /// @notice Helper method to add pending deposits
    function getDepositRoot() public returns (uint256) {
        
    }
}