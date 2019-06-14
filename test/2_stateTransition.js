// var RollupNC = artifacts.require("RollupNC");

// /*
//     Here we want to test the smart contract state transition functionality.
// */ 

// contract("RollupNC State Transition", async accounts => {

//     const updateA = [
//         "0x0f1baedd66ca51288fea85de83d4db6018588e4f3e494d9f49837b541d037edc",
//         "0x1a449d046ccc37424c3925f95aeceae5bc01f8554d5f773eb8d5d339f19f0d77"]
//     const updateB = [
//         ["0x1655b9d96c2a157baf7ae8e09cda18680c391cdd504f1de2f811b62aa60aac77",
//          "0x08846aa2499816ad822b874ed6a67fc53d3df3e04eecd747f37102de7cbf4217"],
//          ["0x0b60f81862b1b90c9e750939adb70021bfa184443fb8fd0a4532258fb006f2ec", 
//          "0x0011e80537fcb1e321c9a489ff2af2f3bd9f83b2bf73dc55b1bed254751eacba"]]
//     const updateC = [
//         "0x259cc06cd0cbd9244fba753eed2c8c692bfb68c8ba1fb0fb78c068bdd1707861",
//          "0x0a200a8e284bdb07142de5c24db0bae27193be0efd4922aec713f8358c8f1765"]
//     const updateInput = [
//         "0x1a52b20785401603b64b1cc3db168f648e96d52af9fc896396e76e068ffb7547",
//         "0x0f98200e29638cb637d4ce0f18d8fcd9166880c072c0085d539b01d42c22a81d",
//         "0x293a77d2ffc919fec84075c4fc2f86d3d1c34570fbe52eed3f99041a720c38d2"]

//     // it("should reject invalid state updates", async () => {
  
//     // });
  
//     it("should accept valid state updates", async () => {
//       let rollupNC = await RollupNC.deployed();
//       let validStateUpdate = await rollupNC.updateState(
//             updateA, updateB, updateC, updateInput
//           );
//       assert(validStateUpdate, "invalid state transition");
//       await rollupNC.currentRoot().then(console.log)
  
//     });


// });