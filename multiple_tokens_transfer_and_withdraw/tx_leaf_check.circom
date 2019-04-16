include "../circomlib/circuits/mimc.circom";
include "../circomlib/circuits/eddsamimc.circom";

template CheckTxLeaf(m) {

    signal input tx_enabled;

    // transaction information
    signal input tx_from_x; //sender address x coordinate
    signal input tx_from_y; //sender address y coordinate
    signal input tx_to_x; //receiver address x coordinate
    signal input tx_to_y; //receiver address y coordinate
    signal input tx_amount; // amount being transferred
    signal input tx_token_type_from; // sender token type
    signal input tx_token_type_to; // receiver token type

    signal input tx_R8x; // sender signature
    signal input tx_R8y; // sender signature
    signal input tx_S; // sender signature

    // Merkle root of transactions tree
    signal input tx_tx_root;

    // Merkle proof for transaction in tx tree
    signal input tx_paths2tx_root[m-1];

    // binary vector indicating whether node in tx proof is left or right
    signal input tx_paths2tx_root_pos[m-1];

    // constant zero address 
    var ZERO_ADDRESS_X = 0000000000000000000000000000000000000000000000000000000000000000000000000000;
    var ZERO_ADDRESS_Y = 00000000000000000000000000000000000000000000000000000000000000000000000000000;

    // check token types for non-withdraw transfers
    if (tx_to_x != ZERO_ADDRESS_X && tx_to_y != ZERO_ADDRESS_Y){
        tx_token_type_to === tx_token_type_from;
    }

    // hash of sender address, recipient address, amount, token type
    component tx = MultiMiMC7(6,91);
    tx.in[0] <== tx_from_x;
    tx.in[1] <== tx_from_y;
    tx.in[2] <== tx_to_x;
    tx.in[3] <== tx_to_y; 
    tx.in[4] <== tx_amount;
    tx.in[5] <== tx_token_type_from;

    // check that sender account signed transaction
    component verifier = EdDSAMiMCVerifier();   
    verifier.enabled <== 1;
    verifier.Ax <== tx_from_x;
    verifier.Ay <== tx_from_y;
    verifier.R8x <== tx_R8x
    verifier.R8y <== tx_R8y
    verifier.S <== tx_S;
    verifier.M <== tx.out;

    // hash of first two entries in tx Merkle proof
    component tx_merkle_root[m-1];
    tx_merkle_root[0] = MultiMiMC7(2,91);
    tx_merkle_root[0].in[0] <== tx.out - tx_paths2tx_root_pos[0]* (tx.out - tx_paths2tx_root[0]);
    tx_merkle_root[0].in[1] <== tx_paths2tx_root[0] - tx_paths2tx_root_pos[0]* (tx_paths2tx_root[0] - tx.out);
    
    // hash of all other entries in tx Merkle proof
    for (var k = 1; k < m - 1; k++){
    	tx_merkle_root[k] = MultiMiMC7(2,91);
    	tx_merkle_root[k].in[0] <== tx_merkle_root[k-1].out - tx_paths2tx_root_pos[k]* (tx_merkle_root[k-1].out - tx_paths2tx_root[k]);
    	tx_merkle_root[k].in[1] <== tx_paths2tx_root[k] - tx_paths2tx_root_pos[k]* (tx_paths2tx_root[k] - tx_merkle_root[k-1].out);
    }

    // equality constraint: input tx root === computed tx root 
    component eqCheck = ForceEqualIfEnabled();
    eqCheck.enabled <== tx_enabled;
    eqCheck.in[0] <== tx_tx_root
    eqCheck.in[1] <== tx_merkle_root[m-2].out;

}