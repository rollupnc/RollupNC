include "./balance_leaf.circom";
include "./leaf_existence.circom";

template BalanceExistence(k){

    signal input x;
    signal input y;
    signal input token_balance;
    signal input nonce;
    signal input token_type;

    signal input balance_root;
    signal input paths2_root_pos[k];
    signal input paths2_root[k];

    component balanceLeaf = BalanceLeaf();
    balanceLeaf.x <== x;
    balanceLeaf.y <== y;
    balanceLeaf.token_balance <== token_balance;
    balanceLeaf.nonce <== nonce; 
    balanceLeaf.token_type <== token_type;

    component balanceExistence = LeafExistence(k);
    balanceExistence.leaf <== balanceLeaf.out;
    balanceExistence.root <== balance_root;

    for (var s = 0; s < k; s++){
        balanceExistence.paths2_root_pos[s] <== paths2_root_pos[s];
        balanceExistence.paths2_root[s] <== paths2_root[s];
    }

}