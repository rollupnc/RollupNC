var Migrations = artifacts.require("./Migrations.sol");
var Pairing = artifacts.require("./Pairing.sol");
var TransferVerifier = artifacts.require("./TransferVerifier.sol");
var WithdrawVerifier = artifacts.require("./WithdrawVerifier.sol");
var RollupNC = artifacts.require("./RollupNC.sol");
var MiMC = artifacts.require("./MiMC.sol");

module.exports = function(deployer, accounts) {
    deployer.deploy(Migrations);
    deployer.deploy(Pairing);
    deployer.link(Pairing, [TransferVerifier,WithdrawVerifier]);
      deployer.deploy(TransferVerifier).then(() => {
        return deployer.deploy(WithdrawVerifier);
      }).then(() => {
        return deployer.deploy(RollupNC, TransferVerifier.address, WithdrawVerifier.address);
      });
  };