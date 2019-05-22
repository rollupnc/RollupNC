var RollupNC = artifacts.require("RollupNC");

/*
    Here we want to test the smart contract withdrawal functionality.
*/ 

contract("RollupNC Withdraw", async accounts => {

  const pubkey_from = [
    "5188413625993601883297433934250988745151922355819390722918528461123462745458",
    "12688531930957923993246507021135702202363596171614725698211865710242486568828"
  ]
  const nonce = 0;
  const amount = 500;
  const token_type_from = 10;
  const proof = [
    "8342813455761320245860753246541064453130959347426759535493956280345855081934",
    "13262889801219401015313652374233039919049275140584211861348878621716455310933"
  ]
  const position = [1, 0]
  const txRoot = "149126198147162084281232535967801344773039936115368629187002798446712412021"
  const recipient = "0xC33Bdb8051D6d2002c0D80A1Dd23A1c9d9FC26E4"
  const a = [
    "0x096ed4c35159f0c371729082cc18d323135be5ae410fb4ba313595a666ed530c", 
    "0x2995f1640c8d4da98cde2ef61af64b2927c95c2946455247877643cca3b39db6"]
  const b = [
    ["0x1adbee8bcfa45824a5ebe904176b4f161282fbea31ff5954c7e49466f38e295f", 
    "0x249ba84b42ab6c8d0bf91b9d9f77069ba1c16f8d446eab203480c82819cea03d"],
    ["0x085780756487e6ed337d5a7cb362afaec168bd762df5ce93342894e1ca6dcdea", 
    "0x16deb6ed5cfe8c6457a9e5bd041fd8fc3e63efe88011a6252bea3e048f1b5737"]]
  const c = [
    "0x0486ae4189391ac3e03d03585fc4091ffea326e1f22bebac56883c586a1b6e82", 
    "0x034c0ae8bd353e82c697d227a8b2c7ae405a28dc9f4f3bd7a23f96947b71e400"]

  // it("should reject invalid withdrawals", async () => {

  // });

  it("should accept valid withdrawals", async () => {
    let rollupnc = await RollupNC.deployed();
    let validWithdraw = await rollupnc.withdraw(
          pubkey_from, [nonce, amount, token_type_from], 
          [position, proof], txRoot, recipient,
          a, b, c
        );
    assert(validWithdraw, "invalid withdraw");
  });

});