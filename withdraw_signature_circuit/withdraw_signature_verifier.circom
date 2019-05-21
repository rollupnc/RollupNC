include "../circomlib/circuits/eddsamimc.circom";
include "../circomlib/circuits/mimc.circom";

template Main(){

    signal input Ax;
    signal input Ay;
    signal private input R8x;
    signal private input R8y;
    signal private input S;
    signal input nonce;
    signal input txRoot;
    signal input ethRecipientAddress;

    component message = MultiMiMC7(3,91);
    message.in[0] <== nonce;
    message.in[1] <== txRoot;
    message.in[2] <== ethRecipientAddress;

    component verifier = EdDSAMiMCVerifier();   
    verifier.enabled <== 1;
    verifier.Ax <== Ax;
    verifier.Ay <== Ay;
    verifier.R8x <== R8x;
    verifier.R8y <== R8y;
    verifier.S <== S;
    verifier.M <== message.out;

}

component main = Main();