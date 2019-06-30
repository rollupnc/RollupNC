const Tree = require("./tree.js");
const treeHelper = require("./treeHelper.js");

module.exports = class AccountTree extends Tree{
    constructor(
        _accounts
    ){
        super(_accounts.map(x => x.hashAccount()))
        this.accounts = _accounts
    }

    processTxArray(txTree){

        const originalState = this.root;
        const txs = txTree.txs;

        var paths2txRoot = new Array(txs.length);
        var paths2txRootPos = new Array(txs.length);
        var deltas = new Array(txs.length);

        for (var i = 0; i < txs.length; i++){

            const tx = txs[i];

            // verify tx exists in tx tree
            const [txProof, txProofPos] = txTree.getTxProofAndProofPos(tx);

            txTree.checkTxExistence(tx, txProof);
            paths2txRoot[i] = txProof;
            paths2txRootPos[i] = txProofPos;

            // process transaction
            deltas[i] = this.processTx(tx);

        }

        return {
            originalState: originalState,
            txTree: txTree,
            paths2txRoot: paths2txRoot,
            paths2txRootPos: paths2txRootPos,
            deltas: deltas
        }

    }

    processTx(tx){
        const sender = this.findAccountByPubkey(tx.fromX, tx.fromY);
        const balanceFrom = sender.balance;

        const receiver = this.findAccountByPubkey(tx.toX, tx.toY);
        const balanceTo = receiver.balance;
        const nonceTo = receiver.nonce;
        const tokenTypeTo = receiver.tokenType;

        const [senderProof, senderProofPos] = this.getAccountProof(sender);
        this.checkAccountExistence(sender, senderProof);
        tx.checkSignature();

        sender.debitAndIncreaseNonce(tx.amount);
        this.root = treeHelper.rootFromLeafAndPath(sender.hash, sender.index, senderProof);
        const rootFromNewSender = this.root;

        const [receiverProof, receiverProofPos] = this.getAccountProof(receiver);
        this.checkAccountExistence(receiver, receiverProof);

        receiver.credit(tx.amount);
        this.root = treeHelper.rootFromLeafAndPath(receiver.hash, receiver.index, receiverProof);
        const rootFromNewReceiver = this.root;

        return {
            senderProof: senderProof,
            senderProofPos: senderProofPos,
            rootFromNewSender: rootFromNewSender,
            receiverProof: receiverProof,
            receiverProofPos: receiverProofPos,
            rootFromNewReceiver: rootFromNewReceiver,
            balanceFrom: balanceFrom,
            balanceTo: balanceTo,
            nonceTo: nonceTo,
            tokenTypeTo: tokenTypeTo
        }
    }

    checkAccountExistence(account, accountProof){
        if (!this.verifyProof(account.hash, account.index, accountProof)){
            throw "account does not exist"
        }
    }

    getAccountProof(account){
        return this.getProof(account.index)
    }

    findAccountByPubkey(pubkeyX, pubkeyY){
        const account = this.accounts.filter(
            acct => (acct.pubkeyX == pubkeyX && acct.pubkeyY == pubkeyY)
        )[0];
        return account
    }

}
