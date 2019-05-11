

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
        vk.alfa1 = Pairing.G1Point(15498479935337734211149742424586973802542067037468702995356514895682657369021,13170188063813043291968689192744754073272262463152907156750392463783871834558);
        vk.beta2 = Pairing.G2Point([12020265975378154198641204906727111061011032631603530585106112638179918084784,20858024453284123043029874306270118854103157624586762655122505498957652035483], [8238060445568532437309268732784082457300469610450357366220911339730532180813,20633125644886685526636148088091586705192033675328788125745173217302267527335]);
        vk.gamma2 = Pairing.G2Point([1891964192126087427229894167856768865537441132928626923008343388867376330926,19908934398876181710880037701456537737307761284975444302939423402906412269700], [15958928813352608770155228146209379011829626362991531441416384484128753196534,20043562897108667070998461792181459461170677105747434172334054497170181662719]);
        vk.delta2 = Pairing.G2Point([17202069413652134785325421246561491497961196083022720937313913470344591670732,153387404138859547242081725112583940347902872371567623515952679344295836354], [829306065393917197778024505865288097758527272488046173215451634993504405821,918751650383127898866665004840313875450874041051710625135213862726828758919]);
        vk.IC = new Pairing.G1Point[](4);
        vk.IC[0] = Pairing.G1Point(19596692339765054572675326792544461302577616091074643723262475779758491438634,1113927309165445196186495070488007920247800688311123613839837645309025235120);
        vk.IC[1] = Pairing.G1Point(14352052318746650999377714676743251322541522766255392933001106884784376015471,5709620328056095883266674032582997169799828018806017114878428663623670474996);
        vk.IC[2] = Pairing.G1Point(10535708770360124519416960466045092183905302540306974118404533709251841863556,15378363829053726613825650940722376674837222543033527742366417906557317470309);
        vk.IC[3] = Pairing.G1Point(21561763195519174875845472566828894710515687987433153688756631864074158824728,11198759802665636499382541785650461404285640167468545067425604800291933949979);

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
