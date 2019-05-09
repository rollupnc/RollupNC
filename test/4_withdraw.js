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

  const a = [
    "0x0d3772db6cc4d2b1a4025d700206c1fd0d04123c57b225514d495ceac2d003e8", 
    "0x059fa3f88b05a429eafbdce88c356d98f8c56649236166b59beb38758e195844"
  ]

  const b = [
    ["0x10814e3178070cdc64fb425339ae573904f89a2d9415574786ef8567dda2c35a", 
    "0x1c278bf0eb57839134205593e38022badd9d3886097232457630879365d351cf"],
    ["0x1db5070c455a7e70d46bc924dc9a83eb0d5b714bed13c0fab773e4385376cac6", 
    "0x12e5683544ef3d8448e6fc7932d19b61160a94eac76c0b59b983caffe1cfbcea"]
  ]

  const c = [
    "0x08da1d82340d24e7482d330290a7a72b38bbda66334f9acf0257e38e9ff2b01a", 
    "0x0b288814628f4e9b4c1b3bcf736f88fdc31b6c50705d5d49a21d38fbc071b775"
  ]

  // it("should reject invalid withdrawals", async () => {

  // });

  it("should accept valid withdrawals", async () => {
    let rollupnc = await RollupNC.deployed();
    let validWithdraw = await rollupnc.withdraw(
          pubkey_from, pubkey_to, amount, token_type_from, 
          proof, position, txRoot, recipient,
          a, b, c
        );
    assert(validWithdraw, "invalid withdraw");
  });

});