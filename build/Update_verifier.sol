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
        vk.alfa1 = Pairing.G1Point(149307559044692901831578064888623813524857951748131929604301878784916297094,308953899691249525215455385052758352247067380293878119422101275445346319709);
        vk.beta2 = Pairing.G2Point([9907386513969861811115340933234526206872273725775992583899525256670366928178,8302576320452183926827941207220555457002563580938896125134989048507670085199], [5866502747398463731322191902062955190750094872538034580806572901244335891396,1344697778889418841357876084442639161937693201217780347281459972577564673613]);
        vk.gamma2 = Pairing.G2Point([1682173733532678598265588951941389628654181112948742118243183898584957604583,17131847939025791549315704035439324708984659832645397328306264737795547167568], [15499977353758843157117298668500253930158461771715336080265510939693578568718,15240235314186278378132701219115794721895065044756819743532827901154329717238]);
        vk.delta2 = Pairing.G2Point([6885192776484610123476675344574145377670416537666468324108107573781399410418,2111605492791937715413755907188747251506499904031143532696115069584242291391], [2700771085717846666192055454137160278650608184553851210387428744273575869328,6802445680705465233593689639502906127284085573501015518108755649428842842995]);
        vk.IC = new Pairing.G1Point[](4);
        vk.IC[0] = Pairing.G1Point(10311557340613601491567896937376252870257525376033255630304185711599385924165,17303075517255968042938837747714848269167053330707341186138469126809156774410);
        vk.IC[1] = Pairing.G1Point(4725415454853978307666376051306947024521900810683407237645993658132024273487,11921376931246780996983804244069549518022510516699472823544413489451966604657);
        vk.IC[2] = Pairing.G1Point(6386174518595405321313044530609092568680985765947588349880384314789396577701,1074795998130333046616253586777735333410538653597851036386380221170402070389);
        vk.IC[3] = Pairing.G1Point(12960710846094750880738573896416296950537963085808524021756215405576472562456,6977904480036082477142755558849178892872032036600705787215366837932381673914);

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
