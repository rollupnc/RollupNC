pragma solidity >=0.4.21;

import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './MerkleTree.sol';
import './TokenRegistry.sol';

contract DepositManager {
    using SafeMath for uint;
    using MerkleTree for MerkleTree.Data;

    address coordinator;
    TokenRegistry tokenRegistry;
    uint256[] pendingDeposits;
    // current merkle root of deposit tree
    uint256 depositTreeRoot;
    // TODO: should we store the current count, or take it in as a parametre when manipulating the tree?
    uint256 depositCount;

    event PendingDepositAdded(address indexed sender, uint256 indexed pubKey_x, uint256 pubKey_y, uint256 token, uint256 balance, uint256 nonce);
    event DepositRootUpdated(uint256 indexed newRoot, uint256 indexed oldRoot);
    event TokenRegistered(address tokenAddr, uint256 tokenIndex);

    constructor(address _tokenRegistryAddress) public {
        coordinator = msg.sender;
        tokenRegistry = TokenRegistry(_tokenRegistryAddress);
    }

    modifier onlyCoordinator(){
        assert(msg.sender == coordinator);
        _;
    }

    /// @notice Deposit ERC20 tokens into contract and alert coordinator. Tokens must be previously approved for this contract by the sender.
    /// @param token Token's Index on TokenRegistry
    /// TODO: We'll want to check signature of rollup pubkey to verify ownership?
    function depositTokens(uint256 pubKey_x, uint256 pubKey_y, uint256 token, uint256 balance, uint256 nonce) public {
        address tokenAddr = tokenRegistry.getTokenAddressById(token);
        require(tokenAddr != address(0), "Token id not registered");

        IERC20 tokenContract = IERC20(tokenAddr);

        require(tokenContract.allowance(msg.sender, address(this)) >= balance, "Not enough allowance");
        require(tokenContract.transferFrom(msg.sender, address(this), balance), "Token transfer failed");

        // TODO: use MIMC
        pendingDeposits.push(uint256(keccak256(abi.encode(pubKey_x, pubKey_y, token, balance, nonce))));

        emit PendingDepositAdded(msg.sender, pubKey_x, pubKey_y, token, balance, nonce);
    }

    /// @notice coordinator publishes deposits root after incorporating new deposits.
    /// @dev Will replace params these with the proper inputs and proof.
    /// @param _newDepositTreeRoot New root for deposit merkle tree
    /// TODO Validate Proof
    function publishDeposits(uint256 _newDepositTreeRoot) external onlyCoordinator {
        // verify old tree is subtree of new tree or only if contains same leaves?
        // just checking leaves allows for reorg.
        // verify pending deposits are leaves
        depositTreeRoot = _newDepositTreeRoot;
        emit DepositRootUpdated(_newDepositTreeRoot, depositTreeRoot);

        delete pendingDeposits;
    }
}