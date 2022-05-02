// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

contract TokenRegistry {

    address public coordinator;
    address public rollupNC;

    mapping(address => bool) public pendingTokens;
    mapping(uint256 => address) public registeredTokens;
        // 1 -> ETH
        // 2 -> 0xaD6D458402F60fD3Bd25163575031ACDce07538D (Dai on Ropsten)
        // 3 -> 0xc778417e063141139fce010982780140aa0cd5ab (WETH on Ropsten)
    uint256 public numTokens;

    modifier fromRollupNC(){
        assert(msg.sender == rollupNC);
        _;
    }

    modifier onlyCoordinator(){
        assert(msg.sender == coordinator);
        _;
    }

    constructor(
        address _coordinator
    ) public {
        coordinator = _coordinator;
        numTokens = 1; //ETH
    }

    function setRollupNC(
        address _rollupNC
    ) public onlyCoordinator {
        rollupNC = _rollupNC;
    }

    function registerToken(
        address tokenContract
    ) public {
        require(pendingTokens[tokenContract] == false, "Token already registered.");
        pendingTokens[tokenContract] = true;
    }

    function approveToken(
        address tokenContract
    ) public fromRollupNC {
        require(pendingTokens[tokenContract], 'Token was not registered');
        numTokens++;
        registeredTokens[numTokens] = tokenContract; // tokenType => token contract address
    }

}