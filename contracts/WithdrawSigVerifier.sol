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
        vk.alfa1 = Pairing.G1Point(17274454196071360455666783696611483348843741078184156659494388958747939920357,14912395392334129928360326987733335156639628305253930837719039149644268113385);
        vk.beta2 = Pairing.G2Point([10518764423355129154223665156572040419245546551021148390439870697682521376912,9150310709878460523042476807251793840388952150699471638311223382281162418914], [5450836285174097507195146468239028283407569126148849716497029398784719432289,411195625623552867512887895730671601275055205399353653920634921874363058333]);
        vk.gamma2 = Pairing.G2Point([11137848627367818469182797067524925614893235895004604900628629317844956498480,14232469282136538545153770672588778172388156068837912938992880499600295021847], [13448972812627095339591335841495426316414038127963407302068876523031223023457,16891414836727682509594548121958187614648405968130224037759465073575533099280]);
        vk.delta2 = Pairing.G2Point([14823259264316675012583758287425559529908829529180521608937094262609905981716,20203441848466694075384600666892578866868329006726145260983752194650614217463], [11220743207460300028089796469294237408205656188374303962685419275842178604588,10040942567982297681399966146849374773638551295183892139720561170308459444124]);
        vk.IC = new Pairing.G1Point[](6);
        vk.IC[0] = Pairing.G1Point(17646718417033127920206420423836923239572493541654207129821398640303387058685,8030590580808213023475197022521605828086421081349285810244775854247106168407);
        vk.IC[1] = Pairing.G1Point(13306499833940269175066475322395177421634111229333259562939690076216898809510,4235179852555299604909002444380132992620137434554671264229594788490423126140);
        vk.IC[2] = Pairing.G1Point(6128560077047200829652209064790920131571231496538697515396050696276887128744,19736505194495507974882123014631558427585002552743028599871415032195157664562);
        vk.IC[3] = Pairing.G1Point(10379668776967315515754742055134731567649181479922174775792546253177914443336,19792300849100857790210827963551408256336962319547625513797178128160680514993);
        vk.IC[4] = Pairing.G1Point(15505255110025357716778052546125029785485877612057919391516973458494758896783,4073905535561064533791273472272513555753227832252453644861890648762728235642);
        vk.IC[5] = Pairing.G1Point(9135749494791573923885815283184226862492508351006801642956537726594751344320,21538125745335411846988442873083971982006909577152389951883669294667144427740);

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
            uint[5] memory input
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
