const eddsa = require("../circomlib/src/eddsa.js");
const txLeaf = require("./generate_tx_leaf.js");
const babyJub = require("../circomlib/src/babyjub");
const snarkjs = require("snarkjs");
const bigInt = snarkjs.bigInt;
const createBlakeHash = require("blake-hash");
const account = require("../utils/generate_accounts.js");

module.exports = {

    processTx: function(tx, fromLeaf, toLeaf, signature){
        if (eddsa.verifyMiMC(txLeaf.hashTxLeafArray([tx]), signature, 
            [fromLeaf['pubKey_x'], fromLeaf['pubKey_y']])){
            newFromLeaf = fromLeaf
            newFromLeaf['balance'] = fromLeaf['balance'] - tx['amount']
            newFromLeaf['nonce'] = fromLeaf['nonce'] + 1

            newToLeaf = toLeaf
            if (!account.isZeroAddress(toLeaf['pubKey_x'], toLeaf['pubKey_y'])){
                newToLeaf['balance'] = toLeaf['balance'] + tx['amount']
            }
            return [newFromLeaf, newToLeaf]
        } else {
            console.log('tx is not signed by sender.')
        }

    }

}