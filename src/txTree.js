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
        if (!this.verifyProof(tx.hash, txIdx, txProof)){
            throw "tx does not exist"
        }
    }

    getTxProofAndProofPos(tx){
        const txIdx = this.findTxIdx(tx.hash)
        const proofObj = this.getProof(txIdx)
        return [proofObj.proof, proofObj.proofPos]
    }

    findTxIdx(txHash){
        const txIdx = this.txs.findIndex(tx => tx.hash == txHash)
        return txIdx
    }

}
