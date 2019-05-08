pragma solidity >=0.4.21;

contract MiMC {

    function MiMCpe7(uint256,uint256) public pure returns(uint256) {}

}

contract MiMCMerkle{

    MiMC public mimc;
    uint public IV = 15021630795539610737508582392395901278341266317943626182700664337106830745361;

    constructor(
        address _mimcContractAddr
    ) public {
        mimc = MiMC(_mimcContractAddr);
    }

    function verifyMerkleProof(
        uint256 _leaf,
        uint256[2] memory _position,
        uint256[2] memory _proof,
        uint256 _claimedRoot
    ) public view returns(bool) {
        uint256[2] memory root;

        uint r = IV;

        // if leaf is left sibling
        if (_position[0] == 0){
            root[0] = mimc.MiMCpe7(mimc.MiMCpe7(r, _leaf), _proof[0]);
        } 
        // if leaf is right sibling
        else if (_position[0] == 1){
            root[0] = mimc.MiMCpe7(mimc.MiMCpe7(r, _proof[0]), _leaf);
        }

        for (uint i = 1; i < _proof.length; i++){
            // if leaf is left sibling
            if (_position[i] == 0){
                root[i] = mimc.MiMCpe7(mimc.MiMCpe7(r, root[i - 1]), _proof[i]);
            } 
            // if leaf is right sibling
            else if (_position[i] == 1){
                root[i] = mimc.MiMCpe7(mimc.MiMCpe7(r, _proof[i]), root[i - 1]);            }
            
        }
        return (_claimedRoot == root[root.length - 1]);
    }

    function hashTx(uint[6] memory array) public returns(uint){
        uint r = IV;
        for (uint i = 0; i < array.length; i++){
            r = mimc.MiMCpe7(r, array[i]);
        }
        return r;
    }
}
