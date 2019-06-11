

//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity >=0.4.17;

import "./Pairing.sol";

contract Verifier {
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
        vk.alfa1 = Pairing.G1Point(18420611634160151947620540556732790992462454929149163730193112074315747087433,19932155283851499183292663159950588920200036606180183594862384621709499839133);
        vk.beta2 = Pairing.G2Point([10271970897685759329747696167393378715232339945947495128141113156773848546376,19594384398645127210036386832063192889813938287174501403576821774895285729175], [12981542207248620630919117352656351218824529080973063149006364220158289574117,201481375460198750258712038803362721723751490696324234016723740213496806512]);
        vk.gamma2 = Pairing.G2Point([7003764525125105681594680368700136282098300293147161290838511588004101206532,16795023470313330465941366967423407297899960031496374169169864151925310073124], [7849387369353767501303806853295977208976725282432671778660086673422563872001,16666931037906228816385434237423477869287563160206099273994656594797945378707]);
        vk.delta2 = Pairing.G2Point([7320319086355978353528301332551066956868402661422516693580254624161015285494,21630497866011277889032810736762998020824077693177826112997701244405242516937], [21324583559471077620574360028529705672185103519553241727685108056895202974985,942313424882890428353305745922062588183149306870662608703185700172487764854]);
        vk.IC = new Pairing.G1Point[](4);
        vk.IC[0] = Pairing.G1Point(3369960093775964166895593389208304930356987214114648841936631107647319466746,175122174429925067422379452001172840270321362540436883323258934669592095392);
        vk.IC[1] = Pairing.G1Point(5359917054492074713597143906860756867447805280597420566309538650602569543043,10351818307922915642941708984300657430813518463327974608801142581567041998172);
        vk.IC[2] = Pairing.G1Point(14668989380759709490310546913942135879546142325597022540915629505921089851687,15371063365802638416299571160725120062569469890312105290190314675744240264344);
        vk.IC[3] = Pairing.G1Point(17540382930800995255650769470607126762101831960463947687124757917909238265567,19756811216145780123509363119352815058805103488785694754234688675662523950989);

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
            uint[3] memory input
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
