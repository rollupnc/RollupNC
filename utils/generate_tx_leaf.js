const mimcjs = require("../circomlib/src/mimc7.js");
const account = require("./generate_accounts.js");
const eddsa = require("../circomlib/src/eddsa.js");

module.exports = {

    emptyTxLeaf: function(){
        leaf = {}
        leaf['from_x'] = account.coordinatorPubKey[0];
        leaf['from_y'] = account.coordinatorPubKey[1];
        leaf['to_x'] = 0;
        leaf['to_y'] = 0;
        leaf['nonce'] = 0;
        leaf['amount'] = 0;
        leaf['token_type'] = 0;
        return leaf;
    },

    emptyTxLeafHash: function(){
        emptyTxLeaf = module.exports.emptyTxLeaf()
        emptyTxLeafHash = module.exports.hashTxLeafArray([emptyTxLeaf])[0]
        return emptyTxLeafHash
    },

    generateTxLeafArray: function(
        from_x, from_y, to_x, to_y, nonces, amounts, token_types
    ){
        if (Array.isArray(from_x)){
            txLeafArray = [];
            for (var i = 0; i < from_x.length; i++){
                leaf = {}
                leaf['from_x'] = from_x[i];
                leaf['from_y'] = from_y[i];
                leaf['to_x'] = to_x[i];
                leaf['to_y'] = to_y[i];
                leaf['nonce'] = nonces[i];
                leaf['amount'] = amounts[i];
                leaf['token_type'] = token_types[i];
                txLeafArray.push(leaf);
                // console.log(i, leaf)
            }
            return txLeafArray;
        } else {
            console.log('please enter values as arrays.')
        }

    },

    hashTxLeafArray: function(leafArray){
        if (Array.isArray(leafArray)){
            txLeafHashArray = [];
            for (i = 0; i < leafArray.length; i++){
                leafHash = mimcjs.multiHash([
                    leafArray[i]['from_x'].toString(),
                    leafArray[i]['from_y'].toString(),
                    leafArray[i]['to_x'].toString(),
                    leafArray[i]['to_y'].toString(),
                    leafArray[i]['nonce'].toString(),
                    leafArray[i]['amount'].toString(),
                    leafArray[i]['token_type'].toString()
                ])
                txLeafHashArray.push(leafHash)
            }
            return txLeafHashArray
        } else {
            console.log('please enter values as arrays.')
        }
    },

    signTxLeafHashArray: function(leafHashArray, prvKeys){
        if (Array.isArray(leafHashArray)){
            signatures = [];
            for (i = 0; i < leafHashArray.length; i++){
                signature = eddsa.signMiMC(prvKeys[i], leafHashArray[i]);
                signatures.push(signature)
            }
            return signatures
        } else {
            console.log('please enter values as arrays.')
        }
    },

    getSignaturesR8x: function(signatures){
        R8xArray = new Array(signatures.length)
        for (i = 0; i < signatures.length; i++){
            R8xArray[i] = signatures[i]['R8'][0]
        }
        return R8xArray
    },

    getSignaturesR8y: function(signatures){
        R8yArray = new Array(signatures.length)
        for (i = 0; i < signatures.length; i++){
            R8yArray[i] = signatures[i]['R8'][1]
        }
        return R8yArray
    },

    getSignaturesS: function(signatures){
        SArray = new Array(signatures.length)
        for (i = 0; i < signatures.length; i++){
            SArray[i] = signatures[i]['S']
        }
        return SArray
    }
}

