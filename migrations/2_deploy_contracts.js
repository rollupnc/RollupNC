var MiMCMerkle = artifacts.require("./dependencies/MiMCMerkle.sol");
var RollupNC = artifacts.require("./RollupNC.sol");
var TokenRegistry = artifacts.require("./TokenRegistry.sol");
const mimcGenContract = require("../circomlib/src/mimc_gencontract.js");

module.exports = async function(deployer, network, accounts) {
    const mimc = await deployMimc(accounts[0]);
    console.log("MiMC address: " + mimc.options.address)
    await deployer.deploy(MiMCMerkle, mimc.options.address, {from: accounts[0]})
    await deployer.deploy(TokenRegistry, accounts[0])
    .then(() => {
        return deployer.deploy(
            RollupNC, 
            mimc.options.address,
            MiMCMerkle.address,
            TokenRegistry.address,
            {from: accounts[0]}
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
