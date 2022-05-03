const {utils} = require("ffjavascript");
const buildMimc7 = require("circomlibjs").buildMimc7;

module.exports = async function getCircuitInput(stateTransition){

    let mimcjs = await buildMimc7()
    let F = mimcjs.F
    const currentState = stateTransition.originalState;
    const txTree = stateTransition.txTree;

    const depth = txTree.depth;

    const paths2txRoot = stateTransition.paths2txRoot
    const paths2txRootPos = stateTransition.paths2txRootPos
    const deltas = stateTransition.deltas

    var intermediateRoots = new Array(2 ** (depth + 1) + 1);
    var paths2rootFrom = new Array(2 ** depth);
    var paths2rootFromPos = new Array(2 ** depth);
    var paths2rootTo = new Array(2 ** depth);
    var paths2rootToPos = new Array(2 ** depth);

    var balanceFrom = new Array(2 ** depth);

    var balanceTo = new Array(2 ** depth);
    var nonceTo = new Array(2 ** depth);
    var tokenTypeTo = new Array(2 ** depth);

    intermediateRoots[0] = F.toString(currentState);

    for (var i = 0 ; i < deltas.length; i ++){

        delta = deltas[i];

        intermediateRoots[2*i + 1] = F.toString(delta.rootFromNewSender);

        paths2rootFrom[i] = delta.senderProof.map((item) => F.toString(item)),
        paths2rootFromPos[i] = delta.senderProofPos,

        paths2rootTo[i] = delta.receiverProof.map((item) => F.toString(item)),
        paths2rootToPos[i] = delta.receiverProofPos,

        intermediateRoots[2*i + 2] = F.toString(delta.rootFromNewReceiver);

        balanceFrom[i] = delta.balanceFrom;

        balanceTo[i] = delta.balanceTo;
        nonceTo[i] = delta.nonceTo;
        tokenTypeTo[i] = delta.tokenTypeTo;

    }

    const txs = txTree.txs;
    var fromX = new Array(2 ** depth);
    var fromY = new Array(2 ** depth);
    var fromIndex = new Array(2 ** depth);
    var toX = new Array(2 ** depth);
    var toY = new Array(2 ** depth);
    var nonceFrom = new Array(2 ** depth);
    var amount = new Array(2 ** depth);
    var tokenTypeFrom = new Array(2 ** depth);
    var R8x = new Array(2 ** depth);
    var R8y = new Array(2 ** depth);
    var S = new Array(2 ** depth);

    for (var i = 0; i < txs.length; i++){

        const tx = txs[i];

        fromX[i] = F.toString(tx.fromX);
        fromY[i] = F.toString(tx.fromY);
        fromIndex[i] = tx.fromIndex;
        // NOTE: zero address will be not zero
        toX[i] = tx.toX == 0? 0 : F.toString(tx.toX);
        toY[i] = tx.toY == 0? 0 : F.toString(tx.toY);
        nonceFrom[i] = tx.nonce;
        amount[i] = tx.amount;
        tokenTypeFrom[i] = tx.tokenType;

        R8x[i] = F.toString(tx.R8x);
        R8y[i] = F.toString(tx.R8y);
        S[i] = tx.S.toString();
        tx.checkSignature()
    }

    return {
        txRoot: F.toString(txTree.root),
        paths2txRoot: (paths2txRoot),
        paths2txRootPos: paths2txRootPos,
        currentState: F.toString(currentState),
        intermediateRoots: (intermediateRoots),
        paths2rootFrom: (paths2rootFrom),
        paths2rootFromPos: paths2rootFromPos,
        paths2rootTo: (paths2rootTo),
        paths2rootToPos: paths2rootToPos,
        fromX: (fromX),
        fromY: (fromY),
        fromIndex: fromIndex,
        toX: (toX),
        toY: (toY),
        nonceFrom: nonceFrom,
        amount: amount,
        tokenTypeFrom: tokenTypeFrom,
        R8x: (R8x),
        R8y: (R8y),
        S: (S),
        balanceFrom: balanceFrom,
        balanceTo: balanceTo,
        nonceTo: nonceTo,
        tokenTypeTo: tokenTypeTo
    }
}

