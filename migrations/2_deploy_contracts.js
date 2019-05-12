var MiMCMerkle = artifacts.require("./dependencies/MiMCMerkle.sol");
var RollupNC = artifacts.require("./RollupNC.sol");
const mimcGenContract = require("../circomlib/src/mimc_gencontract.js");

var TestToken = artifacts.require("./TestToken.sol");
var DepositManager = artifacts.require("./DepositManager.sol");
var TokenRegistry = artifacts.require("./TokenRegistry.sol");

module.exports = async function(deployer, network, accounts) {
    const mimc = await deployMimc(accounts[0]);
    await deployer.deploy(TestToken);
    await deployer.deploy(TokenRegistry);

    console.log("MiMC address: " + mimc.options.address)
    await deployer.deploy(MiMCMerkle, mimc.options.address)
    .then(async () => {
        await deployer.deploy(DepositManager, MiMCMerkle.address, TokenRegistry.address);

        return deployer.deploy(
            RollupNC, 
            mimc.options.address,
            MiMCMerkle.address,
            DepositManager.address
        );
    })
};

async function deployMimc(account) {
    const mimc = new web3.eth.Contract(mimcGenContract.abi);
    const SEED = "mimc";

    return await mimc.deploy({
        data: mimcGenContract.createCode(SEED, 91)
    }).send({
        gas: 1500000,
        from: account
    });
}
