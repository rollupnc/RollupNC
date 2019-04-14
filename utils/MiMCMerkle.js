const mimcjs = require("../circomlib/src/mimc7.js");


module.exports = {

    rootFromLeafAndPath: function(depth, leaf, merkle_path, merkle_path_pos){
        if (depth == merkle_path.length + 1){
            var root = new Array(depth - 1);
            left = leaf - BigInt(merkle_path_pos[0])*(leaf - BigInt(merkle_path[0]));
            right = BigInt(merkle_path[0]) - BigInt(merkle_path_pos[0])*(BigInt(merkle_path[0]) - leaf);
            root[0] = mimcjs.multiHash([left, right]);
            var i;
            for (i = 1; i < depth - 1; i++) {
                left = root[i-1] - BigInt(merkle_path_pos[i])*(root[i-1] - BigInt(merkle_path[i]));
                right = BigInt(merkle_path[i]) - BigInt(merkle_path_pos[i])*(BigInt(merkle_path[i]) - root[i-1]);              
                root[i] = mimcjs.multiHash([left, right]);
            }
        } else {
            console.log("Merkle path is of length ", merkle_path.length, 
            "when it should be length ", depth - 1)
        }
        return root[depth - 2];
    },

    rootFromLeafArray: function(leafArray){
        depth = module.exports.getBase2Log(leafArray.length);
        treeRoot = Array(depth);

        treeRoot[0] = module.exports.pairwiseHash(leafArray)

        for (j = 1; j < depth; j++){
            treeRoot[j] = module.exports.pairwiseHash(treeRoot[j-1])
        }

        return treeRoot[depth-1]
    },

    pairwiseHash: function(array){
        if (array.length % 2 == 0){
            arrayHash = []
            for (i = 0; i < array.length; i = i + 2){
                arrayHash.push(mimcjs.multiHash([array[i].toString(),array[i+1].toString()]))
            }
            return arrayHash
        } else {
            console.log('array must have even number of elements')
        }
    },

    getBase2Log: function(y){
        return Math.log(y) / Math.log(2);
    },

    generateMerklePos: function(from, to, binLength){
        merklePosArray = [];
        for (i = from;  i < to; i++){
            binPos = module.exports.idxToBinaryPos(i, binLength)
            merklePosArray.push(binPos)
        }
        return merklePosArray;
    },

    binaryPosToIdx: function(binaryPos){
        var idx = 0;
        for (i = 0; i < binaryPos.length; i++){
            idx = idx + binaryPos[i]*(2**i)
        }
        return idx;
    },

    idxToBinaryPos: function(idx, binLength){

        binString = idx.toString(2);
        binPos = Array(binLength).fill(0)
        for (j = 0; j < binString.length; j++){
            binPos[j] = Number(binString.charAt(binString.length - j - 1));
        }
        return binPos;
    }

}