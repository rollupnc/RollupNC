const buildMimc7 = require("circomlibjs").buildMimc7;
const {utils} = require("ffjavascript");
const {stringifyBigInts, unstringifyBigInts} = utils;

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
    this.hash = undefined
    this.mimcjs = undefined
  }

  async initialize() {
    this.mimcjs = await buildMimc7()
    this.hash = this.hashAccount()
  }

  hashAccount(){
    const accountHash = this.mimcjs.multiHash([
      // this.index.toString(),
      stringifyBigInts(this.pubkeyX),
      stringifyBigInts(this.pubkeyY),
      stringifyBigInts(this.balance),
      stringifyBigInts(this.nonce),
      stringifyBigInts(this.tokenType),
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




