//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity >=0.4.17;

import "./dependencies/EdDSA.sol";
import "./dependencies/SafeMath.sol";

contract MiMC{

    function MiMCpe7(uint,uint) public pure returns (uint) {}

}

contract Withdraw{

    using SafeMath for uint;

    uint public BAL_DEPTH = 6;
    uint public TX_DEPTH = 4;

    MiMC mimc;

    constructor(address _mimc) public {
        mimc = MiMC(address);
    }

    event Withdrawn(
        address indexed _recipient,
        uint indexed _tokenType,
        uint _amt
    );

    function withdraw(
        address _ethRecipient, //ethereum address to claim withdraw
        uint[2] memory _from,
        uint[2] memory _to,
        uint _amt,
        uint _tokenType,
        uint[2] memory _pubkey, 
        uint _txLeafHash, 
        uint[2] memory _R, 
        uint _s,
        uint _txRoot,
        uint[3] memory _merkleProof, // log n path from leaf to root
        uint[3] memory _merklePos //position in Merkle path (left or right)
    ) public{
        require(multihash([_from[0], _from[1], _to[0], _to[1], _amt, _tokenType]) 
                == _txLeafHash);
        require(EdDSA.Verify(_from, _txLeafHash, _R, _s));
        require (verifyMerkleProof(_txLeafHash, _txRoot, _merkleProof, _merklePos));

        emit Withdrawn(to, tokenType, amt);
    }

    //only for paths of length 3 until i figure out how to generalise array length
    function verifyMerkleProof3(
        uint _depth,
        uint _leafHash,
        uint _root,
        uint[3] memory _merkleProof, // log n path from leaf to root
        uint[3] memory _merklePos //position in Merkle path (left or right)
    ) internal pure returns(bool){
        uint[3] memory root;
        uint left = _leafHash - _merklePos[0]*(_leafHash - _merkleProof[0]);
        uint right = _merkleProof[0] - _merklePos[0]*(_merkleProof[0] - _leafHash);
        root[0] = multihash(left, right);
        for (uint i = 1; i < _depth - 1; i++) {
            left = root[i-1] - _merklePos[i]*(root[i-1] - _merkleProof[0]);
            right = _merkleProof[0] - _merklePos[i]*(_merkleProof[0] - root[i-1]);              
            root[i] = multihash([left, right]);
            }
        return(root == _root);
    }

    function multihash(uint[] memory _array) internal pure 
    returns(uint){
        uint[] memory hashResult;
        hashResult[0] = mimc.MiMCpe7(_array[0], _array[1]);
        for (uint i = 1; i < _array.length; i++) {
            hashResult[i] = mimc.MiMCpe7(hashResult[i-1], _array[i]);
        }
        return hashResult;
    }



}