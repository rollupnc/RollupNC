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

const TX_DEPTH = 4;
const DEPTH = 6;

// let's do two transfers and a withdraw :-)

// generate zero account with the following parameters
const zero_address = account.zeroAddress();
const zero_token_type = 0;
const zero_balance = 0;
const zero_nonce = 0; 

// initialise Alice, Bob, Charlie accounts
const prvKeys = account.generatePrvKeys(3);
const pubKeys = account.generatePubKeys(prvKeys);
const pubKeysX = account.getPubKeysX(pubKeys);
const pubKeysY = account.getPubKeysY(pubKeys);

const tokenTypes = [10,10,10];
const balances = [1000,1000,0];
const nonces = [0,0,0];

const accounts = balanceLeaf.generateBalanceLeaf(
    pubKeysX, pubKeysY, tokenTypes, balances, nonces
);

const balancePos = merkle.generateMerklePos(0,4, DEPTH-1)

// Alice -> Bob 500
// Bob -> Charlie 1000
// Charlie withdraws 1000
const transactions = txLeaf.generateTxLeaf(
    pubKeysX, pubKeysY, 
    [pubKeysX[1], pubKeysX[2], zero_address[0]],
    [pubKeysY[1], pubKeysY[2], zero_address[1]],
    [500,1000,1000],
    [10,10,10]
)

const signatures = [
    eddsa.signMiMC(prvKeys[0], transactions[0]),
    eddsa.signMiMC(prvKeys[1], transactions[1]),
    eddsa.signMiMC(prvKeys[2], transactions[2])
]

const txArray = Array(2**TX_DEPTH).fill(0)
for (i = 0; i < transactions.length; i++){
    txArray[i] = transactions[i]
}

const txRoot = merkle.rootFromLeafArray(txArray)

const txPos = merkle.generateMerklePos(0,3, TX_DEPTH-1)

// process first transaction



// process second transaction

// process third transaction


// const new_hash_leaf_from = mimcjs.multiHash([
//   pubKey_from[0],
//   pubKey_from[1],
//   token_balance_from - amount,
//   nonce_from + 1,
//   token_type_from
// ]);
// const new_hash_leaf_to = mimcjs.multiHash([
//   pubKey_to[0],
//   pubKey_to[1],
//   token_balance_to + amount,
//   nonce_to,
//   token_type_to
// ]);

// var new_merkle = new Array(DEPTH - 1);
// new_merkle[0] = mimcjs.multiHash([new_hash_leaf_from, new_hash_leaf_to]);
// var i;
// for (i = 1; i < DEPTH - 1; i++) {
//   new_merkle[i] = mimcjs.multiHash([new_merkle[i - 1], 0]);
// }

// console.log("Updated Root");
// console.log(new_merkle[DEPTH - 2]);

// const inputs = {
//   tx_root: tx_root[TX_DEPTH - 2].toString(),

//   paths2tx_root: [0, 0, 0],

//   paths2tx_root_pos: [0, 0, 0],

//   current_state: old_merkle[DEPTH - 2].toString(),

//   paths2old_root_from: [old_hash_leaf_to.toString(), 0, 0, 0, 0],
//   paths2old_root_to: [old_hash_leaf_from.toString(), 0, 0, 0, 0],
//   paths2new_root_from: [new_hash_leaf_to.toString(), 0, 0, 0, 0],
//   paths2new_root_to: [new_hash_leaf_from.toString(), 0, 0, 0, 0],

//   paths2root_from_pos: [0, 0, 0, 0, 0],
//   paths2root_to_pos: [1, 0, 0, 0, 0],

//   from_x: pubKey_from[0].toString(),
//   from_y: pubKey_from[1].toString(),
//   R8x: signature.R8[0].toString(),
//   R8y: signature.R8[1].toString(),
//   S: signature.S.toString(),

//   nonce_from: nonce_from.toString(),
//   to_x: pubKey_to[0].toString(),
//   to_y: pubKey_to[1].toString(),
//   nonce_to: nonce_to.toString(),
//   amount: amount.toString(),

//   token_balance_from: token_balance_from.toString(),
//   token_balance_to: token_balance_to.toString(),
//   token_type_from: token_type_from.toString(),
//   token_type_to: token_type_to.toString()
// };

// fs.writeFileSync(
//   "./input.json",
//   JSON.stringify(inputs),
//   "utf-8"
// );
