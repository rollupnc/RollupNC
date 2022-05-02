// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

contract MiMC {

    function MiMCpe7(uint256,uint256) public pure returns(uint256) {}

}

contract MiMCMerkle{

    MiMC public mimc;
    uint public IV = 15021630795539610737508582392395901278341266317943626182700664337106830745361;
    // hashes for empty tree of depth 16
    uint[5] public zeroCache = [
        17400342990847699622034895903486521563192531922107760411846337521891653711537, //H0 = empty leaf
        6113825327972579408082802166670133747202624653742570870320185423954556080212,  //H1 = hash(H0, H0)
        6180012883826996691682233524035352980520561433337754209809143632670877151717,  //H2 = hash(H1, H1)
        20633846227573655562891472654875498275532732787736199734105126629336915134506, //...and so on
        19963324565646943143661364524780633879811696094118783241060299022396942068715
    ];

    constructor(
        address _mimcContractAddr
    ) public {
        mimc = MiMC(_mimcContractAddr);
    }

    function getRootFromProof(
        uint256 _leaf,
        uint256[] memory _position,
        uint256[] memory _proof
    ) public view returns(uint) {

        uint256[] memory root = new uint256[](_proof.length);

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
                root[i] = mimc.MiMCpe7(mimc.MiMCpe7(r, _proof[i]), root[i - 1]);
            }
        }

        // return (_claimedRoot == root[root.length - 1]);
        return root[root.length - 1];

    }

    function hashMiMC(uint[] memory array) public view returns(uint){
        //[pubkey_x, pubkey_y, balance, nonce, token_type]
        uint r = IV;
        for (uint i = 0; i < array.length; i++){
            r = mimc.MiMCpe7(r, array[i]);
        }
        return r;
    }

}
