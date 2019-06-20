const eddsa = require("../circomlib/src/eddsa.js");
const txLeaf = require("./generate_tx_leaf.js");
const account = require("./generate_accounts.js");
const merkle = require("./MiMCMerkle.js");
const balance = require("./generate_balance_leaf.js");
const tx = require("./generate_tx_leaf.js")
var assert = require('assert');

NONCE_MAX_VALUE = 100;

module.exports = {

    processTxArray: function(
        zeroCache,
        tx_depth,
        bal_depth,
        pubKeys,
        balanceLeafArray, // nonempty leaves in balance tree
        from_accounts_idx,
        to_accounts_idx,
        amounts,
        tx_token_types,
        signatures
    ){

        assert(zeroCache.length == bal_depth)
        const zeroLeafHash = zeroCache[0]
        const txPosArray = merkle.generateMerklePosArray(tx_depth)

        var originalState
        var intermediateRoots = new Array(2**(tx_depth+1))

        var fromProofs = new Array(2**tx_depth)
        var newToProofs = new Array(2**tx_depth)

        var fromPosArray = new Array(2**tx_depth)
        var toPosArray = new Array(2**tx_depth)

        const from_accounts = module.exports.pickByIndices(pubKeys, from_accounts_idx)
        const to_accounts = module.exports.pickByIndices(pubKeys, to_accounts_idx)

        const from_x = account.getPubKeysX(from_accounts)
        const from_y = account.getPubKeysY(from_accounts)

        var R8xArray = module.exports.stringifyArray(txLeaf.getSignaturesR8x(signatures))
        var R8yArray = module.exports.stringifyArray(txLeaf.getSignaturesR8y(signatures))
        var SArray = module.exports.stringifyArray(txLeaf.getSignaturesS(signatures))

        var nonceFromArray = new Array(2**tx_depth)

        const to_x = account.getPubKeysX(to_accounts)
        const to_y = account.getPubKeysY(to_accounts)

        var nonceToArray = new Array(2**tx_depth)

        var tokenBalanceFromArray = new Array(2**tx_depth)
        var tokenBalanceToArray = new Array(2**tx_depth)
        var tokenTypeFromArray = new Array(2**tx_depth)
        var tokenTypeToArray = new Array(2**tx_depth)

        const txArray = txLeaf.generateTxLeafArray(
            from_x, from_y, to_x, to_y, amounts, tx_token_types
        )

        const txLeafHashes = txLeaf.hashTxLeafArray(txArray)
        const txTree = merkle.treeFromLeafArray(txLeafHashes)
        const txRoot = merkle.rootFromLeafArray(txLeafHashes)

        const txProofs = merkle.generateMerkleProofArray(txTree, txLeafHashes)
        
        var balanceHashArray = balance.hashBalanceLeafArray(balanceLeafArray)
        const paddedBalanceHashArray = merkle.padLeafArray(balanceHashArray, zeroLeafHash)
        var balanceSubtree = merkle.treeFromLeafArray(paddedBalanceHashArray)
        const subtreeHeight = merkle.getBase2Log(paddedBalanceHashArray.length)
        const subtreeRoot = merkle.rootFromLeafArray(paddedBalanceHashArray)
        const subtreeProof = merkle.getProofEmpty(subtreeHeight, zeroCache)
        
        originalState = merkle.rootFromLeafAndPath(subtreeRoot, 0, subtreeProof)

        intermediateRoots[0] = originalState

        for (k = 0; k < 2**tx_depth; k++){

            nonceFromArray[k] = balanceLeafArrayReceiver[from_accounts_idx[k]]['nonce']
            nonceToArray[k] = balanceLeafArrayReceiver[to_accounts_idx[k]]['nonce']
    
            tokenBalanceFromArray[k] = balanceLeafArrayReceiver[from_accounts_idx[k]]['balance']
            tokenBalanceToArray[k] = balanceLeafArrayReceiver[to_accounts_idx[k]]['balance']
            tokenTypeFromArray[k] = balanceLeafArrayReceiver[from_accounts_idx[k]]['token_type']
            tokenTypeToArray[k] = balanceLeafArrayReceiver[to_accounts_idx[k]]['token_type']

            fromPosArray[k] = merkle.idxToBinaryPos(from_accounts_idx[k], tx_depth)
            toPosArray[k] = merkle.idxToBinaryPos(to_accounts_idx[k], tx_depth)

            fromProofs[k] = merkle.getProof(from_accounts_idx[k], balanceSubtree, paddedBalanceHashArray).push(subtreeProof)

            output = module.exports.processTx(
                k, // tx index in tx tree
                txArray[k], // tx leaf
                txProofs[k], // inclusion proof of tx in tx tree
                signatures[k], // signature of tx
                txRoot, // root of tx tree
                from_accounts_idx[k], // sender index in balance tree
                to_accounts_idx[k], // receiver index in balance tree
                balanceLeafArray[from_accounts_idx[k]], //sender balance leaf
                balanceLeafArray[to_accounts_idx[k]], // receiver balance leaf
                fromProofs[k], // inclusion proof of sender in balance tree 
                subtreeRoot[k], // root of nonempty subtree
                subtreeProof[k], // inclusion proof of subtree in tree
                intermediateRoots[2*k] // root of whole tree
            )

            intermediateRoots[2*k + 1] = output['newRootSender'] ;
            intermediateRoots[2*k + 2] = output['newRootReceiver'] ;
            balanceTreeSender = output['newTreeSender'];
            balanceTreeReceiver = output['newTreeReceiver'];

            balanceLeafArraySender = output['newLeafArraySender'];
            balanceLeafHashArraySender = output['newLeafHashArraySender'];
            balanceLeafArrayReceiver = output['newLeafArrayReceiver'];
            balanceLeafHashArrayReceiver = output['newLeafHashArrayReceiver'];

            newToProofs[k] = output['newToProof'];

        }

        console.log('newRoot', intermediateRoots[2**(tx_depth + 1)])

        return{

            tx_root: txRoot.toString(),
            paths2tx_root: module.exports.stringifyArrayOfArrays(txProofs),
            paths2tx_root_pos: txPosArray,

            current_state: originalState.toString(), 

            intermediate_roots: module.exports.stringifyArray(intermediateRoots.slice(0, 2**(tx_depth + 1))),
            paths2root_from: module.exports.stringifyArrayOfArrays(fromProofs),
            paths2root_to: module.exports.stringifyArrayOfArrays(newToProofs),
            paths2root_from_pos: fromPosArray,
            paths2root_to_pos: toPosArray,

            from_x: module.exports.stringifyArray(from_x),
            from_y: module.exports.stringifyArray(from_y),
            R8x: module.exports.stringifyArray(R8xArray),
            R8y: module.exports.stringifyArray(R8yArray),
            S: module.exports.stringifyArray(SArray),

            nonce_from: nonceFromArray,
            to_x: module.exports.stringifyArray(to_x),
            to_y: module.exports.stringifyArray(to_y),
            nonce_to: nonceToArray,
            amount: amounts,

            token_balance_from: tokenBalanceFromArray,
            token_balance_to: tokenBalanceToArray,
            token_type_from: tokenTypeFromArray,
            token_type_to: tokenTypeToArray

        }

    },

    processTx: function(
        txIdx, txLeaf, txProof, signature, txRoot,
        fromLeafIdx, toLeafIdx, fromLeaf, toLeaf,
        fromProof, subtreeProof, oldSubtreeRoot, oldRoot
    ){

            // parse txLeaf
            txDepth = txProof.length //depth of tx tree
            txLeafHash = tx.hashTxLeafArray([txLeaf])[0] // hash of tx being processed
            txPos = merkle.idxToBinaryPos(txIdx, txDepth) //binary vector

            //check tx existence
            assert(merkle.verifyProof(txLeafHash, txIdx, txProof, txRoot))

            // parse balanceLeaves
            balDepth = fromProof.length; // depth of balance tree
            fromLeafHash = balance.hashBalanceLeafArray([fromLeaf])[0] // hash of sender acct
            toLeafHash = balance.hashBalanceLeafArray([toLeaf])[0] //hash of receiver acct

            // balance checks
            module.exports.checkBalances(txLeaf, fromLeaf, toLeaf)

            // signature checks
            module.exports.checkSignature(txLeaf, fromLeaf, signature)

            // nonce check
            module.exports.checkNonce(fromLeaf)

            // check sender existence in original root
            assert(merkle.verifyProof(fromLeafHash, fromLeafIdx, fromProof, oldBalanceRoot))

            // // check receiver existence in original root
            // assert(merkle.verifyProof(toLeafHash, toLeafIdx, toProof, oldBalanceRoot))

            // get new leaves
            let newFromLeaf
            let newToLeaf
            [newFromLeaf, newToLeaf] = module.exports.getNewLeaves(txLeaf, fromLeaf, toLeaf)

            // update sender leaf to get first intermediate root
            newLeafArraySender = balanceLeafArray.slice(0) //clone leaf array 
            newLeafArraySender[fromLeafIdx] = newFromLeaf

            newLeafHashArraySender = balance.hashBalanceLeafArray(newLeafArraySender)
            newTreeSender = merkle.treeFromLeafArray(newLeafHashArraySender)
            newRootSender = merkle.rootFromLeafArray(newLeafHashArraySender)

            // get inclusion proof for receiver leaf using first intermediate root
            newToProof = merkle.getProof(toLeafIdx, newTreeSender, newLeafHashArraySender)

            // check receiver existence in first intermediate root
            assert(merkle.verifyProof(toLeafHash, toLeafIdx, newToProof, newRootSender))

            // update receiver leaf to get second intermediate root
            newLeafArrayReceiver = newLeafArraySender.slice(0) //clone leaf array
            newLeafArrayReceiver[toLeafIdx] = newToLeaf
            newLeafHashArrayReceiver = balance.hashBalanceLeafArray(newLeafArrayReceiver)
            newTreeReceiver = merkle.treeFromLeafArray(newLeafHashArrayReceiver)
            newRootReceiver = merkle.rootFromLeafArray(newLeafHashArrayReceiver)

        return {
            newRootSender: newRootSender, //first intermediate root after updating sender
            newRootReceiver: newRootReceiver, //second intermediate root after updating receiver
            newTreeSender: newTreeSender, 
            newTreeReceiver: newTreeReceiver,
            newLeafArraySender: newLeafArraySender,
            newLeafHashArraySender: newLeafHashArraySender,
            newLeafArrayReceiver: newLeafArrayReceiver,
            newLeafHashArrayReceiver: newLeafHashArrayReceiver,
            newToProof: newToProof //inclusion proof for receiver in first intermediate root
        }
    },

    getNewLeaves: function(tx, fromLeaf, toLeaf){

        fromLeafCopy = balance.getZeroLeaf()
        toLeafCopy = balance.getZeroLeaf()

        newFromLeaf = Object.assign(fromLeafCopy, fromLeaf)
        newToLeaf = Object.assign(toLeafCopy, toLeaf)

        newFromLeaf['balance'] = newFromLeaf['balance'] - tx['amount']
        newFromLeaf['nonce'] = newFromLeaf['nonce'] + 1

        if (!account.isZeroAddress(toLeaf['pubKey_x'], toLeaf['pubKey_y'])){
            newToLeaf['balance'] = newToLeaf['balance'] + tx['amount']
        }
        return [newFromLeaf, newToLeaf]
    },

    checkSignature: function(tx, fromLeaf, signature){
        assert(eddsa.verifyMiMC(txLeaf.hashTxLeafArray([tx]), signature, 
            [fromLeaf['pubKey_x'], fromLeaf['pubKey_y']]))
    },

    checkBalances: function(tx, fromLeaf, toLeaf){
        assert(fromLeaf['balance'] - tx['amount'] <= fromLeaf['balance']);
        assert(toLeaf['balance'] + tx['amount'] >= toLeaf['balance']);
    },

    checkTokenTypes: function(tx, fromLeaf, toLeaf){
        if (!balance.isZeroLeaf(toLeaf)){
            assert(
                fromLeaf['token_type'] == toLeaf['token_type'] &&
                tx['token_type'] == toLeaf['token_type'] &&
                tx['token_type'] == fromLeaf['token_type'] 
            )
        }
    },

    checkNonce: function(fromLeaf){
        assert (fromLeaf['nonce'] < NONCE_MAX_VALUE)
    },

    stringifyArray: function(array){
        stringified = new Array(array.length)
        for (j = 0; j < array.length; j++){
            stringified[j] = array[j].toString()
        }
        return stringified;
    },
    
    stringifyArrayOfArrays: function(arrayOfArrays){
        outerArray = new Array(arrayOfArrays.length)
        for (i = 0; i < arrayOfArrays.length; i++){       
            outerArray[i] = module.exports.stringifyArray(arrayOfArrays[i])
        }
        return outerArray
    },

    pickByIndices: function(array, idxArray){
        pickedArray = new Array(idxArray.length)
        for (i = 0; i < idxArray.length; i++){
            pickedArray[i] = array[idxArray[i]]
        }
        return pickedArray
    }

}