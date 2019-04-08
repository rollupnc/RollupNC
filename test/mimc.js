const MiMC = artifacts.require("MiMC");
const mimcjs = require("../circomlib/src/mimc7.js");

/*
    Here we want to test the hashing of the MIMC7 contract
*/ 

contract("MiMC7 Hashing", async accounts => {
    let mimc7;

    before(async () => {
        mimc7 = await MiMC.deployed();
    })

    it("should return a hash", async () => {
        const input = [2];
        const key = 22;

        let result = await mimc7.Hash(input, key);
        // console.log(result);
        // console.log(result.toString());
    });

    it("should hash value correctly in js", async () => {
        var m = [   BigInt(3703141493535563179657531719960160174296085208671919316200479060314459804651).toString() ];

        console.log("here")
        console.log(m.toString());
        const k = BigInt(918403109389145570117360101535982733651217667914747213867238065296420114726).toString();
        
        const jsExpected = mimcjs.hash(m[0], k);
        const solidityResult = await mimc7.Hash(m, k);

        assert.equal(solidityResult.toString(), jsExpected.toString(), "Unexpected result");
    });

    // // https://github.com/HarryR/ethsnarks/blob/master/test/TestMiMC.sol
    // it("should hash value correctly in solidity", async () => {
    //     var m = [   BigInt(3703141493535563179657531719960160174296085208671919316200479060314459804651).toString(),
    //                 BigInt(134551314051432487569247388144051420116740427803855572138106146683954151557).toString()  ]

	// 	const k = BigInt(918403109389145570117360101535982733651217667914747213867238065296420114726).toString();
    //     const expected = BigInt(15683951496311901749339509118960676303290224812129752890706581988986633412003).toString();
        
    //     const result = await mimc7.Hash(m, k);
	// 	assert.equal(result.toString(), expected.toString(), "Unexpected result");
    // });
});