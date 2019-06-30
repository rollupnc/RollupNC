include "../../circomlib/circuits/mimc.circom";

template TxLeaf() {

    signal input fromX;
    signal input fromY;
    signal input toX;
    signal input toY;
    signal input nonce;
    signal input amount;
    signal input tokenType;

    signal output out;

    component txLeaf = MultiMiMC7(7,91);
    txLeaf.in[0] <== fromX;
    txLeaf.in[1] <== fromY;
    txLeaf.in[2] <== toX;
    txLeaf.in[3] <== toY; 
    txLeaf.in[4] <== nonce;
    txLeaf.in[5] <== amount;
    txLeaf.in[6] <== tokenType;

    out <== txLeaf.out;
}
