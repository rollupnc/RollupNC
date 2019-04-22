pragma solidity >=0.4.21;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

contract TokenRegistry {      
    using SafeMath for uint;  
    
    uint public registerTokenCost;
    mapping (address => uint) public tokenIds;
    mapping (uint =>  address) public tokenAddresses;
    uint public maxIndex;

    constructor() public {
        registerTokenCost = 1 ether;
    }

    event TokenRegistered(address tokenAddr, uint tokenIndex);

    /// @notice Add token contract to registry. Listing a token in this manner costs Ether.
    function registerToken(address _tokenAddr) public payable returns (uint) {
        require(msg.value == registerTokenCost, "Must send appropriate ether amount");
        require(tokenIds[_tokenAddr] == 0, "Token address is already registered");

        maxIndex = maxIndex.add(1); //We start from index 1 such that 0 represents an unregistered token
        tokenIds[_tokenAddr] = maxIndex;
        tokenAddresses[maxIndex] = _tokenAddr;

        emit TokenRegistered(_tokenAddr, maxIndex);
    }

    function getTokenAddressById(uint _tokenIndex) public view returns (address) {
        return tokenAddresses[_tokenIndex];
    }

    function getTokenIdByAddress(address _tokenAddr) public view returns (uint) {
        return tokenIds[_tokenAddr];
    }
}