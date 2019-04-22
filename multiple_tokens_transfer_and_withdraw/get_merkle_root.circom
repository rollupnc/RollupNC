include "../circomlib/circuits/eddsamimc.circom";
include "../circomlib/circuits/mimc.circom";

template GetMerkleRoot(k){
// k is depth of tree

    signal input leaf;
    signal input paths2_root[k-1];
    signal input paths2_root_pos[k-1];

    signal output out;

    // hash of first two entries in tx Merkle proof
    component merkle_root[k-1];
    merkle_root[0] = MultiMiMC7(2,91);
    merkle_root[0].in[0] <== leaf - paths2_root_pos[0]* (leaf - paths2_root[0]);
    merkle_root[0].in[1] <== paths2_root[0] - paths2_root_pos[0]* (paths2_root[0] - leaf);

    // hash of all other entries in tx Merkle proof
    for (var v = 1; v < k-1; v++){
        merkle_root[v] = MultiMiMC7(2,91);
        merkle_root[v].in[0] <== merkle_root[v-1].out - paths2_root_pos[v]* (merkle_root[v-1].out - paths2_root[v]);
        merkle_root[v].in[1] <== paths2_root[v] - paths2_root_pos[v]* (paths2_root[v] - merkle_root[v-1].out);
    }

    // equality constraint: input tx root === computed tx root 
    out <== merkle_root[k-2].out;

}