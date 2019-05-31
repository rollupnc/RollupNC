# RollupNC (Rollup non-custodial)

An implementation of [rollup](https://github.com/barryWhiteHat/roll_up) in which the relayer **does not** publish transaction data to the main chain, but only publishes the new Merkle root at every update. This provides gas savings but not data availability guarantees: we assume the operator will always provide data to users so they can update their leaf.

note: use node 10.16.0

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
