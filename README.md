# RollupNC (Rollup non-custodial)

![](https://i.imgur.com/ZXVs8IP.png)

SNARKs can make succinct proofs for large computations, meaning that these proofs are much faster and computationally easier to verify than they are to compute. Thus, we can "compress" expensive operations by computing them off-chain in a SNARK, and then only verifying the proof on-chain.

RollupNC is an implementation of [rollup](https://github.com/barryWhiteHat/roll_up) in which the relayer **does not** publish transaction data to the main chain, but only publishes the new Merkle root at every update. This provides gas savings but not data availability guarantees: we assume the operator will always provide data to users so they can update their leaf.

NB: it is trivial to change this implementation back to the original rollup, since it simply involves switching the `private` circuit inputs to `public`. 

## Building this repo

1. Install node version 10.16.0, possibly using [nvm](https://github.com/nvm-sh/nvm)
2. Install truffle and ganache-cli
bash
$ npm install -g truffle ganache-cli
3. Install submodules: use `git submodule update --init --recursive` to clone `circomlib` submodule
4. Install npm modules in both root directory and circomlib submodule
5. [Check out this circom intro](https://github.com/iden3/circom/blob/master/TUTORIAL.md)

## Spec

### Parameters
- `bal_depth`: depth of balance Merkle tree
- `tx_depth`: depth of transaction Merkle tree

### Data structures

#### EdDSA

```
eddsa_prvKey: string //"biginteger"
```

```js
class eddsa_pubKey = {
  X: string // "biginteger",
  Y: string // "biginteger"
}
```

```js
class eddsa_signature = {
  R8: string[2] // "biginteger",
  S: string // "biginteger"
}
```
#### Account
```js
class Account = {
  pubKey: eddsa_pubKey,
  balance: integer,
  nonce: integer,
  token_type: integer
}
```
The **Accounts Merkle tree** has depth `bal_depth` and `2^bal_depth` accounts as its leaves. The first leaf (index `0`) is reserved as the `zero_leaf`. Transactions made to the `zero_leaf` are considered `withdraw`s. The second leaf (index `1`) is reserved as a known operator leaf. This account can be used to make zero transactions when we need to pad inputs to the circuit.

For convenience, we also cache the empty accounts tree when initialising rollupNC.
```
zeroCache = string[bal_depth] //"biginteger"

```

#### Transfer
```js
class Transfer = {
  from: eddsa_pubKey,
  to: eddsa_pubKey,
  amount: integer,
  nonce: integer,
  token_type: integer
}
```
TODO: implement atomic swaps and fees fields in `Transfer` object

For each SNARK, we construct a **Transactions Merkle tree**, whose leaves are the transactions processed by the SNARK. 

## User
The user sends `deposit` and `withdraw` transactions directly to the smart contract, and all other normal transactions to the off-chain coordinator. 

### Deposits
1. User deposits into smart contract

  - increment `deposit_queue_number` (global variable in smart contract)

  - push deposit to deposits_array
  ```
  deposits_array = []
  deposits_array = [A] // Alice deposits, pushed to deposits_array
  deposits_array = [A, B] // Bob deposits, pushed to deposits_array
  ```

  - hash deposit array into on-chain Merkle root, `deposit_root`
  
  ```
  deposits_array = [hash(A, B)] // Bob hashes Alice's deposit and his own
  deposits_array = [hash(A, B), C] // Charlie deposits, pushed to deposits_array
  deposits_array = [hash(A, B), C, D] // Daenerys deposits
  deposits_array = [hash(A, B), hash(C, D)] // Daenerys hashes Charlie's deposit and her own
  deposits_array = [hash(A, B, C, D)] // Daenerys hashes H(A,B) and H(C,D)

  ```
  Notice that the number of times a user has to hash `deposits_array` is equal to the number of times her `deposit_queue_number` can be divided by 2. Also, the first element of `deposits_array` is the tallest subtree at any given point.

2. Coordinator inserts deposit root into balance tree at `deposit_root.height`

  - **prove that balance tree was empty at `deposit_root.height`**: provide `deposit_proof` to smart contract, a Merkle proof showing inclusion of an empty node at `deposit_tree.height` (`zeroCache[deposit_tree.height]`) in the current state root

  - **update balance root on-chain**: using same `deposit_proof`, update the balance root replacing the empty node with the first element of `deposits_array` 

### Transactions

1. User constructs `Transaction` object

2. User hashes `Transaction` object
Use `multiHash` in https://github.com/iden3/circomlib/blob/master/src/mimc7.js#L47.

```js
txHash = multiHash([from, to, amount, nonce, token_type]) //"biginteger"
```

3. User signs hash of `Transaction` object
Use `signMiMC` in https://github.com/iden3/circomlib/blob/master/src/eddsa.js#L53.

```js
signature = signMiMC(prvKey, txHash)

```

### Withdraw
1. User submits proof of inclusion of withdraw tx on-chain
Merkle proof of a transaction in a tx tree, made from user's EdDSA account to the zero address

2. User EdDSA signs message specifying recipient's Ethereum address 

3. User submits SNARK proof of EdDSA signature to smart contract


## Prover
The prover collects transactions from users and puts them through a SNARK circuit, which outputs a SNARK proof. She then submits the SNARK proof to the smart contract to update the Accounts tree root on-chain.

### Public inputs and output
- `tx_root`: Merkle root of a tree of transactions sent to the coordinator
- `current_state`: Merkle root of old Accounts tree 
- `out`: Merkle root of updated Accounts tree

### What the circuit is actually doing
The circuit is a giant `for` loop that performs a few validity checks on each transaction and updates the Accounts tree if the transaction is valid. It takes in the original root of the Accounts tree and a list of transactions, and outputs a legally updated root of the Accounts tree.

Let's go through the first iteration of the `for` loop:
- transaction check
  - **transactions existence check**: check that transaction exists in the `tx_root`
  - **transactions signature check**: check that transaction is signed by sender
- sender check
  - **sender account existence check**: check that sender account exists in `current_state`
  - **balance underflow check**: check that sender has sufficient balance to send transaction
- sender update
  - **sender state update**: decrement sender `balance` and increase sender `nonce`
  - **intermediate root update #1**: update `current_state` with new sender leaf to get `intermediate_root_1`
- receiver check
  - **receiver account existence check**: check that receiver account exists in `intermediate_root_1`
- receiver update
  - **receiver state update**: increment receiver `balance`
  - **intermediate root update #2**: update `intermediate_root_1` with new receiver leaf to get `intermediate_root_2`

Note: there is a special transaction where the receiver is the `zero_leaf`. We consider these to be `withdraw` transactions and do not change the balance and nonce of the `zero_leaf`.

### Inputs to SNARK circuit
#### Parameters
- `n`: depth of Accounts tree (`bal_depth`)
- `m`: depth of Transactions tree (`tx_depth`)

### Private inputs (organised by purpose)
##### General
- `intermediate_roots[2**(m+1)]`: the roots of the Accounts tree after processing each transaction. There are `2*2^m` intermediate roots because each transaction results in two updates (once to update the sender account, and then to update the receiver account)

##### Transaction information
- sender and receiver addresses
  - `from_x[2**m]`: the sender address x coordinate for each transaction
  - `from_y[2**m]`: the sender address y coordinate for each transaction
  - `to_x[2**m]`: the receiver address x coordinate for each transaction
  - `to_y[2**m]`: the receiver address y coordinate for each transaction

- signature from sender
  - `R8x[2**m]`: the x component of the R8 value of the sender's signature, for each transaction
  - `R8y[2**m]`: the y component of the R8 value of the sender's signature, for each transaction
  - `S[2**m]`: the S value of the sender's signature, for each transaction

- sender and receiver state
  - `nonce_from[2**m]`: the nonce of the sender account, for each transaction
  - `nonce_to[2**m]`: the nonce of the receiver account, for each transaction
  - `token_balance_from[2**m]`: the balance of the sender account, for each transaction
  - `token_balance_to[2**m]`: the balance of the receiver account, for each transaction

- amount and token type being transacted
  - `amount[2**m]`: amount being transferred, for each transaction 
  - `token_type_from[2**m]`: the sender account token type, for each transaction
  - `token_type_to[2**m]`: the receiver account token type, for each transaction

##### Transaction checks
- `paths2tx_root[2**m, m]`: Merkle proofs of inclusion (`m` long, since the Transactions tree has depth `m`) for the transactions (`2^m` of them)`
- `paths2tx_root_pos[2**m, m]`: a binary vector for each transfer indicating whether each node in its transfer proof is the left or right child

##### Account existence checks
- `paths2root_from[2**m, n]`: Merkle proofs of inclusion (`n` long, since the Accounts tree has depth `n`) for the sender accounts (`2^m` of them)
- `paths2root_from_pos[2**m, n]`: a binary vector for each sender account indicating whether each node in its transfer proof is the left or right child
- `paths2root_to[2**m, n]`: Merkle proofs of inclusion (`n` long, since the Accounts tree has depth `n`) for the receiver accounts (`2^m` of them)
- `paths2root_to_pos[2**m, n]`: a binary vector for each receiver account indicating whether each node in its transfer proof is the left or right child

