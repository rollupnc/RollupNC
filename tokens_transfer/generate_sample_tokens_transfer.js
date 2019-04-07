const eddsa = require("../circomlib/src/eddsa.js");
const snarkjs = require("snarkjs");
const fs = require("fs");
const util = require("util");
const mimcjs = require("../circomlib/src/mimc7.js");

const bigInt = snarkjs.bigInt;

const TX_DEPTH = 4;
const DEPTH = 6;

const prvKey_from = Buffer.from(
  "0000000000000000000000000000000000000000000000000000000000000001",
  "hex"
);
const prvKey_to = Buffer.from(
  "0000000000000000000000000000000000000000000000000000000000000002",
  "hex"
);

const pubKey_from = eddsa.prv2pub(prvKey_from);
const pubKey_to = eddsa.prv2pub(prvKey_to);

const nonce_from = 0;
const nonce_to = 0;

const token_type_from = 10;
const token_balance_from = 1000;
const token_type_to = 10;
const token_balance_to = 2000;
const amount = 100;

const tx_leaf = mimcjs.multiHash([
  pubKey_from[0],
  pubKey_from[1],
  pubKey_to[0],
  pubKey_to[1],
  amount,
  token_type_from
]);

const old_hash_leaf_from = mimcjs.multiHash([
  pubKey_from[0],
  pubKey_from[1],
  token_balance_from,
  nonce_from,
  token_type_from
]);
const old_hash_leaf_to = mimcjs.multiHash([
  pubKey_to[0],
  pubKey_to[1],
  token_balance_to,
  nonce_to,
  token_type_to
]);

console.log(
  "We placed the transaction at index 0 of the Transaction Merkle Tree"
);
var tx_root = new Array(TX_DEPTH -1);
tx_root[0] = mimcjs.multiHash([tx_leaf,0]);

var i;
for (i = 1; i < TX_DEPTH - 1; i++) {
  tx_root[i] = mimcjs.multiHash([tx_root[i-1], 0]);
}

console.log("Transaction root");
console.log(tx_root[TX_DEPTH -2]);

console.log(
  "We selected to place account 1 and 2 at index 0 and 1 of the Merkle Tree"
);
var old_merkle = new Array(DEPTH - 1);
old_merkle[0] = mimcjs.multiHash([old_hash_leaf_from, old_hash_leaf_to]);

var i;
for (i = 1; i < DEPTH - 1; i++) {
  old_merkle[i] = mimcjs.multiHash([old_merkle[i - 1], 0]);
}

console.log("Initial Root");
console.log(old_merkle[DEPTH - 2]);

const signature = eddsa.signMiMC(prvKey_from, old_hash_leaf_from);

const new_hash_leaf_from = mimcjs.multiHash([
  pubKey_from[0],
  pubKey_from[1],
  token_balance_from - amount,
  nonce_from + 1,
  token_type_from
]);
const new_hash_leaf_to = mimcjs.multiHash([
  pubKey_to[0],
  pubKey_to[1],
  token_balance_to + amount,
  nonce_to,
  token_type_to
]);

var new_merkle = new Array(DEPTH - 1);
new_merkle[0] = mimcjs.multiHash([new_hash_leaf_from, new_hash_leaf_to]);
var i;
for (i = 1; i < DEPTH - 1; i++) {
  new_merkle[i] = mimcjs.multiHash([new_merkle[i - 1], 0]);
}

console.log("Updated Root");
console.log(new_merkle[DEPTH - 2]);

const inputs = {
  tx_root: tx_root[TX_DEPTH - 2].toString(),

  paths2tx_root: [0, 0, 0],

  paths2tx_root_pos: [0, 0, 0],

  current_state: old_merkle[DEPTH - 2].toString(),

  paths2old_root_from: [old_hash_leaf_to.toString(), 0, 0, 0, 0],
  paths2old_root_to: [old_hash_leaf_from.toString(), 0, 0, 0, 0],
  paths2new_root_from: [new_hash_leaf_to.toString(), 0, 0, 0, 0],
  paths2new_root_to: [new_hash_leaf_from.toString(), 0, 0, 0, 0],

  paths2root_from_pos: [0, 0, 0, 0, 0],
  paths2root_to_pos: [1, 0, 0, 0, 0],

  from_x: pubKey_from[0].toString(),
  from_y: pubKey_from[1].toString(),
  R8x: signature.R8[0].toString(),
  R8y: signature.R8[1].toString(),
  S: signature.S.toString(),

  nonce_from: nonce_from.toString(),
  to_x: pubKey_to[0].toString(),
  to_y: pubKey_to[1].toString(),
  nonce_to: nonce_to.toString(),
  amount: amount.toString(),

  token_balance_from: token_balance_from.toString(),
  token_balance_to: token_balance_to.toString(),
  token_type_from: token_type_from.toString(),
  token_type_to: token_type_to.toString()
};

fs.writeFileSync(
  "./input.json",
  JSON.stringify(inputs),
  "utf-8"
);
