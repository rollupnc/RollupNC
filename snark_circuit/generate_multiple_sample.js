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

// generate tx's: 
// 1. Alice --500--> Bob , 
// 2. Bob --500--> withdraw,
// 3. Alice --500--> Charlie,
// 4. Charlie --250--> Bob

from_accounts_idx = [1, 2, 1, 3]
from_accounts = update.pickByIndices(pubKeys, from_accounts_idx)

to_accounts_idx = [2, 0, 3, 2]
to_accounts = update.pickByIndices(pubKeys, to_accounts_idx)

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
const txTree = merkle.treeFromLeafArray(txLeafHashes)

const txRoot = merkle.rootFromLeafArray(txLeafHashes)

// const txPos = merkle.generateMerklePosArray(TX_DEPTH)
const txProofs = new Array(2**TX_DEPTH)
for (jj = 0; jj < 2**TX_DEPTH; jj++){
    txProofs[jj] = merkle.getProof(jj, txTree, txLeafHashes)
}

const signatures = txLeaf.signTxLeafHashArray(
    txLeafHashes, 
    [prvKeys[0], prvKeys[1], prvKeys[0], prvKeys[2]]
)

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


fs.writeFileSync(
    "./input.json",
    JSON.stringify(inputs),
    "utf-8"
);
