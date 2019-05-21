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
    "0x24da287f055f2e76488ff77064decffa83e13ed4e4ad2ee44d4a1be6a7322b41", 
    "0x2669b601920c8a11cb9c1020c7c0aac55ca0d9e3737164acc831b6986dba302d"]
  const b = [
    ["0x07b4e64317b68ff3cf82d9c3211a6abe1933f212e44d5d5405c4823c44da77b3", 
    "0x0a38f9bcda6de56ac1bf09d93f2909946e773fa7de8f759f8594bc6786cfda32"],
    ["0x177019cb641cb8575f9c6ef2b865d60d3437384f13bd311c69fa292da8f08ef1", 
    "0x1c404343b258e15d3f41b6959ea68edd0959ca62faa9a5cfbcc6667295c6644d"]]
  const c = [
    "0x12ba49b6986c922dbaf6f2cf3275419f01609efef6ec556ae1a2a0fae044741e", 
    "0x139ea53ae557c85f1d62e34fab0065b74309db7c3b28f14542c0b7e37a0da9c5"]

  // it("should reject invalid withdrawals", async () => {

  // });

  it("should accept valid withdrawals", async () => {
    let rollupnc = await RollupNC.deployed();
    let validWithdraw = await rollupnc.withdraw(
          pubkey_from, pubkey_to, [nonce, amount, token_type_from], 
          [position, proof], txRoot, recipient,
          a, b, c
        );
    assert(validWithdraw, "invalid withdraw");
  });

});