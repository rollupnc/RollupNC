pragma circom 2.0.0;
include "../../node_modules/circomlib/circuits/eddsamimc.circom";
include "../../node_modules/circomlib/circuits/mimc.circom";

template GetMerkleRoot(k){
// k is depth of tree

    signal input leaf;
    signal input paths2root[k];
    signal input paths2rootPos[k];

    signal output out;

    // hash of first two entries in tx Merkle proof
    component merkleRoot[k];
    merkleRoot[0] = MultiMiMC7(2,91);
    merkleRoot[0].in[0] <== leaf - paths2rootPos[0]* (leaf - paths2root[0]);
    merkleRoot[0].in[1] <== paths2root[0] - paths2rootPos[0]* (paths2root[0] - leaf);
    merkleRoot[0].k <== 0;

    // hash of all other entries in tx Merkle proof
    for (var v = 1; v < k; v++){
        merkleRoot[v] = MultiMiMC7(2,91);
        merkleRoot[v].in[0] <== merkleRoot[v-1].out - paths2rootPos[v]* (merkleRoot[v-1].out - paths2root[v]);
        merkleRoot[v].in[1] <== paths2root[v] - paths2rootPos[v]* (paths2root[v] - merkleRoot[v-1].out);
        merkleRoot[v].k <== 0;
    }

    // output computed Merkle root
    out <== merkleRoot[k-1].out;

}
