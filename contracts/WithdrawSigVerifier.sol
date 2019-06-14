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
        vk.alfa1 = Pairing.G1Point(9700967804665496524122154330748352892405195514609020032626143316822201781799,9641111564705910511593516426802716930526528988039427844627401793642743045539);
        vk.beta2 = Pairing.G2Point([4765505033503888819573942757017400185439302174031274915684805223260697224977,10346516456593298897002235720766102080794724722019160783507533537231160205887], [7782248945808248482356657411866532420108231568606926267014198690589850329411,14437219362937491327385698195638842284168825170202606270605244513198697476928]);
        vk.gamma2 = Pairing.G2Point([11110180232935384214338731125333839014534036522958104892683085916287659459584,14619504537083121181300537086332606994019896413554669432111984451338671905484], [9027860321668372937835546966049402329958301766521019105416993816410145535650,21109349205689743692327069661627483015475571063293160046653802539646426189379]);
        vk.delta2 = Pairing.G2Point([11817247957491742636894314251269995439993163890113116323100033570288499720312,10692259702688413965379104757583992811663081868649781862044472579376966316377], [11003568823550728962933725289952710148820412737545322509043703637062560193365,2086700002212741592789830433011240363953387264620451624811777098752154434307]);
        vk.IC = new Pairing.G1Point[](4);
        vk.IC[0] = Pairing.G1Point(16857499260395268690296079278377283883727628781753863753298515049678905575855,13811704124487055833284568707720576862314885560539965623865473765210833005090);
        vk.IC[1] = Pairing.G1Point(5900759236136350606202960435002107514157401492504446847312438035133652185919,19083084402874499007079144686414315644692893410580947857395662009235790671831);
        vk.IC[2] = Pairing.G1Point(10010384805644993776629161594290407658590575361931206664089592862826462845987,20039146709382947927697755612350230416322534151368136423060020350113810446482);
        vk.IC[3] = Pairing.G1Point(15291916568115168915749342734749545891859853497611073414083351199640900893396,21850287732220545856263021897052645599045235994982546899526606431288161893177);

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
