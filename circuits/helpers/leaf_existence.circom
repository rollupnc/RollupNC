include "./get_merkle_root.circom";

// checks for existence of leaf in tree of depth k

template LeafExistence(k){
// k is depth of tree

    signal input leaf; 
    signal input root;
    signal input paths2rootPos[k];
    signal input paths2root[k];

    component computedRoot = GetMerkleRoot(k);
    computedRoot.leaf <== leaf;

    for (var w = 0; w < k; w++){
        computedRoot.paths2root[w] <== paths2root[w];
        computedRoot.paths2rootPos[w] <== paths2rootPos[w];
    }

    // equality constraint: input tx root === computed tx root 
    root === computedRoot.out;

}

