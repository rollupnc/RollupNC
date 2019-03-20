const eddsa = require("./src/eddsa.js");
const snarkjs = require("snarkjs");
const fs = require("fs");
const util = require("util");
const mimcjs = require("./src/mimc7.js");

const bigInt = snarkjs.bigInt;

const DEPTH = 24;
const msg = bigInt(9999);

const prvKey = Buffer.from(
  "0000000000000000000000000000000000000000000000000000000000000001",
  "hex"
);

const pubKey = eddsa.prv2pub(prvKey);
const nonce = 0;
const old_hash = mimcjs.multiHash([pubKey[0], pubKey[1], nonce]);

var old_merkle = new Array(DEPTH - 1);
old_merkle[0] = mimcjs.multiHash([old_hash, 0]);
var i;
for (i = 1; i < DEPTH - 1; i++) {
  old_merkle[i] = mimcjs.multiHash([old_merkle[i - 1], 0]);
}
console.log("Old Root");
console.log(old_merkle[DEPTH - 2]);

const signature = eddsa.signMiMC(prvKey, old_hash);

const inputs = {
  current_state: old_merkle[DEPTH - 2].toString(),
  paths_to_root: [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  ],
  pubkey_x: pubKey[0].toString(),
  pubkey_y: pubKey[1].toString(),
  R8x: signature.R8[0].toString(),
  R8y: signature.R8[1].toString(),
  S: signature.S.toString(),
  nonce: 0
};

console.log(inputs);

fs.writeFileSync("./leaf_update_input.json", JSON.stringify(inputs), "utf-8");

const new_hash = mimcjs.multiHash([pubKey[0], pubKey[1], nonce + 1]);

var new_merkle = new Array(DEPTH - 1);
new_merkle[0] = mimcjs.multiHash([new_hash, 0]);
var i;
for (i = 1; i < DEPTH - 1; i++) {
  new_merkle[i] = mimcjs.multiHash([new_merkle[i - 1], 0]);
}
console.log("New Root");
console.log(new_merkle[DEPTH - 2]);
