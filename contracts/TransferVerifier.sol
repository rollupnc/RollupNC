//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity >=0.4.17;

import './Pairing.sol';

contract TransferVerifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(16207976686896712039374020720990179716099077106081478590328149945571115933630,16541685107613919465726078049354919289010589197522285031347176292813368820721);
        vk.beta2 = Pairing.G2Point([2031390129094529442166910691121196933228081593988130810950843360552770521983,11179543787048798781777018039111062889869409681458123580348864570297438491224], [9326521038611341766164322328750460156829290610293964460954352477997744634585,6546418172618026538234143505251940195574641865787786847770582059977296881649]);
        vk.gamma2 = Pairing.G2Point([7172580490337278383768586766331909516033898541162627895649844141426066949792,17723969219826454493442861600933222764288891522104383532570086132421685066136], [11136831978747843167641636198717031091681964521118700968141689332342109511743,11412611844787998404953776764319511284325426542091399694617169331515248108825]);
        vk.delta2 = Pairing.G2Point([5026607461532254766763595072098485362949433111367830887775328540038402137612,8383773018851600062295400861416601678584160834188819338496153008057372379004], [20261660729225167883053858316108245870364051969016003224745880220211414090537,9727535963529359266114291404723785684280863659280386812223454055673811351224]);
        vk.IC = new Pairing.G1Point[](3);
        vk.IC[0] = Pairing.G1Point(20629527164148149636861016109741116664546711833543579710182310153948120217809,17156938178721981762798209655490046214645785257672120177037417776395136575389);
        vk.IC[1] = Pairing.G1Point(8066488779626675847148934730699876845594016043040731741508608750349284250426,14701901114662655259173117515246060091428942520822080534166524820742559688344);
        vk.IC[2] = Pairing.G1Point(18856632837574597649873665254543610224245528704643105196870831752892195080386,20894408912757283838165129132856112907523721989841121687350472982074186216593);

    }
    function verify(uint[] memory input, Proof memory proof) view internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd4(
            Pairing.negate(proof.A), proof.B,
            vk.alfa1, vk.beta2,
            vk_x, vk.gamma2,
            proof.C, vk.delta2
        )) return 1;
        return 0;
    }
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[2] memory input
        ) view public returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
