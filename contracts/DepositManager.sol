pragma solidity >=0.4.21;

import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './MerkleTree.sol';
import './TokenRegistry.sol';

contract DepositManager {      
    using SafeMath for uint;  
    using MerkleTree for MerkleTree.Data;

    MerkleTree.Data depositTree;
    TokenRegistry tokenRegistry;

    struct PendingDeposit {
        uint pubKey_x;
        uint pubKey_y;
        uint token;
        uint balance;
        uint nonce;
        // bytes32 root;
    }


    mapping (uint => PendingDeposit) pendingDeposits;
    uint pendingDepositCount;

    uint256 merkleRoot;
    address operator;
    
    event DepositAdded(address indexed sender, uint indexed pubKey_x, uint pubKey_y, uint token, uint balance, uint nonce);
    event DepositRootUpdated(uint256 indexed newRoot, uint256 indexed oldRoot);
    event TokenRegistered(address tokenAddr, uint tokenIndex);

    constructor(address _tokenRegistryAddress) public {
        operator = msg.sender;
        tokenRegistry = TokenRegistry(_tokenRegistryAddress);
    }

    modifier onlyOperator(){
        assert(msg.sender == operator);
        _;
    }

    /// @notice Deposit ERC20 tokens into contract and alert Operator. Tokens must be previously approved for this contract by the sender.
    /// TODO: We'll want to check signature of rollup pubkey to verify ownership?
    function depositTokens(uint pubKey_x, uint pubKey_y, uint token, uint balance, uint nonce) public {
        address tokenAddr = tokenRegistry.getTokenAddressById(token);
        require(tokenAddr != address(0), "Token id not registered");

        IERC20 tokenContract = IERC20(tokenAddr);

        require(tokenContract.allowance(msg.sender, address(this)) >= balance, "Not enough allowance");
        require(tokenContract.transferFrom(msg.sender, address(this), balance), "Token transfer failed");
        
        addPendingDeposit(pubKey_x, pubKey_y, token, balance, nonce);

        emit DepositAdded(msg.sender, pubKey_x, pubKey_y, token, balance, nonce);
    }
    /// @notice Operator publishes deposits root after incorporating new deposits.
    /// @dev Will replace params these with the proper inputs and proof.
    /// @param _newMerkleRoot New root for deposit merkle tree
    /// TODO Validate Proof
    function publishDeposits(uint256 _newMerkleRoot) external onlyOperator {        
        emit DepositRootUpdated(_newMerkleRoot, merkleRoot);
        merkleRoot = _newMerkleRoot;   
    }

    /// @dev Helper method to add pending deposits
    function addPendingDeposit(uint pubKey_x, uint pubKey_y, uint token, uint balance, uint nonce) internal {
        pendingDeposits[pendingDepositCount] = PendingDeposit(pubKey_x, pubKey_y, token, balance, nonce);
        pendingDepositCount = pendingDepositCount.add(1);
        //TODO: Merkle Tree insertion depositTree.Insert(abi.encode(pubKey_x, pubKey_y, token, balance, nonce));
    }

    /// @notice Helper method to add pending deposits
    function getDepositRoot() public returns (uint256) {
        
    }
}