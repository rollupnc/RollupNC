include "./balance_leaf.circom";
include "./leaf_existence.circom";

template BalanceExistence(k){

    signal input x;
    signal input y;
    signal input balance;
    signal input nonce;
    signal input tokenType;

    signal input balanceRoot;
    signal input paths2rootPos[k];
    signal input paths2root[k];

    component balanceLeaf = BalanceLeaf();
    balanceLeaf.x <== x;
    balanceLeaf.y <== y;
    balanceLeaf.balance <== balance;
    balanceLeaf.nonce <== nonce; 
    balanceLeaf.tokenType <== tokenType;

    component balanceExistence = LeafExistence(k);
    balanceExistence.leaf <== balanceLeaf.out;
    balanceExistence.root <== balanceRoot;

    for (var s = 0; s < k; s++){
        balanceExistence.paths2rootPos[s] <== paths2rootPos[s];
        balanceExistence.paths2root[s] <== paths2root[s];
    }


}