const mimcjs = require("../circomlib/src/mimc7.js");

module.exports = class Account {
    constructor(
        _index = 0, _pubkeyX = 0, _pubkeyY = 0, 
        _balance = 0, _nonce = 0, _tokenType  = 0,
        _prvkey = 0
    ) {
        this.index = _index;
        this.pubkeyX = _pubkeyX;
        this.pubkeyY = _pubkeyY;
        this.balance = _balance;
        this.nonce = _nonce;
        this.tokenType = _tokenType;

        this.prvkey = _prvkey;
        this.hash = this.hashAccount()
    }
    
    hashAccount(){
        const accountHash = mimcjs.multiHash([
            // this.index.toString(),
            this.pubkeyX.toString(),
            this.pubkeyY.toString(),
            this.balance.toString(),
            this.nonce.toString(),
            this.tokenType.toString(),
        ])
        return accountHash
    }

    debitAndIncreaseNonce(amount){
        this.balance = this.balance - amount; 
        this.nonce++;
        this.hash = this.hashAccount()
    }

    credit(amount){
        if (this.index > 0){ // do not credit zero leaf
            this.balance = this.balance + amount;
            this.hash = this.hashAccount()
        }
    }

}


    

