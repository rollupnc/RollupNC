include "./get_merkle_root.circom";

// checks for existence of leaf in tree of depth k

template LeafExistence(k){
// k is depth of tree

    signal input leaf; 
    signal input root;
    signal input paths2_root_pos[k];
    signal input paths2_root[k];

    component computed_root = GetMerkleRoot(k);
    computed_root.leaf <== leaf;

    for (var w = 0; w < k; w++){
        computed_root.paths2_root[w] <== paths2_root[w];
        computed_root.paths2_root_pos[w] <== paths2_root_pos[w];
    }

    // equality constraint: input tx root === computed tx root 
    root === computed_root.out;

}

