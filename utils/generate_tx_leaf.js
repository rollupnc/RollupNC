const mimcjs = require("../circomlib/src/mimc7.js");

module.exports = {

    generateTxLeafArray: function(from_x, from_y, to_x, to_y, amounts, token_types){
        if (Array.isArray(from_x)){
            txLeafArray = [];
            for (i = 0; i < from_x.length; i++){
                leaf = {}
                leaf['from_x'] = from_x[i];
                leaf['from_y'] = from_y[i];
                leaf['to_x'] = to_x[i];
                leaf['to_y'] = to_y[i];
                leaf['amount'] = amounts[i];
                leaf['token_type'] = token_types[i];
                txLeafArray.push(leaf);
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
                    leafArray[i]['amount'].toString(),
                    leafArray[i]['token_type'].toString()
                ])
                txLeafHashArray.push(leafHash)
            }
            return txLeafHashArray
        } else {
            console.log('please enter values as arrays.')
        }
    }
    
}

