# RollupNC (Rollup non-custodial)

An implementation of [rollup](https://github.com/barryWhiteHat/roll_up) in which the relayer **does not** publish transaction data to the main chain, but only publishes the new Merkle root at every update. This provides gas savings but not data availability guarantees: we assume the operator will always provide data to users so they can update their leaf.

## Pre-requirements

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

```
eddsa_pubKey{
  X: string // "biginteger",
  Y: string // "biginteger"
}
```

```
eddsa_signature = {
  R8: string[2] // "biginteger",
  S: string // "biginteger"
}
```

#### Merkle tree
```
zeroCache = string[bal_depth] //"biginteger"
```


### Deposits
1. User deposits into smart contract

  - get `deposit_queue_number` (global variable in smart contract)

  - add deposit to deposits_array
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

### Transfers

1. User constructs transfer object
```js
class Transfer = {
  from: eddsa_pubKey,
  to: eddsa_pubKey,
  amount: integer,
  nonce: integer,
  token_type: integer
}
```
2. User hashes transfer object
Use `multiHash` in https://github.com/iden3/circomlib/blob/master/src/mimc7.js#L47.

```js
txHash = multiHash([from, to, amount, nonce, token_type]) //"biginteger"
```

3. User signs hash of transfer object
Use `signMiMC` in https://github.com/iden3/circomlib/blob/master/src/eddsa.js#L53.

```js
signature = signMiMC(prvKey, txHash)

```

### Withdraw
1. User submits proof of inclusion of withdraw tx on-chain

2. User signs message specifying recipient's Ethereum address 

