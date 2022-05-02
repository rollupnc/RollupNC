const treeHelper = require("./treeHelper.js");
const {utils} = require("ffjavascript");
const {stringifyBigInts, unstringifyBigInts} = utils;

module.exports = class Tree{

    constructor(
        _leafNodes
    ) {
        this.leafNodes = _leafNodes
        this.depth = treeHelper.getBase2Log(_leafNodes.length)
        this.innerNodes = this.treeFromLeafNodes()
        this.root = this.innerNodes[0][0]
    }

    updateInnerNodes(leaf, idx, merkle_path){
        // get position of affected inner nodes
        const depth = merkle_path.length;
        const proofPos = treeHelper.proofPos(idx, depth);
        const affectedPos = treeHelper.getAffectedPos(proofPos);
        console.log("affectedPos", proofPos, affectedPos, idx, depth)
        // get new values of affected inner nodes and update them
        const affectedInnerNodes = treeHelper.innerNodesFromLeafAndPath(leaf, idx, merkle_path);

        // update affected inner nodes
        for (var i = 1; i < depth + 1; i++){
            this.innerNodes[depth - i][affectedPos[i - 1]] = affectedInnerNodes[i - 1]
        }
    }

    treeFromLeafNodes(){
        var tree = Array(this.depth);
        tree[this.depth - 1] = treeHelper.pairwiseHash(this.leafNodes)

        for (var j = this.depth - 2; j >= 0; j--){
            tree[j] = treeHelper.pairwiseHash(tree[j+1])
        }
        return tree
    }

    getProof(leafIdx, depth = this.depth){
        const proofBinaryPos = treeHelper.idxToBinaryPos(leafIdx, depth);
        const proofPos = treeHelper.proofPos(leafIdx, depth);
        console.log("tree: proof pos", leafIdx, depth, proofPos)
        var proof = new Array(depth);
        proof[0] = this.leafNodes[proofPos[0]]
        for (var i = 1; i < depth; i++){
            proof[i] = this.innerNodes[depth - i][proofPos[i]]
        }
        return {
            proof: proof,
            proofPos: proofBinaryPos
        }
    }

    verifyProof(leafHash, idx, proof){
      //console.log("verify ", leafHash, proof)
        const computed_root = treeHelper.rootFromLeafAndPath(stringifyBigInts(leafHash), idx, stringifyBigInts(proof))
        return stringifyBigInts(this.root) == stringifyBigInts(computed_root);
    }

    findLeafIdxByHash(hash){
        const index = this.leafNodes.findIndex(leaf => leaf.hash == hash)
        return index;
    }
}
