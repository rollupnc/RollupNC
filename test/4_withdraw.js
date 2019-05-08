var RollupNC = artifacts.require("RollupNC");

/*
    Here we want to test the smart contract withdrawal functionality.
*/ 

contract("RollupNC Withdraw", async accounts => {

  const pubkey_from = [
    "5188413625993601883297433934250988745151922355819390722918528461123462745458",
    "12688531930957923993246507021135702202363596171614725698211865710242486568828"
  ]
  const pubkey_to = [
    0,
    0
  ]
  const amount = 500;
  const token_type_from = 10;
  const proof = [
    "8342813455761320245860753246541064453130959347426759535493956280345855081934",
    "13262889801219401015313652374233039919049275140584211861348878621716455310933"
  ]
  const position = [1, 0]
  const txRoot = "149126198147162084281232535967801344773039936115368629187002798446712412021"
  const recipient = "0xC33Bdb8051D6d2002c0D80A1Dd23A1c9d9FC26E4"

  // it("should reject invalid withdrawals", async () => {

  // });

  it("should accept valid withdrawals", async () => {
    let rollupnc = await RollupNC.deployed();
    let validWithdraw = await rollupnc.withdraw(
          pubkey_from, pubkey_to, amount, token_type_from, 
          proof, position, txRoot, recipient
        );
    assert(validWithdraw, "invalid withdraw");
  });

});