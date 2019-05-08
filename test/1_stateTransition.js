var RollupNC = artifacts.require("RollupNC");

/*
    Here we want to test the smart contract state transition functionality.
*/ 

contract("RollupNC State Transition", async accounts => {

  const a = [
    "0x2436fc4c70b0b82dfd55a2a18b77676591023747398e3a04c19cd9437fad6cb0", 
    "0x1c9be5d4bf1455b58881dada3584c0d6d96461dfdf45203571c8372435997f60"
  ]
  const b = [
    ["0x2e690f499498d6ee3a975cedc00a50eadeb83c81a5beb4cd6fcd0712e1e22c40", 
    "0x176e742ab0c19e7f9b36f597ea2e3861676a22610cca1c98b3d675a36a7acc1a"],
    ["0x0cc540b68a54ad8c4a592f689cfddc7450d094123642dffd8e0e5ae45fcb6522", 
    "0x0e3e4d0832f4db3d7666456941044516355a1ba79ae0553872a028ab62a1d543"]
  ]
  const c = [
    "0x2f7fb9e1ac6b19c10e1d294d89e594a1779a6d25428ba8d1adc2febbfe60b872", 
    "0x16d1d9270f6044c2860bb5a5b0dbe829aa31ebfca7e5ff46f76650b7a2232167"
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