//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity >=0.4.17;

import "./Pairing.sol";

contract WithdrawSigVerifier {
    using Pairing for *;
    struct VerifyingKey1 {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof1 {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }
    function verifyingKey1() pure internal returns (VerifyingKey1 memory vk) {
        vk.alfa1 = Pairing.G1Point(14362041936421857059366133735090450430719254132980517632792932587824549879145,18050896767224881149356049629669789339377429621980246357834686325866935853452);
        vk.beta2 = Pairing.G2Point([3426862363872686871846645027678899498019626245657234369843536512548539923293,19840674485692619472523106356334087875594888109813628692455795493342515130780], [7004123454485966062574049794903141702469308184923287200204928981253082533629,19125360376773758822093016380476950547459318283732433359054770721091427234065]);
        vk.gamma2 = Pairing.G2Point([7526788007305715866895570340877929546135228048370290623923888684893837370111,16227151240431148568712996344383491101093014180457643594440344488631001172418], [13020071557789475165859015530991957693637461549671994040891512519741471238415,19091701812332576178935631498130830119238607459111461886485951302869545862782]);
        vk.delta2 = Pairing.G2Point([7430867122162472789137885471908432118079477145368503347093058548041348229425,491124295264838968981219357400532893138120805742079706757747043571023896003], [5773351492005564811187009355393801842737106766895026904880282789480512660390,10537788164277603848253267773050171029869173619204756175298582560263297036798]);
        vk.IC = new Pairing.G1Point[](4);
        vk.IC[0] = Pairing.G1Point(4724198923564496913169126437918564367534195716172172074249183786322626481432,21691698923983568251089169952266077663151432023871161535984493147925282064083);
        vk.IC[1] = Pairing.G1Point(2640198661265514560981340640999485878609155786449322696052811480814633628135,4497138444989464396676450227505505684411732391060521259718836695072714924388);
        vk.IC[2] = Pairing.G1Point(20570527785263917134395677401136300952598139526445824548474467227684969317534,2439816027982036797315486486092869781608090393465160835363651238348610618710);
        vk.IC[3] = Pairing.G1Point(2801688982286898303918134083042230724134209121863135928139140188234348146643,11822126353681317372198550461184397938265122325364474184348094413016652123144);

    }
    function verify(uint[] memory input, Proof1 memory proof) view internal returns (uint) {
        VerifyingKey1 memory vk = verifyingKey1();
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
            uint[3] memory input
        ) view public returns (bool r) {
        Proof1 memory proof;
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
