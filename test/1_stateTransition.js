var RollupNC = artifacts.require("RollupNC");

/*
    Here we want to test the smart contract state transition functionality.
*/ 

contract("RollupNC State Transition", async accounts => {

  const a = [
        "0x062239b7a8e6411d3484c026256873e801409e63d18128a5ebef3ef65dc7efef", 
        "0x2e3165fd484f3f275ed0064be5f070f080b89de002f6cc22d21e45e17e688ba0"]
  const b = [
        ["0x1516a8a04104bb78f0853afd17710959d6c83d182576372a1ad14affc0b599fe", 
        "0x1f71446f20d3760b3173ea5c403505147986dbc21e0dcf23676e01b226405676"],
        ["0x13778de7a786d7b5b4aa0f4b1bad92dee81765b47156942f3473a3eac28a2c8e", 
        "0x1a1dd5f2745fbab17c9bd2444b6d50fa0b5943ecd1bed48903ecc70237d437a6"]
    ]
  const c = [
    "0x254944eb6d337390994d03d7326a73bc2e72c74c5d32ea6af367ce8ddc222024", 
    "0x20f5ff8afdf449b06b2eacc4fe4c5836b1d980e6f18054c65e52bf69d94d53c8"]
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