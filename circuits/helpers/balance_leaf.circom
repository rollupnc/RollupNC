include "../../circomlib/circuits/mimc.circom";

template BalanceLeaf() {

    signal input x;
    signal input y;
    signal input token_balance;
    signal input nonce;
    signal input token_type;

    signal output out;

    component balanceLeaf = MultiMiMC7(5,91);
    balanceLeaf.in[0] <== x;
    balanceLeaf.in[1] <== y;
    balanceLeaf.in[2] <== token_balance;
    balanceLeaf.in[3] <== nonce; 
    balanceLeaf.in[4] <== token_type;

    out <== balanceLeaf.out;
}
