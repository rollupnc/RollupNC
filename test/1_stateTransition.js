var RollupNC = artifacts.require("RollupNC");

/*
    Here we want to test the smart contract state transition functionality.
*/ 

contract("RollupNC State Transition", async accounts => {

  const a = [
    "0x2130d51e741c3ea41e36f42a1a574546c79d016d2c6f781cfb613a46bea31748", 
    "0x03571457870dbea4bbf79409496eaafce0086eb961a52d4f4a7ea35f6d4dec29"
  ]
  const b = [
    ["0x276e5f96f8738403506cb961bbdcb78b2f3e874668d747f1628c8d1326d020dd", 
    "0x14df145c7a79081e11ffca6c8f86dae9841803ce28fe86d44f7ec93082de3f3f"],
    ["0x24a914040d9f8eef75e9cd97e66cbf94e4089f370a10d9f312d138218b901246", 
    "0x28e65cb705394aecc1b1932a3c4afc6d1739261253680a94a6ba0b06aa41ea66"]
  ]
  const c = [
    "0x19b2cf492a71f35fa1fb72adff021065e7ba115237540728b5f39f4478804ffe", 
    "0x00c0ad43d9dc08a7f7d4b2e1535913f8baeac9afef5a20255e1596be1bcb86a1"
  ]
  const input = [
      "0x275dcd67144ff8b3bad6216dea047b7363c429776c36a389244d9a6f418afc72",
      "0x005467061d2c89c0dbbd5f5162bd49fc35608824308494d0dc0998d713635775",
      "0x20e980b0a37ce697f8f6a15dc8679d367961168874e1f7f9b90710f0365d50b5"
    ]

  // it("should reject invalid state updates", async () => {

  // });

  it("should accept valid state updates", async () => {
    let rollupnc = await RollupNC.deployed();
    let validStateUpdate = await rollupnc.updateState(
          a, b, c, input
        );
    assert(validStateUpdate, "invalid state transition");
  });

});