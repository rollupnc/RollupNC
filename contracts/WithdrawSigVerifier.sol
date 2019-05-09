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
        vk.alfa1 = Pairing.G1Point(9786052009278905741097453111126157903158472542104835572278287991746348633769,3827157341359055810028539247377501233443425174742396552606731273095889365004);
        vk.beta2 = Pairing.G2Point([1992386925340525761856722533739760536957248405088274441011681841554668938363,11683004664082585065770452680926575071486133166830586709320958991842290220118], [19129380297816904319639552337344192404446476282728875511846920071590710645141,6356478183639505301281134701425945540026696437033359252285024854622210793952]);
        vk.gamma2 = Pairing.G2Point([4198078264990476936218678407309423706855457411780343456336941821553039294655,4178703785580347685919858761424105402929345409248688838243546215308504521113], [13913953788757010464321514259285349072464499613066546022726222468891631887070,10926086218241618061759937189019195347649136125952994933632734600199482760432]);
        vk.delta2 = Pairing.G2Point([21790324239759782694316551291713623504368244292791299906451805498632178345767,6613321909405522895431551699945474611076318960299020115540518857539427308122], [9978401578051034698481372762330983262356722875252910091327439163845565740588,12407412567387108212602138009031767485982370693009298752947392702158365915051]);
        vk.IC = new Pairing.G1Point[](4);
        vk.IC[0] = Pairing.G1Point(7682304918291964158356255018451340063899040847380553166319947680758320414986,16824409060507582486005531116906589536993325422428091300705932493835236504238);
        vk.IC[1] = Pairing.G1Point(20708894051059651697647508088633068165149516241029349615885641372952331798774,13158979812148480750659845737830186115798198077402906931078315180903867375873);
        vk.IC[2] = Pairing.G1Point(20078251642566057560138890204710045569341227362160815642378154130260962026991,15839911667138796340377073756080699996786014087701331211731130975938641764666);
        vk.IC[3] = Pairing.G1Point(15381306266140584712001173873142184601612760472853589555377578149752466917205,1286121252860336050689009851653366575825255507876440331079489303701723033852);

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
