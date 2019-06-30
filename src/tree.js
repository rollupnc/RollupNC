const treeHelper = require("./treeHelper.js");

module.exports = class Tree{

    constructor(
        _leafNodes
    ) {
        this.leafNodes = _leafNodes
        this.depth = treeHelper.getBase2Log(_leafNodes.length)
        this.allNodes = this.treeFromLeafNodes()
        this.root = this.allNodes[0][0]
    }

    treeFromLeafNodes(){
        var tree = Array(this.depth);
        tree[this.depth - 1] = treeHelper.pairwiseHash(this.leafNodes)

        for (var j = this.depth - 2; j >= 0; j--){
            tree[j] = treeHelper.pairwiseHash(tree[j+1])
        }
        return tree
    }

    getProof(leafIdx){
        const depth = this.allNodes.length;
        const proofPos = treeHelper.proofPos(leafIdx, depth);
        var proof = new Array(depth);
        proof[0] = this.leafNodes[proofPos[0]]
        for (var i = 1; i < depth; i++){
            proof[i] = this.allNodes[depth - i][proofPos[i]]
        }
        return [proof, proofPos]
    }

    verifyProof(leafHash, idx, proof){
        const computed_root = treeHelper.rootFromLeafAndPath(leafHash, idx, proof)
        const exists = (this.root == computed_root);
        if (!exists){
            throw "leaf does not exist"
        }
    }

    findLeafIdxByHash(hash){
        const index = this.leafNodes.findIndex(leaf => leaf.hash == hash)
        return index;
    }
}
