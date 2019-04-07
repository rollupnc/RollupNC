const mimcjs = require("../circomlib/src/mimc7.js");

module.exports = {
    
    generateBalanceLeaf: function(accts_x, accts_y, token_types, balances, nonces){
        if (Array.isArray(accts_x)){
            accounts = [];
            for (i = 0; i < accts_x.length; i++){
                accts = mimcjs.multiHash([
                    accts_x[i],
                    accts_y[i],
                    balances[i],
                    nonces[i],
                    token_types[i]                    
                ])
                accounts.push(accts);
            }
        } else {
            accounts = mimcjs.multiHash([
                accts_x,
                accts_y,
                balances,
                nonces,
                token_types
            ])
        }
        return accounts;
    }
}

