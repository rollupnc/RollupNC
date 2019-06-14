const snarkjs = require("snarkjs");
const fs = require("fs");
const account = require("../utils/generate_accounts.js");
const balanceLeaf = require("../utils/generate_balance_leaf.js");
const txLeaf = require("../utils/generate_tx_leaf.js");
const merkle = require("../utils/MiMCMerkle.js")
const update = require("../utils/update.js")

const TX_DEPTH = 3; //2**3 transactions
const BAL_SUB_DEPTH = 4; //2**4 accounts per subtree
const BAL_DEPTH = 6; //2**6 subtrees

// generate zero, Alice, Bob, Charlie, Daenerys accounts with the following parameters
const num_accts = 5;
const prvKeys = account.generatePrvKeys(num_accts);
const zeroPubKey = account.zeroAddress()
const pubKeys = account.generatePubKeys(prvKeys);
pubKeys.unshift(zeroPubKey)
const token_types = [0, 2, 1, 2, 1];
const balances = [0, 1000, 20, 200, 100];
const nonces = [0, 0, 0, 0, 0];

// generate balance leaves for user accounts
const balanceLeafArray = balanceLeaf.generateBalanceLeafArray(
    account.getPubKeysX(pubKeys),
    account.getPubKeysY(pubKeys),
    token_types, balances, nonces
)

// generate tx's: 
// 1. Alice --500--> Charlie , 
// 2. Charlie --200--> withdraw,
// 3. Alice --500--> withdraw,
// 4. Charlie --500--> Alice
// 5. Daenerys --50--> Bob , 
// 6. Bob --10--> withdraw,
// 7. Bob --10--> Daenerys,
// 8. Daenerys --50--> withdraw

from_accounts_idx = [1, 3, 1, 3, 4, 2, 2, 4]
from_accounts = update.pickByIndices(pubKeys, from_accounts_idx)

to_accounts_idx = [3, 0, 0, 1, 2, 0, 4, 0]
to_accounts = update.pickByIndices(pubKeys, to_accounts_idx)

from_x = account.getPubKeysX(from_accounts)
from_y = account.getPubKeysY(from_accounts)
to_x = account.getPubKeysX(to_accounts)
to_y = account.getPubKeysY(to_accounts)
const amounts = [500, 200, 500, 500, 50, 10, 10, 50]
const tx_token_types = [2, 2, 2 ,2 ,1 ,1, 1, 1]

const txArray = txLeaf.generateTxLeafArray(
    from_x, from_y, to_x, to_y, amounts, tx_token_types
)

const txLeafHashes = txLeaf.hashTxLeafArray(txArray)

const txTree = merkle.treeFromLeafArray(txLeafHashes)

// const txRoot = merkle.rootFromLeafArray(txLeafHashes)

// const txPos = merkle.generateMerklePosArray(TX_DEPTH)
const txProofs = new Array(2**TX_DEPTH)
for (jj = 0; jj < 2**TX_DEPTH; jj++){
    txProofs[jj] = merkle.getProof(jj, txTree, txLeafHashes)
}

const signatures = txLeaf.signTxLeafHashArray(
    txLeafHashes, 
    [prvKeys[0], prvKeys[1], prvKeys[0], prvKeys[2]]
)

console.log(signatures)

const inputs = update.processTxArray(
    TX_DEPTH,
    pubKeys,
    balanceLeafArray,
    from_accounts_idx,
    to_accounts_idx,
    amounts,
    tx_token_types,
    signatures
)

console.log(inputs)

fs.writeFileSync(
    "./input.json",
    JSON.stringify(inputs),
    "utf-8"
);
