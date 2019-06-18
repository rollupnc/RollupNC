const snarkjs = require("snarkjs");
const fs = require("fs");

const account = require("../../src/generate_accounts.js");
const balanceLeaf = require("../../src/generate_balance_leaf.js");
const txLeaf = require("../../src/generate_tx_leaf.js");
const merkle = require("../../src/MiMCMerkle.js")
const update = require("../../src/update.js")
const eddsa = require("../../circomlib/src/eddsa.js");

const TX_DEPTH = 2
const BAL_DEPTH = 4

// get empty tree hashes
const zeroLeaf = balanceLeaf.zeroLeaf()
const zeroLeafHash = balanceLeaf.zeroLeafHash()
const zeroCache = merkle.getZeroCache(zeroLeafHash, BAL_DEPTH)

// console.log(merkle.getZeroCache(zeroLeafHash, 5))
// generate Coordinator, A, B, C, D, E, F accounts with the following parameters
const num_accts = 7;
const prvKeys = account.generatePrvKeys(num_accts);
const zeroPubKey = account.zeroAddress()
const pubKeys = account.generatePubKeys(prvKeys);
pubKeys.unshift(zeroPubKey)

// console.log('pubkeys', pubKeys)

const token_types = [0, 0, 2, 1, 2, 1, 2, 1];
const balances = [0, 0, 1000, 20, 200, 100, 500, 20];
const nonces = [0, 0, 0, 0, 0, 0, 0, 0];

// generate balance leaves for user accounts
const balanceLeafArray = balanceLeaf.generateBalanceLeafArray(
    account.getPubKeysX(pubKeys),
    account.getPubKeysY(pubKeys),
    token_types, balances, nonces
)

const first4BalanceLeafArray = balanceLeafArray.slice(0,4)
const first4BalanceLeafArrayHash = balanceLeaf.hashBalanceLeafArray(first4BalanceLeafArray)
const first4SubtreeRoot = merkle.rootFromLeafArray(first4BalanceLeafArrayHash)
console.log('first4SubtreeRoot', first4SubtreeRoot)
const first4SubtreeProof = merkle.getProofEmpty(2, zeroCache)
console.log('first4SubtreeProof', first4SubtreeProof)
console.log('first4WholeRoot', merkle.rootFromLeafAndPath(first4SubtreeRoot, 0, first4SubtreeProof))

const paddedTo16BalanceLeafArray = merkle.padLeafHashArray(balanceLeafArray, zeroLeaf, 8)
const paddedTo16BalanceLeafArrayHash = balanceLeaf.hashBalanceLeafArray(paddedTo16BalanceLeafArray)
const balanceLeafArrayHash = balanceLeaf.hashBalanceLeafArray(balanceLeafArray)
const paddedBalanceLeafArrayHash = merkle.padLeafHashArray(balanceLeafArrayHash, zeroLeafHash)
const height = merkle.getBase2Log(paddedBalanceLeafArrayHash.length)
const nonEmptySubtreeRoot = merkle.rootFromLeafArray(paddedBalanceLeafArrayHash)
console.log('nonEmptySubtreeRoot', nonEmptySubtreeRoot)
const subtreeProof = merkle.getProofEmpty(height, zeroCache)
console.log('subtreeProof', subtreeProof)
const root = merkle.rootFromLeafAndPath(nonEmptySubtreeRoot, 0, subtreeProof)
const rootCheck = merkle.rootFromLeafArray(paddedTo16BalanceLeafArrayHash)
console.log('balance tree root', root)
console.log('balance tree root check', rootCheck)

// const testFilledArray = merkle.fillLeafArray(balanceLeafArrayHash, zeroLeafHash, 10)
// console.log(merkle.rootFromLeafArray(testFilledArray))

// generate tx's: 
// 1. Alice --500--> Charlie , 
// 2. Charlie --200--> withdraw,
// 3. Bob --10--> Daenerys,
// 4. empty tx (operator --0--> withdraw)

from_accounts_idx = [2, 4, 3, 1]
from_accounts = update.pickByIndices(pubKeys, from_accounts_idx)

to_accounts_idx = [4, 0, 5, 0]
to_accounts = update.pickByIndices(pubKeys, to_accounts_idx)

from_x = account.getPubKeysX(from_accounts)
from_y = account.getPubKeysY(from_accounts)
to_x = account.getPubKeysX(to_accounts)
to_y = account.getPubKeysY(to_accounts)
const amounts = [500, 200, 10, 0]
const tx_token_types = [2, 2, 1, 0]
const tx_nonces = [0, 0, 0, 0]

const txArray = txLeaf.generateTxLeafArray(
    from_x, from_y, to_x, to_y, tx_nonces, amounts, tx_token_types
)

const txLeafHashes = txLeaf.hashTxLeafArray(txArray)
// console.log(txLeafHashes)

const txTree = merkle.treeFromLeafArray(txLeafHashes)

// const txRoot = merkle.rootFromLeafArray(txLeafHashes)

// const txPos = merkle.generateMerklePosArray(TX_DEPTH)
const txProofs = new Array(2**TX_DEPTH)
for (jj = 0; jj < 2**TX_DEPTH; jj++){
    txProofs[jj] = merkle.getProof(jj, txTree, txLeafHashes)
}

signingPrvKeys = new Array()
from_accounts_idx.forEach(function(index){
    signingPrvKeys.push(prvKeys[index - 1])
})

const signatures = txLeaf.signTxLeafHashArray(
    txLeafHashes, 
    signingPrvKeys
)

// for (i = 0; i < from_accounts.length; i++){
//     console.log(
//         eddsa.verifyMiMC(txLeafHashes[i], signatures[i], from_accounts[i])
//     )
// }

const inputs = update.processTxArray(
    TX_DEPTH,
    BAL_DEPTH,
    pubKeys,
    paddedTo16BalanceLeafArray,
    from_accounts_idx,
    to_accounts_idx,
    tx_nonces,
    amounts,
    tx_token_types,
    signatures
)

fs.writeFileSync(
    "build/test_1_update_input.json",
    JSON.stringify(inputs),
    "utf-8"
);
