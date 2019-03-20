include "./circuits/mimc.circom";
include "./circuits/eddsamimc.circom";
include "./circuits/bitify.circom";

template Main(n) {
    signal private input paths_to_root[n-1];

    signal input current_state;
    signal input pubkey_x;
    signal input pubkey_y;
    signal input R8x;
    signal input R8y;
    signal input S;
    signal input nonce;

    signal output out;

    var i;
    
    component old_hash = MultiMiMC7(3,91);
    old_hash.in[0] <== pubkey_x;
    old_hash.in[1] <== pubkey_y;
    old_hash.in[2] <== nonce;
    
    component old_merkle[n-1];
    old_merkle[0] = MultiMiMC7(2,91);
    old_merkle[0].in[0] <== old_hash.out;
    old_merkle[0].in[1] <== paths_to_root[0];
    for (i=1; i<n-1; i++){
        old_merkle[i] = MultiMiMC7(2,91);
        old_merkle[i].in[0] <== old_merkle[i-1].out;
        old_merkle[i].in[1] <== paths_to_root[i-1];
    }

    current_state === old_merkle[n-2].out;

    component verifier = EdDSAMiMCVerifier();   
    verifier.enabled <== 1;
    verifier.Ax <== pubkey_x;
    verifier.Ay <== pubkey_y;
    verifier.R8x <== R8x
    verifier.R8y <== R8y
    verifier.S <== S;
    verifier.M <== old_hash.out;
    
    component new_hash = MultiMiMC7(3,91);
    new_hash.in[0] <== pubkey_x;
    new_hash.in[1] <== pubkey_y;
    new_hash.in[2] <== nonce+1;
    
    component new_merkle[n-1];
    new_merkle[0] = MultiMiMC7(2,91);
    new_merkle[0].in[0] <== new_hash.out;
    new_merkle[0].in[1] <== paths_to_root[0];
    for (i=1; i<n-1; i++){
        new_merkle[i] = MultiMiMC7(2,91);
        new_merkle[i].in[0] <== new_merkle[i-1].out;
        new_merkle[i].in[1] <== paths_to_root[i-1];
    }
    
    out <== new_merkle[n-2].out;
}

component main = Main(24);