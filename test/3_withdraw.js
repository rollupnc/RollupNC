// var RollupNC = artifacts.require("RollupNC");

// /*
//     Here we want to test the smart contract withdrawal functionality.
// */ 

// contract("RollupNC Withdraw", async accounts => {

//   const pubkey_from = [
//     "1762022020655193103898710344498807340207430243997238950919845130297394445492",
//     "8832411107013507530516405716520512990480512909708424307433374075372921372064"
//   ]
//   const nonce = 0;
//   const amount = 200;
//   const token_type_from = 2;
//   const proof = [
//     "14531446347543507823064235057843916202619496233804832613581857015484624277653",
//     "18254291533780430427259061798213882541801401402725032906945856976051805416542"
//     ]
//   const position = [1, 0]
//   const txRoot = 
//   "7053474720276417193178914001357165144196208978730163381613334488911018371101"
//   const recipient = "0xC33Bdb8051D6d2002c0D80A1Dd23A1c9d9FC26E4"
//   const a = [
//     "0x2c54372cad388d7e445489530a93e7c648b825ff5cd18e65526b11df8e9a5a8b", 
//     "0x2985487009964527c301b2930a5663c516e6dfa232e27f761047af2d95afc91c"]
//   const b = [
//     ["0x0dbe5a77aa4d004942268ffac90b5adfa35f3a3b5ce426f4a23e3a287ce4fd34",
//      "0x23250aa3d63898a457e07cb2a42417097ca36bcba65c40c30f2149e3c9040ff6"],
//      ["0x10fa8752666c9e8bf8d88c1470b6dc1544438247314cb6998f2f532547c8c179",
//       "0x0dc0721e9c65b9008eff2ee719855937b233fbc585cd6f2e3bc9fa8a3f9643ec"]]
//   const c = [
//     "0x1848acdb157b27c3fcb15cfa4bd09cdc116fafabebd9beddb8ce6486edf185d2", 
//     "0x18893ba046ebc078a3dfc615bbd08cb9e390084eb2a91edf758b3ea4da9ea3c7"]

//   // it("should reject invalid withdrawals", async () => {

//   // });

//   it("should accept valid withdrawals", async () => {
//     let rollupNC = await RollupNC.deployed();
//     let validWithdraw = await rollupNC.withdraw(
//           pubkey_from, [nonce, amount, token_type_from], 
//           [position, proof], txRoot, recipient,
//           a, b, c
//         );
//     assert(validWithdraw, "invalid withdraw");
//   });

// });