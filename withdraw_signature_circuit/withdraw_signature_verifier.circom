include "../circomlib/circuits/eddsamimc.circom";

template Main(){

    signal input Ax;
    signal input Ay;
    signal private input R8x;
    signal private input R8y;
    signal private input S;
    signal input ethRecipientAddress;

    component verifier = EdDSAMiMCVerifier();   
    verifier.enabled <== 1;
    verifier.Ax <== Ax;
    verifier.Ay <== Ay;
    verifier.R8x <== R8x;
    verifier.R8y <== R8y;
    verifier.S <== S;
    verifier.M <== ethRecipientAddress;

}

component main = Main();