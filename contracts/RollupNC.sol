pragma solidity >=0.4.21;

import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './TransferVerifier.sol';
import './WithdrawVerifier.sol';

contract RollupNC {
    using SafeMath for uint;
    
    struct Deposit {
        address senderAddr;
        uint senderPubkey;
        address tokenAddr;
        uint amount;
    }   

    mapping(uint => Deposit) pendingDeposits;
    uint pendingDepositsCount;
    
    TransferVerifier public transferVerifier;
    WithdrawVerifier public withdrawVerifier;

    uint256 merkleRoot;
    address operator;
    
    event DepositAdded(address indexed sender, uint indexed pubKey, address indexed tokenAddr, uint amount);
    event DepositRollup(uint pendingDepositCount);

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

    /// @notice Deposit ERC20 tokens into rollup chain. Tokens must be previously approved for this contract by the sender.
    /// @param tokenAddr Address of ERC20 contract for token to be deposited
    /// @param amount Amount of tokens to deposit
    /// @param pubKey rollup public key to associate with this deposit
    /// TODO: We'll want to check signature of rollup pubkey to verify ownership?
    function depositTokens(address tokenAddr, uint amount, uint pubKey) public {
        require(IERC20(tokenAddr).allowance(msg.sender, address(this)) >= amount, "Not enough allowance");
        
        addPendingDeposit(Deposit(msg.sender, pubKey, tokenAddr, amount));

        require(IERC20(tokenAddr).transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        emit DepositAdded(msg.sender, pubKey, tokenAddr, amount);
    }
    
    /// @notice Add pending deposit to end of list
    /// @param deposit Token deposit to add
    function addPendingDeposit(Deposit memory deposit) internal {
        pendingDeposits[pendingDepositsCount] = deposit;
        pendingDepositsCount = pendingDepositsCount.add(1);
    }
    
    /// @notice Clear pending deposits list
    /// @dev We just zero out the count index as its unecessary to clear the storage here.
    function clearPendingDeposits() internal {
        pendingDepositsCount = 0;
    }
    
    /// @notice View list of pending deposits
    /// @return senderAddrs Ethereum addresses of depositors
    /// @return senderPubkeys rollup pubKeys of depositors
    /// @return tokenAddrs contract addresses for deposited tokens
    /// @return amounts deposit amounts in tokens
    function getPendingDeposits() public view returns (address[] memory, uint[] memory, address[] memory, uint[] memory) {
        address[] memory senderAddrs = new address[](pendingDepositsCount);
        uint[] memory senderPubkeys = new uint[](pendingDepositsCount);
        address[] memory tokenAddrs = new address[](pendingDepositsCount);
        uint[] memory amounts = new uint[](pendingDepositsCount);
        
        for (uint i = 0; i < pendingDepositsCount; i++) {
            senderAddrs[i] = pendingDeposits[i].senderAddr;
            senderPubkeys[i] = pendingDeposits[i].senderPubkey;
            tokenAddrs[i] = pendingDeposits[i].tokenAddr;
            amounts[i] = pendingDeposits[i].amount;
        }
        
        return (senderAddrs, senderPubkeys, tokenAddrs, amounts);
    }

    /// @notice Get list of all pending deposits and clear them on-chain. Operator will add to rollup sidechain.
    /// @dev Right now we're just clearing on read, will start a discussion of how to properly implement this with separation while avoiding concurrency issues with additional deposits being added in between read and write.
    /// @dev until we can return arrays of structs, we have to return the data as a set of primitive arrays.
    /// @return senderAddrs Ethereum addresses of depositors
    /// @return senderPubkeys rollup pubKeys of depositors
    /// @return tokenAddrs contract addresses for deposited tokens
    /// @return amounts deposit amounts in tokens
    function rollupPendingDeposits() external onlyOperator returns (address[] memory, uint[] memory, address[] memory, uint[] memory) {
        address[] memory senderAddrs;
        uint[] memory senderPubkeys;
        address[] memory tokenAddrs;
        uint[] memory amounts;
        
        (senderAddrs, senderPubkeys, tokenAddrs, amounts) = getPendingDeposits();
        emit DepositRollup(pendingDepositsCount);
        clearPendingDeposits();

        return (senderAddrs, senderPubkeys, tokenAddrs, amounts);
    }
}