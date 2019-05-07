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

### Deploy MimcHash contract 
```bash
npm run deploy-mimc 
```

### Test locally 
```bash
npm run rpc
npm run test
```

## Deposit Mechanism

The smart contract stores the root of the current deposits tree `Td`, and an array of pending deposits.
Users create new pending deposits by: setting a token allowance to the contract, then calling the `RollupNC` deposit function.

The coordinator:
- creates a merkle tree `T1` where leaves are the current pending deposits.
- superimposes `T1` to `Td` creating a new deposits tree `Tn`.
- posts to the smart contract the root of `Tn` , and a snark proof of the superimposition of `T1`.

The smart contract verifies the snark proof, updates the current deposits tree root, and clears the pending deposits array.

### Tree superimposition

Limit depth 24.
Skip on IV (empty hashes).
Start with depth 0. 

Pending deposits gather until coordinator processes them. 
The coordinator gets the current deposits, 