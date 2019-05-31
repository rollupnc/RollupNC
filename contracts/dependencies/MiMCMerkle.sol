pragma solidity >=0.4.21;

contract MiMC {

    function MiMCpe7(uint256,uint256) public pure returns(uint256) {}

}

contract MiMCMerkle{

    MiMC public mimc;
    uint public IV = 15021630795539610737508582392395901278341266317943626182700664337106830745361;
    // hashes for empty tree of depth 16
    uint[16] public zeroCache = [
        17400342990847699622034895903486521563192531922107760411846337521891653711537, //H0 = empty leaf
        6113825327972579408082802166670133747202624653742570870320185423954556080212,  //H1 = hash(H0, H0)
        6180012883826996691682233524035352980520561433337754209809143632670877151717,  //H2 = hash(H1, H1)
        20633846227573655562891472654875498275532732787736199734105126629336915134506, //...and so on
        19963324565646943143661364524780633879811696094118783241060299022396942068715,
        9116305404554493188667682829032875002375650300019536938573543070513751528350,
        15759141913656962485350219473258363918430940625851304374292752988970572480078,
        12082545087695303090197913216896657397127733286321080287975447885375320633190,
        8653943635473922476177354127568428820046791852493483066721332253466432540317,
        16691853928129235849618252688899225128086495735956963513366372534133282112184,
        18335689325733187151724957795577014689145166048677804628669634192033325197111,
        18858636268996040430960602170855166200865641605541888749083720058663983750970,
        17690162382247018792698036814626403776337849021815306424276618020510837348597,
        20110079130341111047913826323165708463208283589536845070351411561199177673167,
        2345493422951287429713570628020003478520312721101703109046832176189684637348,
        14524096407381902470594287796808492262785775277701891268019187914977794838609
    ];

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

    function hashBalance(uint[5] memory array) public returns(uint){
        //[pubkey_x, pubkey_y, balance, nonce, token_type]
        uint r = IV;
        for (uint i = 0; i < array.length; i++){
            r = mimc.MiMCpe7(r, array[i]);
        }
        return r;
    }

    function hashTx(uint[6] memory array) public returns(uint){
        //[from_x, from_y, to_x, to_y, amt, token_type]
        uint r = IV;
        for (uint i = 0; i < array.length; i++){
            r = mimc.MiMCpe7(r, array[i]);
        }
        return r;
    }

    function hashWithdraw(uint[2] memory array) public returns(uint){
        uint r = IV;
        for (uint i = 0; i < array.length; i++){
            r = mimc.MiMCpe7(r, array[i]);
        }
        return r;
    }
}
