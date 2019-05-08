var MiMCMerkle = artifacts.require("./dependencies/MiMCMerkle.sol");
var Verifier = artifacts.require("./Verifier.sol");
var RollupNC = artifacts.require("./RollupNC.sol");
const mimcGenContract = require("../circomlib/src/mimc_gencontract.js");

module.exports = async function(deployer, network, accounts) {
    const mimc = await deployMimc(accounts[0]);
    console.log("MiMC address: " + mimc.options.address)
    await deployer.deploy(MiMCMerkle, mimc.options.address)
    .then(() => {
        return deployer.deploy(Verifier)
        .then(() => {
            return deployer.deploy(
                RollupNC, 
                Verifier.address,
                mimc.options.address,
                MiMCMerkle.address
            );
        })
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
