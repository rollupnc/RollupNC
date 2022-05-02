pragma circom 2.0.0;
include "./tx_leaf.circom";
include "./leaf_existence.circom";
include "../../node_modules/circomlib/circuits/eddsamimc.circom";

template TxExistence(k){
// k is depth of tx tree

    signal input fromX;
    signal input fromY;
    signal input fromIndex;
    signal input toX;
    signal input toY;
    signal input nonce;
    signal input amount;
    signal input tokenType;

    signal input txRoot;
    signal input paths2rootPos[k];
    signal input paths2root[k];

    signal input R8x;
    signal input R8y;
    signal input S;

    component txLeaf = TxLeaf();
    txLeaf.fromX <== fromX;
    txLeaf.fromY <== fromY;
    txLeaf.fromIndex <== fromIndex;
    txLeaf.toX <== toX;
    txLeaf.toY <== toY;
    txLeaf.nonce <== nonce;
    txLeaf.amount <== amount;
    txLeaf.tokenType <== tokenType;

    component txExistence = LeafExistence(k);
    txExistence.leaf <== txLeaf.out;
    txExistence.root <== txRoot;

    for (var q = 0; q < k; q++){
        txExistence.paths2rootPos[q] <== paths2rootPos[q];
        txExistence.paths2root[q] <== paths2root[q];
    }

    component verifier = EdDSAMiMCVerifier();
    verifier.enabled <== 1;
    verifier.Ax <== fromX;
    verifier.Ay <== fromY;
    verifier.R8x <== R8x;
    verifier.R8y <== R8y;
    verifier.S <== S;
    verifier.M <== txLeaf.out;
}

