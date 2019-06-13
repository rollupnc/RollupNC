include "../circomlib/circuits/comparators.circom"
include "../circomlib/circuits/switcher.circom"
include "../circomlib/circuits/gates.circom"

template IfBothHighForceEqual() {
    // check if these are both high, if so constrain equality on a and b
    signal private input to_x;
    signal private input to_y;

    signal private input a;
    signal private input b;

    var ZERO = 0;
    var ONE = 1;

    component zc[3];
    component or;
    component equalIf;

    zc[0] = IsZero();
    zc[1] = IsZero();
    zc[2] = IsZero();
    or = OR();

    zc[0].in <== to_x;
    zc[1].in <== to_y;

    or.a <== zc[0].out;
    or.b <== zc[1].out;

    zc[2].in <== or.out;

    equalIf = ForceEqualIfEnabled();
    equalIf.in[0] <== a;
    equalIf.in[1] <== b;
    equalIf.enabled <== zc[2].out;
}


template IfBothLowForceEqual() {
    // check if these are both low, if so constrain equality on a and b
    signal private input to_x;
    signal private input to_y;

    signal private input a;
    signal private input b;

    component zc[2];
    component ifBothHigh;

    zc[0] = IsZero();
    zc[1] = IsZero();

    zc[0].in <== to_x;
    zc[1].in <== to_y;

    ifBothHigh = IfBothHighForceEqual();
    ifBothHigh.to_x <== zc[0].out;
    ifBothHigh.to_y <== zc[1].out;
    ifBothHigh.a <== a;
    ifBothHigh.b <== b;
}
