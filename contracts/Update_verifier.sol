//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.5
//      fixed linter warnings
//      added requiere error messages
//
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./Pairing.sol";

contract Update_verifier {
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
    function verifyingKey1() internal pure returns (VerifyingKey1 memory vk) {
        vk.alfa1 = Pairing.G1Point(7917149555917076442485460811909777643172123779351056324693654551846719394826,4951611073690893623603425524188028653311734329962048135762189262070041510075);
        vk.beta2 = Pairing.G2Point([8875105465686720341186674712904773543947453194597092961073611637655479278622,12648513082242883747399976199505186196922009013736650767378141130365352583222], [10843573189236512463629578994560929360563112350364422931867477188218438328071,12992882994702592247172638168246070685372277522890169960846388765194231310202]);
        vk.gamma2 = Pairing.G2Point([5474748006431279255319789618126794379623682063280643127711436943670196399113,10247549371914559718439752768990146778201763727381290211255857526196511569856], [17151527726792574591462066590083884759636614499946552420811006655719606632597,730474758069116614038178207980878121158408503671466027269611033467420605953]);
        vk.delta2 = Pairing.G2Point([12032548938864581851720126563296534507139702590378124964968452442098113804750,20998667298348894000608943601590873124778020818610518892128714170102444316672], [1012271321673102351036853289058611388156989405204651083215168924447816517772,11491636253943378328437665624857388319721897639123643590474407317069649297912]);
        vk.IC = new Pairing.G1Point[](4);
        vk.IC[0] = Pairing.G1Point(18861255924036707419527061509341448150392916002902876440733895594039144615964,10785480352266025669062578699248202585494571632866109324557834131617191760370);
        vk.IC[1] = Pairing.G1Point(1325123163515110228198890475035258435538344572686166451619972042655196649503,15200656210893497146633814869302507757960734426693804365290198305593027444967);
        vk.IC[2] = Pairing.G1Point(15302146590442421277498148921813459145539182662093519812649412956168443369419,7286564824222066184019974261762452891969263830256031789617041779579646493631);
        vk.IC[3] = Pairing.G1Point(3562589712880695396254371898263423073790075001217718615578697900383937602271,6828244923447125154569777398137502901149739800727967117333006915602786210726);

    }
    function verify1(uint[] memory input, Proof1 memory proof) internal view returns (uint) {
        VerifyingKey1 memory vk = verifyingKey1();
        require(input.length + 1 == vk.IC.length,"verifier-bad-input");
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
    function update_verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[3] memory input
        ) public view returns (bool r) {
        Proof1 memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify1(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}