include "../../circomlib/circuits/mimc.circom";

template BalanceLeaf() {

    signal input index;
    signal input x;
    signal input y;
    signal input balance;
    signal input nonce;
    signal input tokenType;

    signal output out;

    component balanceLeaf = MultiMiMC7(6,91);
    balanceLeaf.in[0] <== index;
    balanceLeaf.in[1] <== x;
    balanceLeaf.in[2] <== y;
    balanceLeaf.in[3] <== balance;
    balanceLeaf.in[4] <== nonce; 
    balanceLeaf.in[5] <== tokenType;

    out <== balanceLeaf.out;
}
