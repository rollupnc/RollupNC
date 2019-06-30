const Tree = require("./tree.js");

module.exports = class TxTree extends Tree{
    constructor(
        _txs
    ){
        super(_txs.map(x => x.hashTx()))
        this.txs = _txs
    }

    checkTxExistence(tx, txProof){
        const txIdx = this.findTxIdx(tx.hash);
        this.verifyProof(tx.hash, txIdx, txProof);
    }

    getTxProofAndProofPos(tx){
        const txIdx = this.findTxIdx(tx.hash)
        const [proof, proofPos] = this.getProof(txIdx)
        return [proof, proofPos]
    }

    findTxIdx(txHash){
        const txIdx = this.txs.findIndex(tx => tx.hash == txHash)
        return txIdx
    }

}
