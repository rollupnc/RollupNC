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

        await mimc.methods.MiMCpe7(input, key).call();
    });

    it("Should hash value correctly in js", async () => {
        const m = BigInt(3703141493535563179657531719960160174296085208671919316200479060314459804651).toString();
        const k = BigInt(918403109389145570117360101535982733651217667914747213867238065296420114726).toString();
        
        const jsExpected = mimcjs.hash(m, k);
        const solidityResult = await solidityMiMCHash(m, k);

        assert.equal(solidityResult.toString(), jsExpected.toString(), "Unexpected result");
    });

    it("Should hash value correctly in solidity", async () => {
        const res = await solidityMiMCHash(1,2);
        const res2 = await mimcjs.hash(1,2,91);

        assert.equal(res.toString(), res2.toString());
    });

    async function solidityMiMCHash(val1, val2) {
        return mimc.methods.MiMCpe7(val1.toString(), val2.toString()).call();
    }
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

        const solE = await solidityMiMCHash(a, b);
        const jsE = mimcjs.hash(a, b);
        assert.equal(solE.toString(), jsE.toString());
        
        const solF = await solidityMiMCHash(c, d);
        const jsF = mimcjs.hash(c, d);
        assert.equal(solF.toString(), jsF.toString());
        
        // TODO: parse it with ying tong's MiMCMerkle.js after merge and assert values
        // g = hash(hash(a, b), hash(c, d))
        const solG = await solidityMiMCHash(solE, solF);
        const jsG = mimcjs.hash(jsE, jsF);
        assert.equal(solG.toString(), jsG.toString());

        // multihash = hash(hash(hash(hash(IV, a), b), c), d)
        const multiHashDecomposition = await solidityMiMCHash(await solidityMiMCHash(await solidityMiMCHash(await solidityMiMCHash(mimcjs.getIV(), a), b), c), d);
        const multiHashJS = mimcjs.multiHash([a, b, c, d]);

        assert.equal(multiHashDecomposition, multiHashJS, "wrong multihash");
        assert.notEqual(multiHashJS, jsG);
    });
});