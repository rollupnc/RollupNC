pragma solidity >=0.4.21;

import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './MerkleTree.sol';
import './TokenRegistry.sol';

contract DepositManager {
    using SafeMath for uint;
    using MerkleTree for MerkleTree.Data;

    // current merkle root of deposit tree
    uint256 depositTreeRoot;
    // TODO: should we store the current count, or take it in as a parametre when manipulating the tree?
    uint256 depositCount;
    TokenRegistry tokenRegistry;

    uint256[] pendingDeposits;
    address coordinator;

    event PendingDeposit(uint pubKey_x, uint pubKey_y, uint token, uint balance, uint nonce);
    event DepositAdded(address indexed sender, uint indexed pubKey_x, uint pubKey_y, uint token, uint balance, uint nonce);
    event DepositRootUpdated(uint256 indexed newRoot, uint256 indexed oldRoot);
    event TokenRegistered(address tokenAddr, uint tokenIndex);

    constructor(address _tokenRegistryAddress) public {
        coordinator = msg.sender;
        tokenRegistry = TokenRegistry(_tokenRegistryAddress);
    }

    modifier onlyCoordinator(){
        assert(msg.sender == coordinator);
        _;
    }

    /// @notice Deposit ERC20 tokens into contract and alert coordinator. Tokens must be previously approved for this contract by the sender.
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

    /// @notice coordinator publishes deposits root after incorporating new deposits.
    /// @dev Will replace params these with the proper inputs and proof.
    /// @param _newDepositTreeRoot New root for deposit merkle tree
    /// TODO Validate Proof
    function publishDeposits(uint256 _newDepositTreeRoot) external onlyCoordinator {
        emit DepositRootUpdated(_newDepositTreeRoot, depositTreeRoot);
        depositTreeRoot = _newDepositTreeRoot;
    }

    /// @dev Helper method to add pending deposits
    function addPendingDeposit(uint pubKey_x, uint pubKey_y, uint token, uint balance, uint nonce) internal {
        emit PendingDeposit(pubKey_x, pubKey_y, token, balance, nonce);
        // TODO: use MIMC
        pendingDeposits.push(uint256(keccak256(abi.encode(pubKey_x, pubKey_y, token, balance, nonce))));
        //TODO: Merkle Tree insertion depositTree.Insert(abi.encode(pubKey_x, pubKey_y, token, balance, nonce));
    }
}