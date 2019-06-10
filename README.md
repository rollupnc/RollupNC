# RollupNC (Rollup non-custodial)

An implementation of [rollup](https://github.com/barryWhiteHat/roll_up) in which the relayer **does not** publish transaction data to the main chain, but only publishes the new Merkle root at every update. This provides gas savings but not data availability guarantees: we assume the operator will always provide data to users so they can update their leaf.

note: use node 10.16.0


### Pre-requirements

1. Install node version 10.16.0, possibly using [nvm](https://github.com/nvm-sh/nvm)
2. Install truffle and ganache-cli
bash
$ npm install -g truffle ganache-cli
3. Install submodules
bash
git submodule update --init --recursive
4. [Install docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
5. [Check out this circom intro](https://github.com/iden3/circom/blob/master/TUTORIAL.md)
