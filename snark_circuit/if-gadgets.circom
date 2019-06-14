include "../circomlib/circuits/comparators.circom"
include "../circomlib/circuits/switcher.circom"
include "../circomlib/circuits/gates.circom"

// Maps ints to (0, 1). Maps 0 to 0 and all other ints to 1.
template ToBool() {
    signal input x;
    signal output out;
    component iszA = IsZero();
    component iszB = IsZero();
    iszA.in <== x;
    iszB.in <== iszA.out;
    out <== iszB.out;
}

// Outputs 1 if all k inputs are high.
template AllHigh(k) {
    signal input in[k];
    signal output out;

    component makeBool[k];
    for (var i = 0; i < k; i++) {
    	makeBool[i] = ToBool();
    	makeBool[i].x <== in[i];
    }

    component mand = MultiAND(k)
    for (var i = 0; i < k; i++) {
    	mand.in[i] <== makeBool[i].out;
    }
    out <== mand.out;
}

// Outputs 1 if all k inputs are low.
template AllLow(k) {
    signal input in[k];
    signal output out;

    component isz[k];
    component allHigh = AllHigh(k);
    for (var i = 0; i < k; i++) {
    	isz[i] = IsZero();
        isz[i].in <== in[i];
	allHigh.in[i] <== isz[i].out;
    }
    out <== allHigh.out;
}

template IfBothHighForceEqual() {
    // check if these are both high, if so constrain equality on a and b
    signal input check1;
    signal input check2;

    signal input a;
    signal input b;

    component allHigh = AllHigh(2);
    allHigh.in[0] <== check1;
    allHigh.in[1] <== check2;

    component equalIf = ForceEqualIfEnabled();
    equalIf.in[0] <== a;
    equalIf.in[1] <== b;
    equalIf.enabled <== allHigh.out;
}

template IfAThenBElseC() {
    signal input aCond;
    signal input bBranch;
    signal input cBranch;
    signal output out;

    component switcher = Switcher();
    switcher.L <== bBranch;
    switcher.R <== cBranch;
    switcher.sel <== aCond;

    out <== switcher.outR;
}
