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

import "../contracts/Pairing.sol";

contract Withdraw_verifier {
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
    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(6922800137825317709854761355372187011858344780436583871134917149313155191195,4803784671734536341847818528932882296576899739109031190886857376596443995501);
        vk.beta2 = Pairing.G2Point([10933884458737887847524918447301956757519185837911795297344621204920128171145,17957222582146940185712455178179651834664421890519480187098620374198951527720], [17568264519861915881346970642000475859008751835083506466670054353375487861835,11622867207870388111799709147880193051297336471189776202369713435199225856599]);
        vk.gamma2 = Pairing.G2Point([2314814837727256517626731298130669884032170765374949037074717845387088393948,14354247169852509374040191445363883827139240183883544548478704393542027394219], [434005662841513791739829681715009043857597042407333768922295560985940058900,4436989036011280518283051107457856579371984798454058662716477926042565903062]);
        vk.delta2 = Pairing.G2Point([5641307883459031045923988805799239245158709285783645550675128741895092227315,19127894720691385427863062532759388152288298190621244002030372836123190023348], [11884779306585534141320787638271074963593674938817958519447989015299191016904,13793342398583494317726604955220825424113403939950827305407964119117512308683]);
        vk.IC = new Pairing.G1Point[](4);
        vk.IC[0] = Pairing.G1Point(18232904104303297873093719810864101736199938641397297718631109346032311725380,7380605251200034124104001624308618350875294716090431273232183450375725977497);
        vk.IC[1] = Pairing.G1Point(1857923157051946493109870272686657870623832942011551538538675866353123503754,13811684811761627748889561500261753002191141079133439432390863607280693610877);
        vk.IC[2] = Pairing.G1Point(4177803280777240753305605861155518255972875641421525121340898537102303280365,919013977229102941523648795342669105063118976479518177460620481121085924691);
        vk.IC[3] = Pairing.G1Point(11358634721610109138847130535034796534152977445684368465400997280095961509161,8974743665975153988629230472309829939606752638645846239330617458522009788268);

    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        VerifyingKey memory vk = verifyingKey();
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
    function withdraw_verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[3] memory input
        ) public view returns (bool r) {
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