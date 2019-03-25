var Migrations = artifacts.require("./Migrations.sol");
var Verifier = artifacts.require("./Verifier.sol");
var RollupNC = artifacts.require("./RollupNC.sol");

module.exports = function(deployer, accounts) {
    deployer.deploy(Migrations);
    deployer.deploy(Verifier).then(() => {
      return deployer.deploy(RollupNC, Verifier.address);
    })
  };