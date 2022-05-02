pragma circom 2.0.0;
include "../../node_modules/circomlib/circuits/mimc.circom";

template TxLeaf() {

    signal input fromX;
    signal input fromY;
    signal input fromIndex;
    signal input toX;
    signal input toY;
    signal input nonce;
    signal input amount;
    signal input tokenType;

    signal output out;

    component txLeaf = MultiMiMC7(8,91);
    txLeaf.in[0] <== fromX;
    txLeaf.in[1] <== fromY;
    txLeaf.in[2] <== fromIndex;
    txLeaf.in[3] <== toX;
    txLeaf.in[4] <== toY; 
    txLeaf.in[5] <== nonce;
    txLeaf.in[6] <== amount;
    txLeaf.in[7] <== tokenType;
    txLeaf.k <== 0;

    out <== txLeaf.out;
}
