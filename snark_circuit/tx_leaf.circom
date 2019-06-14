include "../circomlib/circuits/mimc.circom";

template TxLeaf() {

    signal input from_x;
    signal input from_y;
    signal input to_x;
    signal input to_y;
    signal input nonce;
    signal input amount;
    signal input token_type_from;

    signal output out;

    component txLeaf = MultiMiMC7(7,91);
    txLeaf.in[0] <== from_x;
    txLeaf.in[1] <== from_y;
    txLeaf.in[2] <== to_x;
    txLeaf.in[3] <== to_y; 
    txLeaf.in[4] <== nonce;
    txLeaf.in[5] <== amount;
    txLeaf.in[6] <== token_type_from;

    out <== txLeaf.out;
}
