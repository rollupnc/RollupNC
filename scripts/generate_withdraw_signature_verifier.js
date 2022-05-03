const ffj = require("ffjavascript");
const buildEddsa = require("circomlibjs").buildEddsa;
const buildMimc7 = require("circomlibjs").buildMimc7;
const buildBabyjub = require("circomlibjs").buildBabyjub;
const snarkjs = require("snarkjs");
const fs = require("fs");
const fromHexString = hexString =>
  new Uint8Array(hexString.match(/.{1,2}/g).map(byte => parseInt(byte, 16)));

const Scalar = ffj.Scalar;
let eddsa
let mimcjs

const main = async () => {
  eddsa = await buildEddsa()
  mimcjs = await buildMimc7();
  babyJub = await buildBabyjub();
  //let F = eddsa.babyJub.F;
  let F = mimcjs.F

  //var prvKey = Buffer.from("4".padStart(64,'0'), "hex");
  const prvKey = fromHexString("0001020304050607080900010203040506070809000102030405060708090002");

  var pubKey = eddsa.prv2pub(prvKey);

  var nonce = 0;
  //var txRoot = bigInt('14053325031894235002744541221369412510941171790893507881802249870625790656164')
  var recipient = fromHexString('0xC33Bdb8051D6d2002c0D80A1Dd23A1c9d9FC26E4');
  var m = mimcjs.multiHash([nonce, recipient])
  //const msgBuf = fromHexString("000102030405060708090000");
  //const msg = eddsa.babyJub.F.e(Scalar.fromRprLE(msgBuf, 0));
  const msg = F.e(m);

  var signature = eddsa.signMiMC(prvKey, msg);

  var verify = eddsa.verifyMiMC(msg, signature, pubKey)
  console.log(verify)

  const inputs = {
    Ax: F.toString(pubKey[0]),
    Ay: F.toString(pubKey[1]),
    R8x: F.toString(signature.R8[0]),
    R8y: F.toString(signature.R8[1]),
    S: signature.S.toString(),
    M: F.toString(msg)
  }

  fs.writeFileSync(
    "input.json",
    JSON.stringify(inputs),
    "utf-8"
  );
}

main().then(() => {
  console.log("Done")
})
