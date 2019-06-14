

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
        vk.alfa1 = Pairing.G1Point(10781225378508203975207304553347435968074341338522252708536722567652589784633,1481444911811567642497751551935914607625931292747046105130994118427460070890);
        vk.beta2 = Pairing.G2Point([1549962719181633158740907279322768453592022521189476587895439823196273090428,9461395153859438725808111167104142042691314672081650123136403497062541406709], [16033429103564525493962945282121908252679445091578062115749221818259931296666,3326331231657597382608718292594302869084218833617974764657931111680197044268]);
        vk.gamma2 = Pairing.G2Point([10488036523685974305827810608806530655238382947130790306804743548115587110172,445619904704513203432017551789466998706196715220839648995258512935319794710], [3411354706238115145035473864241011273456901933305057861628655353881249401915,7560217571182541370048456504034071483156072133746307140159515217568890521061]);
        vk.delta2 = Pairing.G2Point([12388052262804838601108281535756683259839756623096679766719945819909171344691,16800492315914281697312060614436565516103700159215313585399897164587090325797], [2692543222336770808905064539011185829314827373557311907187723240368054788383,21020795384927886717244844352473145211670766252879259345354060569484314689227]);
        vk.IC = new Pairing.G1Point[](4);
        vk.IC[0] = Pairing.G1Point(10806612600446678180741724900580513772028329093205165880584968852277420985303,14835483150680730684840714922134031471118076206115750177043072563741672448409);
        vk.IC[1] = Pairing.G1Point(1570246656443276302422239125867744250062222996602608224152683761907422678963,20003483768576771059959272191837163698086429075937026890524186055251106954039);
        vk.IC[2] = Pairing.G1Point(16088350435385637829626428236989060022123233633328697491575471832157401969075,18332763828665463100990734222425555142421682470010374176005538336615913454754);
        vk.IC[3] = Pairing.G1Point(20611002160806984796833936351294175955021451607603470453442429601444842270723,18999129046157884381523685292586994740912480001125968195971633407085403881765);

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
