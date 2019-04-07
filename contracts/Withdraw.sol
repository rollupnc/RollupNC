//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity >=0.4.17;

// import "./dependencies/EdDSA.sol";
import "./dependencies/SafeMath.sol";

contract MiMC{

    function MiMCpe7(uint,uint) public pure returns (uint) {}

}

contract EdDSA{

    function Verify( uint256[2] memory, uint256, uint256[2] memory, uint256 )
        public view returns (bool) {}

}


contract Withdraw{

    using SafeMath for uint;
    using SafeMath for uint256; 

    uint public BAL_DEPTH = 6;
    uint public TX_DEPTH = 4;

    MiMC mimc;
    EdDSA eddsa;

    constructor(address _mimc, address _eddsa) public {
        mimc = MiMC(_mimc);
        eddsa = EdDSA(_eddsa);
    }

    event Withdrawn(
        address indexed _recipient,
        uint indexed _tokenType,
        uint _amt
    );

    function withdraw(
        address _ethRecipient, //ethereum address to claim withdraw
        uint256[2] memory _from,
        // uint[2] memory _to,
        uint _amt,
        uint _tokenType,
        // uint[2] memory _pubkey, 
        uint256 _txLeafHash, 
        uint256[2] memory _R, 
        uint256 _s,
        // uint _txRoot,
        // uint[3] memory _merkleProof, // log n path from leaf to root
        // uint[3] memory _merklePos, //position in Merkle path (left or right)
        uint _msgHash
    ) public returns(bool){
        // require(multihash6([_from[0], _from[1], _to[0], _to[1], _amt, _tokenType]) 
        //         == _txLeafHash);
        require(mimc.MiMCpe7(toString(_ethRecipient), _txLeafHash) == _msgHash);
        require(eddsa.Verify(_from, _txLeafHash, _R, _s));
        // require (verifyMerkleProof3(_txLeafHash, _txRoot, _merkleProof, _merklePos));
        emit Withdrawn(_ethRecipient, _tokenType, _amt);
    }

    // //only for paths of length 3 until i figure out how to generalise array length
    // function verifyMerkleProof3(
    //     uint _leafHash,
    //     uint _root,
    //     uint[3] memory _merkleProof, // log n path from leaf to root
    //     uint[3] memory _merklePos //position in Merkle path (left or right)
    // ) internal pure returns(bool){
    //     uint[3] memory root;
    //     uint left = _leafHash - _merklePos[0]*(_leafHash - _merkleProof[0]);
    //     uint right = _merkleProof[0] - _merklePos[0]*(_merkleProof[0] - _leafHash);
    //     root[0] = mimc.MiMCpe7(left, right);
    //     for (uint i = 1; i < 3; i++) {
    //         left = root[i-1] - _merklePos[i]*(root[i-1] - _merkleProof[0]);
    //         right = _merkleProof[0] - _merklePos[i]*(_merkleProof[0] - root[i-1]);              
    //         root[i] = mimc.MiMCpe7(left, right);
    //         }
    //     return(root[2] == _root);
    // }

    // //only for arrays of length 6 until i figure out how to generalise array length
    // function multihash6(uint[6] memory _array) internal pure 
    // returns(uint){
    //     uint[5] memory hashResult;
    //     // mimc.MiMCpe7(0,1);
    //     hashResult[0] = mimc.MiMCpe7(_array[0], _array[1]);
    //     for (uint i = 1; i < _array.length; i++) {
    //         hashResult[i] = mimc.MiMCpe7(hashResult[i-1], _array[i]);
    //     }
    //     return hashResult[4];
    // }
    function toString(address addr) public returns (string memory) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++) {
        b[i] = byte(uint8(uint(addr) / (2**(8*(19 - i)))));
        }
        return string(b);
    }
}