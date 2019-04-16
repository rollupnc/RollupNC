include "../circomlib/circuits/mimc.circom";
include "../circomlib/circuits/eddsamimc.circom";
include "../circomlib/circuits/bitify.circom";

template Main(n,m) {

    // Merkle root of transactions tree
    signal input tx_root;

    // Merkle proof for transaction in tx tree
    signal private input paths2tx_root[m-1];

    // binary vector indicating whether node in tx proof is left or right
    signal private input paths2tx_root_pos[m-1];

    // Merkle root of old balance tree
    signal input current_state;

    // Merkle proof for sender account in old balance tree
    signal private input paths2old_root_from[n-1];

    // Merkle proof for receiver account in old balance tree
    signal private input paths2old_root_to[n-1];

    // Merkle proof for sender account in new balance tree
    signal private input paths2new_root_from[n-1];

    // Merkle proof for receiver account in new balance tree
    signal private input paths2new_root_to[n-1];

    // binary vector indicating whether node in balance proof for sender account
    // is left or right 
    signal private input paths2root_from_pos[n-1];

    // binary vector indicating whether node in balance proof for receiver account
    // is left or right 
    signal private input paths2root_to_pos[n-1];
    
    signal private input from_x; //sender address x coordinate
    signal private input from_y; //sender address y coordinate
    signal private input R8x; // sender signature
    signal private input R8y; // sender signature
    signal private input S; // sender signature

    signal private input nonce_from; // sender account nonce
    signal private input to_x; // receiver address x coordinate
    signal private input to_y; // receiver address y coordinate
    signal private input nonce_to; // receiver account nonce
    signal private input amount; // amount being transferred

    signal private input token_balance_from; // sender token balance
    signal private input token_balance_to; // receiver token balance
    signal private input token_type_from; // sender token type
    signal private input token_type_to; // receiver token type

    // new balance tree Merkle root
    signal output out;

    var i;

    var NONCE_MAX_VALUE = 100;

    // // constant zero address (EdDSA public key derived from "0x00000..." private key)
    // var ZERO_ADDRESS_X = 14693049754975295088601889058423528175209346965458018166282702079546899756033;
    // var ZERO_ADDRESS_Y = 2567899521534891726544025877709012721621806025758268445301366801784237662454;

    // constant zero address 
    var ZERO_ADDRESS_X = 0000000000000000000000000000000000000000000000000000000000000000000000000000;
    var ZERO_ADDRESS_Y = 00000000000000000000000000000000000000000000000000000000000000000000000000000;

    // transactions existence check

    // hash of sender address, recipient address, amount, token type
    component tx = MultiMiMC7(6,91);
    tx.in[0] <== from_x;
    tx.in[1] <== from_y;
    tx.in[2] <== to_x;
    tx.in[3] <== to_y; 
    tx.in[4] <== amount;
    tx.in[5] <== token_type_from;

    // hash of first two entries in tx Merkle proof
    component tx_merkle_root[m-1];
    tx_merkle_root[0] = MultiMiMC7(2,91);
    tx_merkle_root[0].in[0] <== tx.out - paths2tx_root_pos[0]* (tx.out - paths2tx_root[0]);
    tx_merkle_root[0].in[1] <== paths2tx_root[0] - paths2tx_root_pos[0]* (paths2tx_root[0] - tx.out);
    
    // hash of all other entries in tx Merkle proof
    for (i=1; i<m-1; i++){
    	tx_merkle_root[i] = MultiMiMC7(2,91);
    	tx_merkle_root[i].in[0] <== tx_merkle_root[i-1].out - paths2tx_root_pos[i]* (tx_merkle_root[i-1].out - paths2tx_root[i]);
    	tx_merkle_root[i].in[1] <== paths2tx_root[i] - paths2tx_root_pos[i]* (paths2tx_root[i] - tx_merkle_root[i-1].out);
    }

    // equality constraint: input tx root === computed tx root 
    tx_root === tx_merkle_root[m-2].out;
    
    // accounts existence check

    // hash of sender address, balance, nonce, token type
    component old_hash_from = MultiMiMC7(5,91);
    old_hash_from.in[0] <== from_x;
    old_hash_from.in[1] <== from_y
    old_hash_from.in[2] <== token_balance_from;
    old_hash_from.in[3] <== nonce_from;
    old_hash_from.in[4] <== token_type_from;


    // hash of first two entries in balance Merkle proof for sender account
    component old_merkle_from[n-1];
    old_merkle_from[0] = MultiMiMC7(2,91);
    old_merkle_from[0].in[0] <== old_hash_from.out - paths2root_from_pos[0]* (old_hash_from.out - paths2old_root_from[0]);
    old_merkle_from[0].in[1] <== paths2old_root_from[0] - paths2root_from_pos[0]* (paths2old_root_from[0] - old_hash_from.out);
    
    // hash of all other entries in balance Merkle proof for sender account
    for (i=1; i<n-1; i++){
    	old_merkle_from[i] = MultiMiMC7(2,91);
    	old_merkle_from[i].in[0] <== old_merkle_from[i-1].out - paths2root_from_pos[i]* (old_merkle_from[i-1].out - paths2old_root_from[i]);
    	old_merkle_from[i].in[1] <== paths2old_root_from[i] - paths2root_from_pos[i]* (paths2old_root_from[i] - old_merkle_from[i-1].out);
    }

    // equality constraint: input old balance root === computed old balance root from sender account
    current_state === old_merkle_from[n-2].out;

    // hash of receiver address, balance, nonce, token type
    component old_hash_to = MultiMiMC7(5,91);
    old_hash_to.in[0] <== to_x;
    old_hash_to.in[1] <== to_y;
    old_hash_to.in[2] <== token_balance_to;
    old_hash_to.in[3] <== nonce_to;
    old_hash_to.in[4] <== token_type_to;

    // hash of first two entries in balance Merkle proof for receiver account
    component old_merkle_to[n-1];
    old_merkle_to[0] = MultiMiMC7(2,91);
    old_merkle_to[0].in[0] <== old_hash_to.out - paths2root_to_pos[0]* (old_hash_to.out - paths2old_root_to[0]);
    old_merkle_to[0].in[1] <== paths2old_root_to[0] - paths2root_to_pos[0]* (paths2old_root_to[0] - old_hash_to.out);

     // hash of all other entries in balance Merkle proof for receiver account   
    for (i=1; i<n-1; i++){
    	old_merkle_to[i] = MultiMiMC7(2,91);
    	old_merkle_to[i].in[0] <== old_merkle_to[i-1].out - paths2root_to_pos[i]* (old_merkle_to[i-1].out - paths2old_root_to[i]);
    	old_merkle_to[i].in[1] <== paths2old_root_to[i] - paths2root_to_pos[i]* (paths2old_root_to[i] - old_merkle_to[i-1].out);
    }

    // equality constraint: input old balance root === computed old balance root from receiver account
    current_state === old_merkle_to[n-2].out;

    // check that sender account signed transaction
    component verifier = EdDSAMiMCVerifier();   
    verifier.enabled <== 1;
    verifier.Ax <== from_x;
    verifier.Ay <== from_y;
    verifier.R8x <== R8x
    verifier.R8y <== R8y
    verifier.S <== S;
    verifier.M <== tx.out;
    
    // balance checks
    token_balance_from-amount <= token_balance_from;
    token_balance_to + amount >= token_balance_to;

    nonce_from != NONCE_MAX_VALUE;

    // check token types for non-withdraw transfers
    if (to_x != ZERO_ADDRESS_X && to_y != ZERO_ADDRESS_Y){
        token_type_to === token_type_from;
    }


    // accounts updates

    // subtract amount from sender balance; increase sender nonce
    component new_hash_from = MultiMiMC7(5,91);
    new_hash_from.in[0] <== from_x;
    new_hash_from.in[1] <== from_y;
    new_hash_from.in[2] <== token_balance_from-amount;
    new_hash_from.in[3] <== nonce_from+1;
    new_hash_from.in[4] <== token_type_from;
    
    // hash new sender leaf with original path to get new balance root
	component new_merkle_from[n-1];
    new_merkle_from[0] = MultiMiMC7(2,91);
    new_merkle_from[0].in[0] <== new_hash_from.out - paths2root_from_pos[0]* (new_hash_from.out - paths2new_root_from[0]);
    new_merkle_from[0].in[1] <== paths2new_root_from[0] - paths2root_from_pos[0]* (paths2new_root_from[0] - new_hash_from.out);
    
    for (i=1; i<n-1; i++){
    	new_merkle_from[i] = MultiMiMC7(2,91);
    	new_merkle_from[i].in[0] <== new_merkle_from[i-1].out - paths2root_from_pos[i]* (new_merkle_from[i-1].out - paths2new_root_from[i]);
    	new_merkle_from[i].in[1] <== paths2new_root_from[i] - paths2root_from_pos[i]* (paths2new_root_from[i] - new_merkle_from[i-1].out);
    }

    // add amount to receiver balance
    // if receiver is zero address, do not change balance
    component new_hash_to = MultiMiMC7(5,91);
    new_hash_to.in[0] <== to_x;
    new_hash_to.in[1] <== to_y;
    if (to_x != ZERO_ADDRESS_X && to_y != ZERO_ADDRESS_Y){
        new_hash_to.in[2] <== token_balance_to+amount;
    }
    if (to_x == ZERO_ADDRESS_X && to_y == ZERO_ADDRESS_Y){
        new_hash_to.in[2] <== token_balance_to;
    }
    new_hash_to.in[3] <== nonce_to;
    new_hash_to.in[4] <== token_type_to;
    
    // hash new receiver leaf with original path to get new balance root
	component new_merkle_to[n-1];
    new_merkle_to[0] = MultiMiMC7(2,91);
    new_merkle_to[0].in[0] <== new_hash_to.out - paths2root_to_pos[0]* (new_hash_to.out - paths2new_root_to[0]);
    new_merkle_to[0].in[1] <== paths2new_root_to[0] - paths2root_to_pos[0]* (paths2new_root_to[0] - new_hash_to.out);
    
    for (i=1; i<n-1; i++){
    	new_merkle_to[i] = MultiMiMC7(2,91);
    	new_merkle_to[i].in[0] <== new_merkle_to[i-1].out - paths2root_to_pos[i]* (new_merkle_to[i-1].out - paths2new_root_to[i]);
    	new_merkle_to[i].in[1] <== paths2new_root_to[i] - paths2root_to_pos[i]* (paths2new_root_to[i] - new_merkle_to[i-1].out);
    }

    // new root computed from new sender and receiver leaves should be the same
   	new_merkle_from[n-2].out === new_merkle_to[n-2].out
    
    // circuit outputs new balance root
    out <== new_merkle_to[n-2].out;

    }

component main = Main(6,4);