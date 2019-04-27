const eddsa = require("../circomlib/src/eddsa.js");
const txLeaf = require("./generate_tx_leaf.js");
const account = require("../utils/generate_accounts.js");
const merkle = require("../utils/MiMCMerkle.js");
const balance = require("../utils/generate_balance_leaf.js");
const tx = require("../utils/generate_tx_leaf.js")
var assert = require('assert');

NONCE_MAX_VALUE = 100;

module.exports = {

    processTxArray: function(
        tx_depth,
        pubKeys,
        balanceLeafArray,
        from_accounts_idx,
        to_accounts_idx,
        amounts,
        tx_token_types,
        signatures,
    ){

        txPosArray = merkle.generateMerklePosArray(tx_depth)

        intermediateRoots = new Array(2**tx_depth)

        fromProofs = new Array(2**tx_depth)
        toProofs = new Array(2**tx_depth)
        newFromProofs = new Array(2**tx_depth)
        newToProofs = new Array(2**tx_depth)

        fromPosArray = new Array(2**tx_depth)
        toPosArray = new Array(2**tx_depth)

        from_accounts = module.exports.pickByIndices(pubKeys, from_accounts_idx)
        to_accounts = module.exports.pickByIndices(pubKeys, to_accounts_idx)

        from_x = account.getPubKeysX(from_accounts)
        from_y = account.getPubKeysY(from_accounts)

        R8xArray = module.exports.stringifyArray(txLeaf.getSignaturesR8x(signatures))
        R8yArray = module.exports.stringifyArray(txLeaf.getSignaturesR8y(signatures))
        SArray = module.exports.stringifyArray(txLeaf.getSignaturesS(signatures))

        nonceFromArray = new Array(2**tx_depth)

        to_x = account.getPubKeysX(to_accounts)
        to_y = account.getPubKeysY(to_accounts)

        nonceToArray = new Array(2**tx_depth)

        tokenBalanceFromArray = new Array(2**tx_depth)
        tokenBalanceToArray = new Array(2**tx_depth)
        tokenTypeFromArray = new Array(2**tx_depth)
        tokenTypeToArray = new Array(2**tx_depth)

        const txArray = txLeaf.generateTxLeafArray(
            from_x, from_y, to_x, to_y, amounts, tx_token_types
        )

        const txLeafHashes = txLeaf.hashTxLeafArray(txArray)
        const txTree = merkle.treeFromLeafArray(txLeafHashes)
        const txRoot = merkle.rootFromLeafArray(txLeafHashes)

        const txProofs = merkle.generateMerkleProofArray(txTree, txLeafHashes)
        
        var balanceLeafHashArray = balance.hashBalanceLeafArray(balanceLeafArray)
        
        var balanceTree = merkle.treeFromLeafArray(balanceLeafHashArray)
        const originalState = merkle.rootFromLeafArray(balanceLeafHashArray)

        intermediateRoots[0] = originalState

        for (k = 0; k < 2**tx_depth; k++){

            nonceFromArray[k] = balanceLeafArray[from_accounts_idx[k]]['nonce']
            nonceToArray[k] = balanceLeafArray[to_accounts_idx[k]]['nonce']
    
            tokenBalanceFromArray[k] = balanceLeafArray[from_accounts_idx[k]]['balance']
            tokenBalanceToArray[k] = balanceLeafArray[to_accounts_idx[k]]['balance']
            tokenTypeFromArray[k] = balanceLeafArray[from_accounts_idx[k]]['token_type']
            tokenTypeToArray[k] = balanceLeafArray[to_accounts_idx[k]]['token_type']

            fromPosArray[k] = merkle.idxToBinaryPos(from_accounts_idx[k], tx_depth)
            toPosArray[k] = merkle.idxToBinaryPos(to_accounts_idx[k], tx_depth)

            fromProofs[k] = merkle.getProof(from_accounts_idx[k], balanceTree, balanceLeafHashArray)
            toProofs[k] = merkle.getProof(to_accounts_idx[k], balanceTree, balanceLeafHashArray)    

            output = module.exports.processTx(
                k, txArray, txProofs[k], signatures[k], txRoot,
                from_accounts_idx[k], to_accounts_idx[k], balanceLeafArray,
                fromProofs[k], toProofs[k], intermediateRoots[k]
            )

            intermediateRoots[k + 1] = output['newRoot'] ;
            balanceTree = output['newTree'];

            balanceLeafArray = output['newLeafArray'];
            balanceLeafHashArray = output['newLeafHashArray'];

            newFromProofs[k] = output['newFromProof'];
            newToProofs[k] = output['newToProof'];

        }

        return{

            tx_root: txRoot.toString(),
            paths2tx_root: module.exports.stringifyArrayOfArrays(txProofs),
            paths2tx_root_pos: txPosArray,

            current_state: originalState.toString(), 

            intermediate_roots: module.exports.stringifyArray(intermediateRoots.slice(0, 2**tx_depth)),
            paths2old_root_from: module.exports.stringifyArrayOfArrays(fromProofs),
            paths2old_root_to: module.exports.stringifyArrayOfArrays(toProofs),
            paths2new_root_from: module.exports.stringifyArrayOfArrays(newFromProofs),
            paths2new_root_to: module.exports.stringifyArrayOfArrays(newToProofs),
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
        txIdx, txLeafArray, txProof, signature, txRoot,
        fromLeafIdx, toLeafIdx, balanceLeafArray,
        fromProof, toProof, oldBalanceRoot
    ){

            // parse txLeaf
            txDepth = txProof.length
            const txLeaf = txLeafArray[txIdx]
            txLeafHash = tx.hashTxLeafArray([txLeaf])[0]

            txPos = merkle.idxToBinaryPos(txIdx, txDepth)

            // parse balanceLeaves
            // balDepth = fromProof.length
            balDepth = 2;
            const fromLeaf = balanceLeafArray[fromLeafIdx]
            fromLeafHash = balance.hashBalanceLeafArray([fromLeaf])[0]
            const toLeaf = balanceLeafArray[toLeafIdx]
            toLeafHash = balance.hashBalanceLeafArray([toLeaf])[0]

            //check tx existence
            assert(merkle.verifyProof(txLeafHash, txIdx, txProof, txRoot))

            // balance checks
            module.exports.checkBalances(txLeaf, fromLeaf, toLeaf)

            // signature checks
            module.exports.checkSignature(txLeaf, fromLeaf, signature)

            // nonce check
            module.exports.checkNonce(fromLeaf)

            // check sender existence
            assert(merkle.verifyProof(fromLeafHash, fromLeafIdx, fromProof, oldBalanceRoot))

            // check receiver existence
            assert(merkle.verifyProof(toLeafHash, toLeafIdx, toProof, oldBalanceRoot))

            // get new leaves
            var newFromLeaf
            var newToLeaf
            [newFromLeaf, newToLeaf] = module.exports.getNewLeaves(txLeaf, fromLeaf, toLeaf)

            balanceLeafArray[fromLeafIdx] = newFromLeaf
            balanceLeafArray[toLeafIdx] = newToLeaf

            newBalanceLeafHashArray = balance.hashBalanceLeafArray(balanceLeafArray)

            // get new root
            newRoot = merkle.rootFromLeafArray(newBalanceLeafHashArray)
            newTree = merkle.treeFromLeafArray(newBalanceLeafHashArray)

            newFromProof = merkle.getProof(fromLeafIdx, newTree, newBalanceLeafHashArray)
            newToProof = merkle.getProof(toLeafIdx, newTree, newBalanceLeafHashArray)

        return {
            newRoot: newRoot,
            newTree: newTree,
            newLeafArray: balanceLeafArray,
            newLeafHashArray: newBalanceLeafHashArray,
            newFromProof: newFromProof,
            newToProof: newToProof
        }
    },

    getNewLeaves: function(tx, fromLeaf, toLeaf){
        newFromLeaf = fromLeaf
        newFromLeaf['balance'] = fromLeaf['balance'] - tx['amount']
        newFromLeaf['nonce'] = fromLeaf['nonce'] + 1

        newToLeaf = toLeaf
        if (!account.isZeroAddress(toLeaf['pubKey_x'], toLeaf['pubKey_y'])){
            newToLeaf['balance'] = toLeaf['balance'] + tx['amount']
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