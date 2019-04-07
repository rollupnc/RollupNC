const mimcjs = require("../circomlib/src/mimc7.js");

module.exports = {
    
    generateTxLeaf: function(from_x, from_y, to_x, to_y, amounts, token_types){
        if (Array.isArray(from_x)){
            txArr = [];
            for (i = 0; i < from_x.length; i++){
                tx = mimcjs.multiHash([
                    from_x[i],
                    from_y[i],
                    to_x[i],
                    to_y[i],
                    amounts[i],
                    token_types[i]                    
                ])
                accounts.push(txArr);
            }
        } else {
            txArr = mimcjs.multiHash([
                from_x,
                from_y,
                to_x,
                to_y,
                amounts,
                token_types
            ])
        }
        return txArr;
    }
}

