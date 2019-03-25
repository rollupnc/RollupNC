# RollupNC (Rollup non-custodial)

An implementation of [rollup](https://github.com/barryWhiteHat/roll_up) in which the relayer **does not** publish transaction data to the main chain, but only publishes the new Merkle root at every update. This provides gas savings but not data availability guarantees: we assume the operator will always provide data to users so they can update their leaf.

### Pre-requirements

1. [Install docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
2. [Check out this circom intro](https://github.com/iden3/circom/blob/master/TUTORIAL.md)

### Build

```bash
$ docker build -t rollup/rollup-nc docker
```

### Setup

```bash
$ docker run -ti rollup/rollup-nc /bin/bash
```

## Signature validation

We put a public key in our merkle tree and prove we have a signature that was created by that public key for a message of size 80 bits.
Circuit can be found at `signature_verification/eddsa_mimc_verifier.circom`

#### Generate circuit

```bash
$ cd circomlib
$ circom signature_verification/eddsa_mimc_verifier.circom -o signature_verification/eddsa_mimc_verifier.cir
```

#### Generate Input

Checkout `signature_verification/generate_sample_eddsa_mimc_verifier.js`

Run the command below to generate input for calculating witness.

```bash
$ cd signature_verification
$ node generate_sample_eddsa_mimc_verifier.js
```

A file `eddsa_mimc_input.json` would be created which is then supplied while generating witness.

#### Test if circuit compiles correctly

```bash
$ snarkjs calculatewitness -c eddsa_mimc_verifier.cir -i eddsa_mimc_input.json
```

## Permissioned merkle tree update

So now lets say we want to update the leaf in the merkle tree
but the only let people update the leaf is if they have the current public key. The leaf index in the tree represents an NFT token owned a user.

Circuit can be found at `leaf_update/leaf_update.circom`

#### Generate circuit

```bash
$ circom leaf_update/leaf_update.circom -o leaf_update/leaf_update.cir
```

#### Generate Input

Checkout `leaf_update/generate_sample_leaf_update.js`
Run the command below to generate input for calculating witness.

```bash
$ cd leaf_update
$ node generate_sample_leaf_update.js
```

A file `leaf_update_input.json` could be created which is then supplied while generating witness.

## Token transfers

Lets change our leaf so that instead of a public key it holds a public key and a number.
We can use the number to represent a token balance.

We have a circuit at `tokens_transfer/tokens_transfer.circom`

#### Generate circuit

```bash
$ circom tokens_transfer/tokens_transfer.circom -o tokens_transfer/tokens_transfer.cir
```

#### Generate Input

Checkout `token_transfer/generate_sample_tokens_transfer.js`
Run the command below to generate input for calculating witness.

```bash
$ cd tokens_transfer
$ node generate_sample_tokens_transfer.js
```

A file `tokens_transfer_input.json` could be created which is then supplied while generating witness.

NOTE : Careful, this circuit is quite big and took to setup on my MacbookPro more than 10m.
The witness is generally a better way to check if your circuit compiles properly.

And we need to add some token balance requirements as follows

### Putting this all inside a smart contract

Compile the code

```bash
$ circom tokens_transfer.circom -o circuit.json
```

Perform the trusted setup _this will take a long time ~ 20 mins_ see the comments about reducing proving time in the disclaimer.
They apply here also.

```bash
$ snarkjs setup --protocol groth
```

Create a smart contract to verify this circuit on EVM.

```bash
$ snarkjs generateverifier
```

Checkout `verifier.sol` -- This contract will verify snarks on-chainand will be used to build our side chain !

So now we have a smart contract where we can deposit coins to move to the side chain.

Then we can transfer them via snark and eventually we can withdraw them to the main chain again.

### Deposit


### Withdraw
