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
pragma solidity ^0.5.0;

import "../contracts/Pairing.sol";

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
        vk.alfa1 = Pairing.G1Point(13823044047843710244811253241981634029074954914547850220297064708121473459995,7682790073231934250983342143162017115964137509635101145947623758152978682182);
        vk.beta2 = Pairing.G2Point([20739541995846546562202026196037239975160345149426511889709563957165169199213,13606434942557832059558677085723234750519115559720973925196828398022553228041], [10234633812257639177069588812892350859554670130884314901287983309357905481211,10637229594098800149980107580242153011860811564388064320176116708311407466301]);
        vk.gamma2 = Pairing.G2Point([1937436501074665316412567576938290756083668792952625388136729172242349382723,14775188523768579729687221363980181953538532204127062199875478542436256335504], [20123605072969236617185428505362436673941700147911295268872377649605638751065,12017303847355489641344964109535177597243749770346252691029069501783801053232]);
        vk.delta2 = Pairing.G2Point([11712661545864236721954502091867023096463509691454633848709893605612439624329,17149995705801631817082635288156606200245341411756993695841557264261611449409], [21668631033216497593753041161652295614447308846730526496044219450307425397471,7829525705750508428345883403617028548118910097143368245447523223032081946907]);
        vk.IC = new Pairing.G1Point[](4);
        vk.IC[0] = Pairing.G1Point(10508672849313965007219037337111975483238952544776028146379563044583201585853,2690574739683348815260891105651177177591085777026349626219771056977862463046);
        vk.IC[1] = Pairing.G1Point(21539392809775020238601336141410021386869492286816121277299427620725665656356,6441467798545851588021291351690037939449298167945888861767731863585868005351);
        vk.IC[2] = Pairing.G1Point(12722248221915259440888527968998022894863809371273477233793332298332590408795,20355432118324260736780341890071338092016066374512618989878277185421730092763);
        vk.IC[3] = Pairing.G1Point(12576555714584303464497933273514459682885564966239139969571149217142926517345,14675934393782811704839239924329638785299308028421369461735416453778231180355);

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
