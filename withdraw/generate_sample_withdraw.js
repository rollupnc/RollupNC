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
const BAL_DEPTH = 6;

// generate zero account with the following parameters
const zero_address = account.zeroAddress();
const zero_token_type = 0;
const zero_balance = 0;
const zero_nonce = 0;  

// generate balance leaf for zero account
const zero_leaf = balanceLeaf.generateBalanceLeaf(
    account.getPubKeysX(zero_address),
    account.getPubKeysY(zero_address),
    zero_token_type, zero_balance, zero_nonce
)

// generate Alice account with the following parameters
const num_accts = 1; //can generate more than 1 acct at a time!
const prvKeys = account.generatePrvKeys(num_accts);
const pubKeys = account.generatePubKeys(prvKeys);
const token_types = [10];
const balances = [1000];
const nonces = [0];

// generate balance leaves for user accounts
const alice_leaf = balanceLeaf.generateBalanceLeaf(
    account.getPubKeysX(pubKeys),
    account.getPubKeysY(pubKeys),
    token_types, balances, nonces
)

// Alice signs old leaf
const signature = eddsa.signMiMC(prvKeys, alice_leaf);

// generate balance tree
console.log("The zero account is permanently at the zero index of the balance tree.")
const balance_path_zero = [alice_leaf,0,0,0,0]
const balance_pos_zero = [0,0,0,0,0]

console.log("Alice's account is at index 1 of the balance tree.") 
const balance_path_alice = [zero_leaf,0,0,0,0]
const balance_pos_alice = [1,0,0,0,0]

const balance_root_zero = merkle.rootFromLeafAndPath(
    BAL_DEPTH, zero_leaf, balance_path_zero, balance_pos_zero
) 
const balance_root_alice = merkle.rootFromLeafAndPath(
    BAL_DEPTH, alice_leaf, balance_path_alice, balance_pos_alice
)
console.log("balance root: ", balance_root_zero)
console.log("balance root: ", balance_root_alice)

// transfer from Alice account to zero address (withdraw)
const alice = pubKeys;
const transfer_from = alice;
const transfer_to = zero_address;
const transfer_amt = 1000;
const transfer_type = 10;

// generate tx leaf for withdraw
const withdrawTxLeaf = txLeaf.generateTxLeaf(
    account.getPubKeysX(transfer_from), account.getPubKeysY(transfer_from),
    account.getPubKeysX(transfer_to), account.getPubKeysY(transfer_to),
    transfer_amt, transfer_type
)

const tx_path = [0,0,0];
const tx_pos = [0,0,0];

// generate tx tree and root
var tx_root = merkle.rootFromLeafAndPath(
    TX_DEPTH, withdrawTxLeaf, tx_path, tx_pos);
console.log("transactions tree root: ", tx_root)

// new zero leaf is the same as old zero leaf

// new Alice leaf
const new_alice_leaf = balanceLeaf.generateBalanceLeaf(
    account.getPubKeysX(pubKeys),
    account.getPubKeysY(pubKeys),
    token_types, balances[0] - transfer_amt, nonces[0] + 1
)

// generate new balance tree
console.log("The zero account is permanently at the zero index of the balance tree.")
const new_balance_path_zero = [new_alice_leaf,0,0,0,0]

console.log("Alice's account is at index 1 of the balance tree.") 
const new_balance_path_alice = [zero_leaf,0,0,0,0]

const new_balance_root_zero = merkle.rootFromLeafAndPath(
    BAL_DEPTH, zero_leaf, new_balance_path_zero, balance_pos_zero
) 
const new_balance_root_alice = merkle.rootFromLeafAndPath(
    BAL_DEPTH, new_alice_leaf, new_balance_path_alice, balance_pos_alice
)
console.log("new balance root: ", new_balance_root_zero)
console.log("new balance root: ", new_balance_root_alice)

const inputs = {
    tx_root: tx_root.toString(),
  
    paths2tx_root: [0, 0, 0],
  
    paths2tx_root_pos: [0, 0, 0],
  
    current_state: balance_root_alice.toString(),
  
    // paths2old_root_from: balance_path_alice.toString(),
    // paths2old_root_to: balance_path_zero.toString(),
    // paths2new_root_from: new_balance_path_alice.toString(),
    // paths2new_root_to: new_balance_path_zero.toString(),
  
    paths2old_root_from: [zero_leaf.toString(),0,0,0,0],
    paths2old_root_to: [alice_leaf.toString(),0,0,0,0],
    paths2new_root_from: [zero_leaf.toString(),0,0,0,0],
    paths2new_root_to: [new_alice_leaf.toString(),0,0,0,0],

    paths2root_from_pos: balance_pos_alice,
    paths2root_to_pos: balance_pos_zero,
  
    from_x: account.getPubKeysX(pubKeys).toString(),
    from_y: account.getPubKeysY(pubKeys).toString(),
    R8x: signature.R8[0].toString(),
    R8y: signature.R8[1].toString(),
    S: signature.S.toString(),
  
    nonce_from: nonces[0].toString(),
    to_x: account.getPubKeysX(zero_address).toString(),
    to_y: account.getPubKeysY(zero_address).toString(),
    nonce_to: zero_nonce.toString(),
    amount: transfer_amt.toString(),
  
    token_balance_from: balances[0].toString(),
    token_balance_to: zero_balance.toString(),
    token_type_from: token_types[0].toString(),
    token_type_to: zero_token_type.toString()
  };
  
  fs.writeFileSync(
    "./input.json",
    JSON.stringify(inputs),
    "utf-8"
  );

//Ethereum address to claim withdrawal from smart contract
const recipient_address = "0xb16c0a1ed2d7275286d795b648befed94902142a";
const tx_leaf = withdrawTxLeaf.toString();
const data = [recipient_address, tx_leaf];
const msgHash = mimcjs.multiHash(data);
const signature2 = eddsa.signMiMC(prvKeys, msgHash)
const contractInputs = {
    msgHash: msgHash.toString(),
    R8x: signature2.R8[0].toString(),
    R8y: signature2.R8[1].toString(),
    S: signature2.S.toString(),
}

fs.writeFileSync(
    "./contractInput.json",
    JSON.stringify(contractInputs),
    "utf-8"
  );