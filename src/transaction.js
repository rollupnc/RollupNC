const mimcjs = require("../circomlib/src/mimc7.js");
const eddsa = require("../circomlib/src/eddsa.js");
const {stringifyBigInts, unstringifyBigInts} = require('../src/stringifybigint.js')

module.exports = class Transaction  {
    constructor(
          _fromX, _fromY, _fromIndex, 
          _toX, _toY, 
          _nonce, _amount, _tokenType, 
          _R8x, _R8y, _S
        ) {
          this.fromX = _fromX;
          this.fromY = _fromY;
          this.fromIndex = _fromIndex;
          this.toX = _toX;
          this.toY = _toY;
          this.nonce = _nonce;
          this.amount = _amount
          this.tokenType = _tokenType;

          this.hash = this.hashTx();
      
          this.R8x = _R8x;
          this.R8y = _R8y;
          this.S = _S;
    }

    hashTx(){
        // hash unsigned transaction
        const txHash = mimcjs.multiHash([
            this.fromX.toString(),
            this.fromY.toString(),
            this.fromIndex.toString(),
            this.toX.toString(),
            this.toY.toString(),
            this.nonce.toString(),
            this.amount.toString(),
            this.tokenType.toString()
        ]);
        this.hash = txHash;
        return txHash
    }

    signTxHash(prvkey){
        const signature = eddsa.signMiMC(prvkey, unstringifyBigInts(this.hash.toString()));
        this.R8x = signature.R8[0];
        this.R8y = signature.R8[1];
        this.S = signature.S;
    }

    checkSignature(){
        const signature = {
            R8: [this.R8x, this.R8y],
            S: this.S
        }
        const signed = eddsa.verifyMiMC(
            this.hash, signature, [this.fromX, this.fromY]
        )
        if (!signed){
            throw "transaction was not signed by sender"
        }
    }

}

