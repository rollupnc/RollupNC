const mimcjs = require("../circomlib/src/mimc7.js");
const { MerkleTree } = require('merkletreejs')

module.exports = {

    rootFromLeafAndPath: function(depth, leaf, merkle_path, merkle_path_pos){
        if (depth == merkle_path.length){
            var root = new Array(depth);
            left = leaf - BigInt(merkle_path_pos[0])*(leaf - BigInt(merkle_path[0]));
            right = BigInt(merkle_path[0]) - BigInt(merkle_path_pos[0])*(BigInt(merkle_path[0]) - leaf);
            root[0] = mimcjs.multiHash([left, right]);
            var i;
            for (i = 1; i < depth; i++) {
                left = root[i-1] - BigInt(merkle_path_pos[i])*(root[i-1] - BigInt(merkle_path[i]));
                right = BigInt(merkle_path[i]) - BigInt(merkle_path_pos[i])*(BigInt(merkle_path[i]) - root[i-1]);              
                root[i] = mimcjs.multiHash([left, right]);
            }
        } else {
            console.log("Merkle path is of length ", merkle_path.length, 
            "when it should be length ", depth)
        }
        return root[depth - 1];
    },

    // treeFromLeafArray: function(leafArray){
    //     tree = new MerkleTree(Buffer.from(leafArray), mimcjs.hash);
    //     return tree;
    // },

    // proofFromTree: function(leaf, tree){
    //     proof = tree.getProof(leaf)
    //     return proof;
    // },

    // verifyProof: function(proof, leaf, root, tree){
    //     return tree.verify(proof, leaf, root)
    // },

    proofIdx: function(leafIdx, treeDepth){
        console.log("leafIdx", leafIdx)
        proofIdxArray = new Array(treeDepth);
        proofPos = module.exports.idxToBinaryPos(leafIdx, treeDepth);
        console.log("proofPos", proofPos)

        layerIdx = leafIdx;
        num = Math.floor(module.exports.getBase2Log(leafIdx)) - 1
        if (num < 1){ num = 1 }
        for (i = treeDepth; i > 0; i--){
            console.log("layerIdx before", treeDepth - i, layerIdx)
            if (proofPos[treeDepth - i] == 0){
                proofIdxArray[treeDepth - i] = layerIdx + 1
                layerIdx = layerIdx + 2**i/num - num;
            } else {
                proofIdxArray[treeDepth - i] = layerIdx - 1
                layerIdx = layerIdx + 2**i/num ;
            }

            console.log("layerIdx", treeDepth - i, layerIdx)

        }

        return(proofIdxArray)


    },

    treeFromLeafArray: function(leafArray){
        depth = module.exports.getBase2Log(leafArray.length);
        tree = Array(depth);

        tree[depth - 1] = module.exports.pairwiseHash(leafArray)

        for (j = depth - 2; j >= 0; j--){
            tree[j] = module.exports.pairwiseHash(tree[j+1])
        }

        // return treeRoot[depth-1]
        return tree
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

    generateMerklePosArray: function(from, to, binLength){
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
