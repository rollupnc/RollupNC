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

const TX_DEPTH = 4;
const BAL_DEPTH = 6;

// generate zero leaf
const zeroAddress = account.zeroAddress()
const zero_leaf = balanceLeaf.getZeroLeaf()
const zeroLeafHash = balanceLeaf.hashBalanceLeafArray([zero_leaf])[0]

// generate Alice account with the following parameters
const prvKeys = account.generatePrvKeys(1);
const pubKeys = account.generatePubKeys(prvKeys);
const pubKeysX = account.getPubKeysX(pubKeys);
const pubKeysY = account.getPubKeysY(pubKeys);

const tokenTypes = [10]; //each account's token type
const balances = [1000]; // Alice 1000
const nonces = [0]; //initialise each account to 0 nonce

const balanceLeaves = balanceLeaf.generateBalanceLeafArray(
    pubKeysX, pubKeysY, tokenTypes, balances, nonces
);

const balanceLeafHashes = balanceLeaf.hashBalanceLeafArray(balanceLeaves)

const balanceArray = Array(2**BAL_DEPTH).fill(0)
balanceArray[0] = zeroLeafHash
for (i = 1; i <= balanceLeafHashes.length; i++){
    balanceArray[i] = balanceLeafHashes[i - 1]
}

const balancePos = merkle.generateMerklePos(0,2, BAL_DEPTH-1)

// generate balance tree
console.log("The zero account is permanently at the zero index of the balance tree.")
const balance_path_zero = [balanceArray[1],0,0,0,0]
const balance_pos_zero = balancePos[0]

console.log("Alice's account is at index 1 of the balance tree.") 
const balance_path_alice = [balanceArray[0],0,0,0,0]
const balance_pos_alice = balancePos[1]

const balance_root_zero = merkle.rootFromLeafAndPath(
    BAL_DEPTH, balanceArray[0], balance_path_zero, balance_pos_zero
) 
const balance_root_alice = merkle.rootFromLeafAndPath(
    BAL_DEPTH, balanceArray[1], balance_path_alice, balance_pos_alice
)

// Alice withdraws 1000
const transactions = txLeaf.generateTxLeafArray(
    pubKeysX, pubKeysY, // from_x, from_y
    [zeroAddress[0]], //to_x
    [zeroAddress[1]], //to_y
    [1000],
    [10]
)

const txHashes = txLeaf.hashTxLeafArray(transactions)
const signatures = [
    eddsa.signMiMC(prvKeys[0], txHashes[0])
]

// Merkle path and position in tx tree
const tx_path = [0,0,0];
const tx_pos = merkle.generateMerklePos(0,1, TX_DEPTH-1)

// generate tx tree and root
var tx_root = merkle.rootFromLeafAndPath(
    TX_DEPTH, txHashes[0], tx_path, tx_pos[0]);

// process Alice withdraw
var [new_alice_leaf, new_zero_leaf] = update.processTx(
    transactions[0], 
    balanceLeaves[0],
    zero_leaf,
    signatures[0])

// update balance array
const newBalanceArray = Array(2**BAL_DEPTH).fill(0)
newBalanceArray[0] = balanceLeaf.hashBalanceLeafArray([new_zero_leaf])[0]
newBalanceArray[1] = balanceLeaf.hashBalanceLeafArray([new_alice_leaf])[0]

// generate new balance tree
console.log("The zero account is permanently at the zero index of the balance tree.")
const new_balance_path_zero = [newBalanceArray[1],0,0,0,0]

console.log("Alice's account is at index 1 of the balance tree.") 
const new_balance_path_alice = [newBalanceArray[0],0,0,0,0]

const new_balance_root_zero = merkle.rootFromLeafAndPath(
    BAL_DEPTH, newBalanceArray[0], new_balance_path_zero, balance_pos_zero
) 
const new_balance_root_alice = merkle.rootFromLeafAndPath(
    BAL_DEPTH, newBalanceArray[1], new_balance_path_alice, balance_pos_alice
)


const inputs = {
    tx_root: tx_root.toString(),
  
    paths2tx_root: [0, 0, 0],
  
    paths2tx_root_pos: [0, 0, 0],
  
    current_state: balance_root_alice.toString(),

    paths2old_root_from: [balanceArray[0].toString(),0,0,0,0],
    paths2old_root_to: [balanceArray[1].toString(),0,0,0,0],
    paths2new_root_from: [newBalanceArray[0].toString(),0,0,0,0],
    paths2new_root_to: [newBalanceArray[1].toString(),0,0,0,0],

    paths2root_from_pos: balance_pos_alice,
    paths2root_to_pos: balance_pos_zero,
  
    from_x: pubKeysX[0].toString(),
    from_y: pubKeysY[0].toString(),
    R8x: signatures[0].R8[0].toString(),
    R8y: signatures[0].R8[1].toString(),
    S: signatures[0].S.toString(),
  
    nonce_from: nonces[0].toString(),
    to_x: zeroAddress[0].toString(),
    to_y: zeroAddress[1].toString(),
    nonce_to: zero_leaf['nonce'].toString(),
    amount: "1000",
  
    token_balance_from: balances[0].toString(),
    token_balance_to: zero_leaf['balance'].toString(),
    token_type_from: "10",
    token_type_to: zero_leaf['token_type'].toString()
  };
  
  fs.writeFileSync(
    "./input.json",
    JSON.stringify(inputs),
    "utf-8"
  );

// //Ethereum address to claim withdrawal from smart contract
// const recipient_address = "0xb16c0a1ed2d7275286d795b648befed94902142a";
// const tx_leaf = withdrawTxLeaf.toString();
// const data = [recipient_address, tx_leaf];
// const msgHash = mimcjs.multiHash(data);
// const signature2 = eddsa.signMiMC(prvKeys, msgHash)
// const contractInputs = {
//     msgHash: msgHash.toString(),
//     R8x: signature2.R8[0].toString(),
//     R8y: signature2.R8[1].toString(),
//     S: signature2.S.toString(),
// }

// fs.writeFileSync(
//     "./contractInput2.json",
//     JSON.stringify(contractInputs),
//     "utf-8"
//   );