const eddsa = require("../circomlib/src/eddsa.js");
const fs = require("fs");
const Account = require("../src/account.js");
const AccountTree = require("../src/accountTree.js");
const Transaction = require("../src/transaction.js");
const TxTree = require("../src/txTree.js");
const treeHelper = require("../src/treeHelper.js");
const getCircuitInput = require("../src/circuitInput.js");

const TX_DEPTH = 2
const BAL_DEPTH = 4

// get empty account tree hashes

const zeroAccount = new Account();
accounts = [zeroAccount];

function generatePrvkey(i){
    prvKey = Buffer.from(i.toString().padStart(64,'0'), "hex");
    return prvKey;  
}

function generatePubkey(prvkey){
    pubkey = eddsa.prv2pub(prvkey);
    return pubkey; 
}

const coordinatorPrvkey = generatePrvkey(1);
const coordinatorPubkey = generatePubkey(coordinatorPrvkey);
const coordinator = new Account(
    1, coordinatorPubkey[0], coordinatorPubkey[1],
    0, 0, 0, coordinatorPrvkey
);

accounts.push(coordinator);

// generate A, B, C, D, E, F accounts

const numAccounts = 6;
const tokenTypes = [2, 1, 2, 1, 2, 1];
const balances = [1000, 20, 200, 100, 500, 20];
const nonces = [0, 0, 0, 0, 0, 0];

for (var i = 0; i < numAccounts; i++){
    prvkey = generatePrvkey(i + 2);
    pubkey = generatePubkey(prvkey);
    account = new Account(
        i + 2, // index
        pubkey[0], // pubkey x coordinate
        pubkey[1], // pubkey y coordinate
        balances[i], // balance
        nonces[i], // nonce
        tokenTypes[i], // tokenType,
        prvkey 
    )
    accounts.push(account);
}

const first4Accounts = accounts.slice(0,4)
const first4Subtree = new AccountTree(first4Accounts)
const first4SubtreeRoot = first4Subtree.root

const first8Accounts = accounts.slice(0,8)
const first8Subtree = new AccountTree(first8Accounts)
const first8SubtreeRoot = first8Subtree.root

const paddedTo16Accounts = treeHelper.padArray(accounts, zeroAccount, 8)
const accountTree = new AccountTree(paddedTo16Accounts)
const root = accountTree.root

// generate tx's: 
// 1. Alice --500--> Charlie , 
// 2. Charlie --200--> withdraw,
// 3. Bob --10--> Daenerys,
// 4. empty tx (operator --0--> withdraw)

fromAccountsIdx = [2, 4, 3, 1]
toAccountsIdx = [4, 0, 5, 0]

const amounts = [500, 200, 10, 0]
const txTokenTypes = [2, 2, 1, 0]
const txNonces = [0, 0, 0, 0]

var txs = new Array(TX_DEPTH ** 2)

for (var i = 0; i < txs.length; i++){
    fromAccount = paddedTo16Accounts[fromAccountsIdx[i]];
    toAccount = paddedTo16Accounts[toAccountsIdx[i]];
    tx = new Transaction(
        fromAccount.pubkeyX,
        fromAccount.pubkeyY,
        toAccount.pubkeyX,
        toAccount.pubkeyY,
        txNonces[i],
        amounts[i],
        txTokenTypes[i]
    );
    tx.hashTx();
    tx.signTxHash(fromAccount.prvKey);
    txs[i] = tx;
}

const txTree = new TxTree(txs);

const stateTransition = accountTree.processTxArray(txTree);
const inputs = getCircuitInput(stateTransition);

fs.writeFileSync(
    "../build/test_1_update_input_refactored.json",
    JSON.stringify(inputs),
    "utf-8"
);
