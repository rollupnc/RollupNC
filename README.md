# RollupNC (Rollup non-custodial)

An implementation of [rollup](https://github.com/barryWhiteHat/roll_up) in which the relayer **does not** publish transaction data to the main chain, but only publishes the new Merkle root at every update. This provides gas savings but not data availability guarantees: we assume the operator will always provide data to users so they can update their leaf.

### Pre-requirements

1. Install node version 10.16.0, possibly using [nvm](https://github.com/nvm-sh/nvm)
2. Install truffle and ganache-cli
bash
$ npm install -g truffle ganache-cli
3. Install submodules: use `git submodule update --init --recursive` to clone `circomlib` submodule
4. Install npm modules in both root directory and circomlib submodule
5. [Check out this circom intro](https://github.com/iden3/circom/blob/master/TUTORIAL.md)
