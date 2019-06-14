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
const {stringifyBigInts, unstringifyBigInts} = require("../utils/stringifybigint.js")

const TX_DEPTH = 2;
const BAL_DEPTH = 16;
const BAL_LEAF_NUM = 2**BAL_DEPTH

const zeroLeaf = balanceLeaf.zeroLeaf()
const zeroLeafHash = balanceLeaf.hashBalanceLeafArray([zeroLeaf])[0]

const zeroCache = new Array(BAL_DEPTH)

zeroCache[0] = zeroLeafHash
for (i = 1; i < BAL_DEPTH; i++){
    zeroCache[i] = mimcjs.multiHash([zeroCache[i-1],zeroCache[i-1]])
}
console.log(zeroCache)

// console.log(
//     merkle.rootFromLeafAndPath(zeroLeafHash,0,[zeroCache[0],zeroCache[1]])
// )
