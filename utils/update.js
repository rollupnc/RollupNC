const eddsa = require("../circomlib/src/eddsa.js");
const txLeaf = require("./generate_tx_leaf.js");
const babyJub = require("../circomlib/src/babyjub");
const snarkjs = require("snarkjs");
const bigInt = snarkjs.bigInt;
const createBlakeHash = require("blake-hash");

module.exports = {

    processTx: function(tx, fromLeaf, toLeaf, signature){
        const sBuff = eddsa.pruneBuffer(createBlakeHash("blake512").update(prv).digest().slice(0,32));
        let s = bigInt.leBuff2int(sBuff);
        const A = babyJub.mulPointEscalar(babyJub.Base8, s.shr(3));

        if (eddsa.verify(txLeaf.hashTxLeafArray([tx]), signature, A)){
            newFromLeaf = fromLeaf
            newFromLeaf['balance'] = fromLeaf['balance'] - tx['amount']
            newFromLeaf['nonce'] = fromLeaf['nonce'] + 1

            newToLeaf = toLeaf
            newToLeaf['balance'] = toLeaf['balance'] + tx['amount']

            return [newFromLeaf, newToLeaf]
        } else {
            console.log('tx is not signed by sender.')
        }

    }

}