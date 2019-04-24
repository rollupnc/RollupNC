const eddsa = require("../circomlib/src/eddsa.js");
const txLeaf = require("./generate_tx_leaf.js");
const babyJub = require("../circomlib/src/babyjub");
const snarkjs = require("snarkjs");
const bigInt = snarkjs.bigInt;
const account = require("../utils/generate_accounts.js");
const merkle = require("../utils/MiMCMerkle.js");
const balance = require("../utils/generate_balance_leaf.js");

module.exports = {

    getNewLeaves: function(tx, fromLeaf, toLeaf, signature){
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

    },

    getNewRoot: function(tx, fromLeafIdx, toLeafIdx, signature, leafArray){
        fromLeaf = leafArray[fromLeafIdx]
        toLeaf = leafArray[toLeafIdx]
        var newFromLeaf
        var newToLeaf
        [newFromLeaf, newToLeaf] = module.exports.getNewLeaves(tx, fromLeaf, toLeaf, signature)
        leafArray[fromLeafIdx] = newFromLeaf
        leafArray[toLeafIdx] = newToLeaf
        leafArrayHash = balance.hashBalanceLeafArray(leafArray)
        return merkle.rootFromLeafArray(leafArrayHash)
    },

    processTx: function(tx, fromLeafIdx, toLeafIdx, signature, leafArray){


        return {
            leafArray: leafArray,
            newRoot: newRoot,
            fromProof: fromProof,
            toProof: toProof
        }

    }

}