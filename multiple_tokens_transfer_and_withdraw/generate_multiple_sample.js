const eddsa = require("../circomlib/src/eddsa.js");
const snarkjs = require("snarkjs");
const fs = require("fs");
const util = require("util");
const mimcjs = require("../circomlib/src/mimc7.js");
const account = require("../utils/generate_accounts.js");
const balanceLeaf = require("../utils/generate_balance_leaf.js");
const txLeaf = require("../utils/generate_tx_leaf.js");
const merkle = require("../utils/MiMCMerkle.js")
const bigInt = snarkjs.bigInt;
const update = require("../utils/update.js")

const TX_DEPTH = 2;
const BAL_DEPTH = 2;
var txLeafArray = new Array(2**TX_DEPTH).fill(0);

// generate zero, Alice, Bob, Charlie accounts with the following parameters
const num_accts = 3;
const prvKeys = account.generatePrvKeys(num_accts);
const zeroPubKey = account.zeroAddress()
const pubKeys = account.generatePubKeys(prvKeys);
pubKeys.unshift(zeroPubKey)
const token_types = [0, 10, 10, 10];
const balances = [0, 1000, 0, 0];
const nonces = [0, 0, 0, 0];

// generate balance leaves for user accounts
const balanceLeafArray = balanceLeaf.generateBalanceLeafArray(
    account.getPubKeysX(pubKeys),
    account.getPubKeysY(pubKeys),
    token_types, balances, nonces
)

const balanceLeafHashArray = balanceLeaf.hashBalanceLeafArray(
    balanceLeafArray
)

const balanceTree = merkle.treeFromLeafArray(balanceLeafHashArray)
const balanceRoot = merkle.rootFromLeafArray(balanceLeafHashArray)

// generate tx's: 
// 1. Alice --500--> Bob , 
// 2. Bob --500--> withdraw,
// 3. Alice --500--> Charlie,
// 4. Charlie --250--> Bob

from_accounts_idx = [1, 2, 1, 3]
from_accounts = new Array(from_accounts_idx.length)
for (i = 0; i < from_accounts_idx.length; i++){
    from_accounts[i] = pubKeys[from_accounts_idx[i]]
}

to_accounts_idx = [2, 0, 3, 2]
to_accounts = new Array(from_accounts_idx.length)
for (i = 0; i < to_accounts_idx.length; i++){
    to_accounts[i] = pubKeys[to_accounts_idx[i]]
}

from_x = account.getPubKeysX(from_accounts)
from_y = account.getPubKeysY(from_accounts)
to_x = account.getPubKeysX(to_accounts)
to_y = account.getPubKeysY(to_accounts)
const amounts = [500, 500, 500, 250]
const tx_token_types = [10, 10, 10, 10]

const txArray = txLeaf.generateTxLeafArray(
    from_x, from_y, to_x, to_y, amounts, tx_token_types
)

const txLeafHashes = txLeaf.hashTxLeafArray(txArray)
const txTree = merkle.treeFromLeafArray(txLeafArray)
const txRoot = merkle.rootFromLeafArray(txLeafArray)

const txPos = merkle.generateMerklePosArray(0, 2**TX_DEPTH, TX_DEPTH)
const txProofs = new Array(2**TX_DEPTH)
for (jj = 0; jj < 2**TX_DEPTH; jj++){
    txProofs[jj] = merkle.getProof(jj, txTree, txLeafArray)
}

const signature = eddsa.signMiMC(prvKeys[0], txLeafHashes[0]);
console.log(update.getNewRoot(txArray[0], 1, 2, signature, balanceLeafArray))


// const inputs = {
//     tx_root: txRoot.toString(),
  
//     paths2tx_root: txProofs,
  
//     paths2tx_root_pos: txPos,
  
//     current_state: balanceRoot,

//     intermediate_roots: [0,0,0,0],

//     paths2old_root_from: [zero_leaf_hash.toString(),0,0,0,0],
//     paths2old_root_to: [alice_leaf_hash.toString(),0,0,0,0],
//     paths2new_root_from: [new_zero_leaf_hash.toString(),0,0,0,0],
//     paths2new_root_to: [new_alice_leaf_hash.toString(),0,0,0,0],

//     paths2root_from_pos: balance_pos_alice,
//     paths2root_to_pos: balance_pos_zero,
  
//     from_x: account.getPubKeysX(pubKeys).toString(),
//     from_y: account.getPubKeysY(pubKeys).toString(),
//     R8x: signature.R8[0].toString(),
//     R8y: signature.R8[1].toString(),
//     S: signature.S.toString(),
  
//     nonce_from: [0,0,0,0],
//     to_x: [],
//     to_y: [],
//     nonce_to: [0,0,0,0],
//     amount: [500, 500, 0, 0],
  
//     token_balance_from: [1000, 500, 0, 0],
//     token_balance_to: [0, 0, 0, 0],
//     token_type_from: [10, 0, 0, 0],
//     token_type_to: [10, 10, 0, 0]
// }
  
//   fs.writeFileSync(
//     "./input.json",
//     JSON.stringify(inputs),
//     "utf-8"
//   );
