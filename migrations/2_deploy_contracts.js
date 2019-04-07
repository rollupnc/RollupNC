var Migrations = artifacts.require("./Migrations.sol");
// var Pairing = artifacts.require("./Pairing.sol");
// var TransferVerifier = artifacts.require("./TransferVerifier.sol");
var EdDSA = artifacts.require("./dependencies/EdDSA.sol")
var Withdraw = artifacts.require("./Withdraw.sol");
// var RollupNC = artifacts.require("./RollupNC.sol");


// module.exports = function(deployer, accounts) {
//     deployer.deploy(Migrations);
//     deployer.deploy(Pairing);
//     deployer.link(Pairing, TransferVerifier);
//     deployer.deploy(TransferVerifier).then(() => {
//       return deployer.deploy(RollupNC, TransferVerifier.address);
//     });
//   };

module.exports = function(deployer, accounts) {
  deployer.deploy(Migrations);
  deployer.deploy(EdDSA).then(() => {
    return deployer.deploy(Withdraw, mimcAddr, EdDSA.address);
  });
}