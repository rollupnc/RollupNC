const mimcjs = require("../circomlib/src/mimc7.js");
const fs = require('fs');

var fileNames = process.argv.slice(2);

// Blocking example with fs.readFileSync
const fileName = fileNames[0];
var parsedData = JSON.parse(fs.readFileSync(fileName, 'utf-8'));
var stringArray = [];

for (var p in parsedData){
    stringArray.push(parsedData[p].toString());
}

var dataHash = mimcjs.multiHash(stringArray);
console.log("Hash of JSON data: " + dataHash.toString());


