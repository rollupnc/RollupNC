const mimcjs = require("../circomlib/src/mimc7.js");
const mimcGenContract = require("../circomlib/src/mimc_gencontract.js");

/*
    Here we want to test the hashing of the MIMC7 contract
*/ 

contract("MiMC7 Hashing", async accounts => {
    let mimc;
    const SEED = "mimc";

    it("Should deploy the contract", async () => {
        const C = new web3.eth.Contract(mimcGenContract.abi);

        mimc = await C.deploy({
            data: mimcGenContract.createCode(SEED, 91)
        }).send({
            gas: 1500000,
            from: accounts[0]
        });
    });

    it("Should return a hash", async () => {
        const input = [2];
        const key = 22;

        let result = await mimc.methods.MiMCpe7(input, key).call();
        // console.log(result);
        // console.log(result.toString());
    });

    it("Should hash value correctly in js", async () => {
        const m = BigInt(3703141493535563179657531719960160174296085208671919316200479060314459804651).toString();
        const k = BigInt(918403109389145570117360101535982733651217667914747213867238065296420114726).toString();
        
        const jsExpected = mimcjs.hash(m, k);
        const solidityResult = await mimc.methods.MiMCpe7(m, k).call();

        assert.equal(solidityResult.toString(), jsExpected.toString(), "Unexpected result");
    });

    it("Should hash value correctly in solidity", async () => {
        const res = await mimc.methods.MiMCpe7(1,2).call();
        const res2 = await mimcjs.hash(1,2,91);

        assert.equal(res.toString(), res2.toString());
    });

    
    /*

              G
            E    F
          A  B  C  D

        E = hash(A, B)
        F = hash(C, D)
        G = hash(E, F)

        multihash(a,b,c,d) != G
        multihash(a,b,c,d) != hash(hash(a, b), hash(c, d))
        multihash(a,b,c,d) == hash(hash(hash(hash(IV, a), b), c), d)
    */
    it("Should parse trees the same way as the multihash", async () => {
        const a = BigInt(123).toString()
        const b = BigInt(564).toString()
        const c = BigInt(894).toString()
        const d = BigInt(354).toString()

        const solE = await mimc.methods.MiMCpe7(a, b).call();
        const jsE = mimcjs.hash(a, b);
        assert.equal(solE.toString(), jsE.toString());
        
        const solF = await mimc.methods.MiMCpe7(c, d).call();
        const jsF = mimcjs.hash(c, d);
        assert.equal(solF.toString(), jsF.toString());
        
        // g = hash(hash(a, b), hash(c, d))
        const solG = await mimc.methods.MiMCpe7(solE, solF).call();
        const jsG = mimcjs.hash(jsE, jsF);
        assert.equal(solG.toString(), jsG.toString());

        // TODO: parse it with ying tong's MiMCMerkle.js after merge
        // g = hash(hash(hash(hash(IV, a), b), c), d)
        const hashG = mimcjs.hash(mimcjs.hash(mimcjs.hash(mimcjs.hash(mimcjs.getIV(), a), b), c), d);

        // multihash is crashing the whole test, comment it out to see the result of the rest
        const multihashG = mimcjs.multiHash([a, b, c, d]);
        assert.equal(multihashG, hashG, "wrong multihash");
        assert.notEqual(multihashG, jsG);
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