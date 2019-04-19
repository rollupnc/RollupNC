var Migrations = artifacts.require("./Migrations.sol");
var Pairing = artifacts.require("./Pairing.sol");
var TransferVerifier = artifacts.require("./TransferVerifier.sol");
var WithdrawVerifier = artifacts.require("./WithdrawVerifier.sol");
var RollupNC = artifacts.require("./RollupNC.sol");
var TestToken = artifacts.require("./TestToken.sol");
var DepositManager = artifacts.require("./DepositManager.sol");
var TokenRegistry = artifacts.require("./TokenRegistry.sol");

module.exports = function(deployer, accounts) {
    deployer.deploy(Migrations);
    deployer.deploy(Pairing);
    deployer.deploy(TestToken);
    deployer.link(Pairing, [TransferVerifier,WithdrawVerifier]);
    deployer.deploy(TransferVerifier).then(() => {
      return deployer.deploy(WithdrawVerifier);
    }).then(() => {
      return deployer.deploy(TokenRegistry)
    }).then(() => {
      return deployer.deploy(DepositManager, TokenRegistry.address)
    }).then(() => {
      return deployer.deploy(RollupNC, TransferVerifier.address, WithdrawVerifier.address, DepositManager.address);
    });
  };