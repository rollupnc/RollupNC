const buildMimc7 = require("circomlibjs").buildMimc7;
const buildEddsa = require("circomlibjs").buildEddsa;

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

    this.mimcjs = undefined
    this.eddsa = undefined
    this.hash = undefined

    this.R8x = _R8x;
    this.R8y = _R8y;
    this.S = _S;
  }

  async initialize() {
    this.mimcjs = await buildMimc7()
    this.eddsa = await buildEddsa()
    this.hash = this.hashTx();
  }

  hashTx(){
    // hash unsigned transaction
    let F = this.mimcjs.F
    const input = [
      F.toString(this.fromX),
      F.toString(this.fromY),
      this.fromIndex,
      this.toX == 0? 0 : F.toString(this.toX),
      this.toY == 0? 0 : F.toString(this.toY),
      this.nonce,
      this.amount,
      this.tokenType
    ];
    const txHash = this.mimcjs.multiHash(input)
    this.hash = txHash;
    return txHash
  }

  signTxHash(prvkey){
    const signature = this.eddsa.signMiMC(prvkey, this.hash);
    this.R8x = signature.R8[0];
    this.R8y = signature.R8[1];
    this.S = signature.S;
    return signature
  }

  checkSignature(){
    const signature = {
      R8: [this.R8x, this.R8y],
      S: this.S
    }
    const signed = this.eddsa.verifyMiMC(
      this.hash, signature, [this.fromX, this.fromY]
    )
    if (!signed){
      throw "transaction was not signed by sender"
    }
  }
}

