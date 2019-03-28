include "../circomlib/circuits/mimc.circom";
include "../circomlib/circuits/eddsamimc.circom";
include "../circomlib/circuits/bitify.circom";

template Main(n) {
    signal input current_state;

    signal input last_index;
    
    signal input pubkey[2];
    signal input deposit;
    signal input token_type;

    signal private input paths2root[n-1];

    // Needed to avoid a DDoS
    // signal private input R8x;
    // signal private input R8y;
    // signal private input S;

    signal output new_state;
    signal output new_index;

    var i
    var j;
    
    last_index < 2**n;

    // computes account 
    component old_hash;
    component new_hash;

    component n2b;
    component old_merkle[n-1];
    component new_merkle[n-1];
    component verifier;
    
    var tmp_state = current_state;
    var tmp_index = last_index;
    //get path to root
    n2b = Num2Bits(n-1);
    tmp_index = tmp_index+i;
    n2b.in <== tmp_index;

    old_hash = MultiMiMC7(1,91);
    old_hash.in[0] <== 0;

    old_merkle[0] = MultiMiMC7(2,91);
    old_merkle[0].in[0] <== old_hash.out - n2b.out[0]* (old_hash.out - paths2root[0]);
    old_merkle[0].in[1] <== paths2root[0] - n2b.out[0]* (paths2root[0] - old_hash.out);

    for (j=1; j<n-1; j++){
        old_merkle[j] = MultiMiMC7(2,91);
        old_merkle[j].in[0] <== old_merkle[j-1].out - n2b.out[j]* (old_merkle[j-1].out - paths2root[j]);
        old_merkle[j].in[1] <== paths2root[j] - n2b.out[j]* (paths2root[j] - old_merkle[j-1].out);
        }

    tmp_state === old_merkle[n-2].out;

    // Needed to avoid a DDoS
    // verifier = EdDSAMiMCVerifier();   
    // verifier.enabled <== 1;
    // verifier.Ax <== pubkey[0];
    // verifier.Ay <== pubkey[1];
    // verifier.R8x <== R8x;
    // verifier.R8y <== R8y;
    // verifier.S <== S;
    // verifier.M <== pubkey[0];

    new_hash = MultiMiMC7(4,91);
    new_hash.in[0] <== pubkey[0];
    new_hash.in[1] <== deposit;
    new_hash.in[2] <== 0;
    new_hash.in[3] <== token_type;

    new_merkle[0] = MultiMiMC7(2,91);
    new_merkle[0].in[0] <== new_hash.out - n2b.out[0]* (new_hash.out - paths2root[0]);
    new_merkle[0].in[1] <== paths2root[0] - n2b.out[0]* (paths2root[0] - new_hash.out);

    for (j=1; j<n-1; j++){
        new_merkle[j] = MultiMiMC7(2,91);
        new_merkle[j].in[0] <== new_merkle[j-1].out - n2b.out[j]* (new_merkle[j-1].out - paths2root[j]);
        new_merkle[j].in[1] <== paths2root[j] - n2b.out[j]* (paths2root[j] - new_merkle[j-1].out);
        }
    tmp_state = new_merkle[n-2].out

    new_state <== new_merkle[n-2].out;
    new_index <== last_index+k;

    }

component main = Main(6);
