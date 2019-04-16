const eddsa = require("../circomlib/src/eddsa.js");
const snarkjs = require("snarkjs");
const fs = require("fs");
const util = require("util");
const mimcjs = require("../circomlib/src/mimc7.js");

const bigInt = snarkjs.bigInt;

module.exports = {
    
    generatePrvKeys: function(n){
        var prvKeys = [];
        for (i = 1; i < n+1; i++) {
            var prvKey = Buffer.from(
                i.toString().padStart(64,'0'), "hex");
            // console.log(prvKey);
            prvKeys.push(prvKey);
        }
        return prvKeys;  
    },

    generatePubKeys: function(prvKeys){
        if (Array.isArray(prvKeys)){
            var pubKeys = [];
            for (i = 0; i < prvKeys.length; i++){
                var pubKey = eddsa.prv2pub(prvKeys[i]);
                pubKeys.push(pubKey);
            }
        } else {
            console.log('please enter arguments as an array.')
        }
        return pubKeys; 
    },

    
    getPubKeysX: function(pubKeys){
        if (Array.isArray(pubKeys[0])){
            var pubKeysX = [];
            for (i = 0; i < pubKeys.length; i++){
                var pubKeyX = pubKeys[i][0];
                pubKeysX.push(pubKeyX);
            }
        } else {
            pubKeysX = pubKeys[0]
        }
        return pubKeysX;
    },

    getPubKeysY: function(pubKeys){
        if (Array.isArray(pubKeys[0])){
            var pubKeysY = [];
            for (i = 0; i < pubKeys.length; i++){
                var pubKeyY = pubKeys[i][1];
                pubKeysY.push(pubKeyY);
            }
        } else {
            pubKeysY = pubKeys[1];
        }
        return pubKeysY;
    },

    zeroAddress: function(){
        return ["0".padStart(76,'0'), "0".padStart(77,'0')]
    }

}
