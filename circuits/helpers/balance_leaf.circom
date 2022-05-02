pragma circom 2.0.0;
include "../../node_modules/circomlib/circuits/mimc.circom";

template BalanceLeaf() {

    signal input x;
    signal input y;
    signal input balance;
    signal input nonce;
    signal input tokenType;

    signal output out;

    component balanceLeaf = MultiMiMC7(5,91);
    balanceLeaf.in[0] <== x;
    balanceLeaf.in[1] <== y;
    balanceLeaf.in[2] <== balance;
    balanceLeaf.in[3] <== nonce; 
    balanceLeaf.in[4] <== tokenType;
    balanceLeaf.k <== 0;

    out <== balanceLeaf.out;
}
