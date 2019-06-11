const mimcjs = require("../circomlib/src/mimc7.js");

module.exports = {

    zeroLeaf: function(){
        zeroLeaf = {};
        zeroLeaf['pubKey_x'] = BigInt("0".padStart(76,'0'));
        zeroLeaf['pubKey_y'] = BigInt("0".padStart(77,'0'));
        zeroLeaf['balance'] = 0;
        zeroLeaf['nonce'] = 0;
        zeroLeaf['token_type'] = 0;
        return zeroLeaf;
    },

    zeroLeafHash: function(){
        const zeroLeaf = module.exports.zeroLeaf()
        const zeroLeafHash = module.exports.hashBalanceLeafArray([zeroLeaf])[0]
        return zeroLeafHash
    },

    isZeroLeaf: function(balanceLeaf){
        zeroLeaf = module.exports.zeroLeaf()
        if(
            zeroLeaf['pubKey_x'] == balanceLeaf['pubKey_x'] &&
            zeroLeaf['pubKey_y'] == balanceLeaf['pubKey_y'] &&
            zeroLeaf['balance'] == balanceLeaf['balance'] &&
            zeroLeaf['nonce'] == balanceLeaf['nonce'] &&
            zeroLeaf['token_type'] == balanceLeaf['token_type'] 
        ) return true
    },

    generateBalanceLeafArray: function(accts_x, accts_y, token_types, balances, nonces){
        if (Array.isArray(accts_x)){
            balanceLeafArray = [];
            for (i = 0; i < accts_x.length; i++){
                leaf = {}
                leaf['pubKey_x'] = accts_x[i];
                leaf['pubKey_y'] = accts_y[i];
                leaf['balance'] = balances[i];
                leaf['nonce'] = nonces[i];
                leaf['token_type'] = token_types[i];
                balanceLeafArray.push(leaf);
            }
            return balanceLeafArray;
        } else {
            console.log('please enter values as arrays.')
        }

    },

    hashBalanceLeafArray: function(leafArray){
        if (Array.isArray(leafArray)){
            balanceLeafHashArray = [];
            for (i = 0; i < leafArray.length; i++){
                leafHash = mimcjs.multiHash([
                    leafArray[i]['pubKey_x'].toString(),
                    leafArray[i]['pubKey_y'].toString(),
                    leafArray[i]['balance'].toString(),
                    leafArray[i]['nonce'].toString(),
                    leafArray[i]['token_type'].toString()
                ])
                balanceLeafHashArray.push(leafHash)
            }
            return balanceLeafHashArray
        } else {
            console.log('please enter values as arrays.')
        }
    }
}

