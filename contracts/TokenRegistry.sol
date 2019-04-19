pragma solidity >=0.4.21;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

contract TokenRegistry {      
    using SafeMath for uint;  
    
    struct Registry {
        uint registerTokenCost;
        mapping (address => uint) tokenIds;
        mapping (uint =>  address) tokenAddresses;
        uint maxIndex;
    }

    Registry registry;

    constructor() public {
        registry.registerTokenCost = 1 ether;
    }

    event TokenRegistered(address tokenAddr, uint tokenIndex);

    /// @notice Add token contract to registry. Listing a token in this manner costs Ether.
    function registerToken(address _tokenAddr) public payable {
        require(msg.value == registry.registerTokenCost, "Must send appropriate ether amount");

        Registry storage re = registry;

        require(re.tokenIds[_tokenAddr] == 0, "Token address is already registered");

        re.maxIndex = re.maxIndex.add(1); //We start from index 1 such that 0 represents an unregistered token
        re.tokenIds[_tokenAddr] == re.maxIndex;
        re.tokenAddresses[registry.maxIndex] == _tokenAddr;

        emit TokenRegistered(_tokenAddr, re.maxIndex);
    }

    function getTokenAddressById(uint _tokenIndex) public view returns (address) {
        return registry.tokenAddresses[_tokenIndex];
    }

    function getTokenIdByAddress(address _tokenAddr) public view returns (uint) {
        return registry.tokenIds[_tokenAddr];
    }
}