const MiMC = artifacts.require("MiMC");

/*
    Here we want to test the hashing of the MIMC7 contract
*/ 

contract("MiMC7 Hashing", async accounts => {
    let mimc7;

    before(async () => {
        console.log("before");
        mimc7 = await MiMC.deployed();
    })
    it("should return correct hash", async () => {
        const input = [2, 3];
        let result = await mimc7.Hash(input);
        console.log(result);
    });
});