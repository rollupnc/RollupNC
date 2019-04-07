include "../circomlib/circuits/mimc.circom";
include "../circomlib/circuits/eddsamimc.circom";
include "../circomlib/circuits/bitify.circom";

template Main(n,m) {

    signal input tx_root;

    signal private input paths2tx_root[m-1];

    signal private input paths2tx_root_pos[m-1];

    signal input current_state;

    signal private input paths2old_root_from[n-1];
    signal private input paths2old_root_to[n-1];
    signal private input paths2new_root_from[n-1];
    signal private input paths2new_root_to[n-1];

    signal private input paths2root_from_pos[n-1];
    signal private input paths2root_to_pos[n-1];
    
    signal private input from_x;
    signal private input from_y;
    signal private input R8x;
    signal private input R8y;
    signal private input S;

    signal private input nonce_from;
    signal private input to_x;
    signal private input to_y;
    signal private input nonce_to;
    signal private input amount;

    signal private input token_balance_from;
    signal private input token_balance_to;
    signal private input token_type_from;
    signal private input token_type_to;

    signal output out;

    var i;

    var NONCE_MAX_VALUE = 100;

    var ZERO_ADDRESS_X = 14693049754975295088601889058423528175209346965458018166282702079546899756033;
    var ZERO_ADDRESS_Y = 2567899521534891726544025877709012721621806025758268445301366801784237662454;


    // transactions existence check
    component tx = MultiMiMC7(6,91);
    tx.in[0] <== from_x;
    tx.in[1] <== from_y;
    tx.in[2] <== to_x;
    tx.in[3] <== to_y; 
    tx.in[4] <== amount;
    tx.in[5] <== token_type_from;

    component tx_merkle_root[m-1];
    tx_merkle_root[0] = MultiMiMC7(2,91);
    tx_merkle_root[0].in[0] <== tx.out - paths2tx_root_pos[0]* (tx.out - paths2tx_root[0]);
    tx_merkle_root[0].in[1] <== paths2tx_root[0] - paths2tx_root_pos[0]* (paths2tx_root[0] - tx.out);
    
    for (i=1; i<m-1; i++){
    	tx_merkle_root[i] = MultiMiMC7(2,91);
    	tx_merkle_root[i].in[0] <== tx_merkle_root[i-1].out - paths2tx_root_pos[i]* (tx_merkle_root[i-1].out - paths2tx_root[i]);
    	tx_merkle_root[i].in[1] <== paths2tx_root[i] - paths2tx_root_pos[i]* (paths2tx_root[i] - tx_merkle_root[i-1].out);
    }

    tx_root === tx_merkle_root[m-2].out;
    
    // accounts existence check
    component old_hash_from = MultiMiMC7(5,91);
    old_hash_from.in[0] <== from_x;
    old_hash_from.in[1] <== from_y
    old_hash_from.in[2] <== token_balance_from;
    old_hash_from.in[3] <== nonce_from;
    old_hash_from.in[4] <== token_type_from;

    component old_merkle_from[n-1];
    old_merkle_from[0] = MultiMiMC7(2,91);
    old_merkle_from[0].in[0] <== old_hash_from.out - paths2root_from_pos[0]* (old_hash_from.out - paths2old_root_from[0]);
    old_merkle_from[0].in[1] <== paths2old_root_from[0] - paths2root_from_pos[0]* (paths2old_root_from[0] - old_hash_from.out);
    
    for (i=1; i<n-1; i++){
    	old_merkle_from[i] = MultiMiMC7(2,91);
    	old_merkle_from[i].in[0] <== old_merkle_from[i-1].out - paths2root_from_pos[i]* (old_merkle_from[i-1].out - paths2old_root_from[i]);
    	old_merkle_from[i].in[1] <== paths2old_root_from[i] - paths2root_from_pos[i]* (paths2old_root_from[i] - old_merkle_from[i-1].out);
    }

    current_state === old_merkle_from[n-2].out;

    component old_hash_to = MultiMiMC7(5,91);
    old_hash_to.in[0] <== to_x;
    old_hash_to.in[1] <== to_y;
    old_hash_to.in[2] <== token_balance_to;
    old_hash_to.in[3] <== nonce_to;
    old_hash_to.in[4] <== token_type_to;

    component old_merkle_to[n-1];
    old_merkle_to[0] = MultiMiMC7(2,91);
    old_merkle_to[0].in[0] <== old_hash_to.out - paths2root_to_pos[0]* (old_hash_to.out - paths2old_root_to[0]);
    old_merkle_to[0].in[1] <== paths2old_root_to[0] - paths2root_to_pos[0]* (paths2old_root_to[0] - old_hash_to.out);
    
    for (i=1; i<n-1; i++){
    	old_merkle_to[i] = MultiMiMC7(2,91);
    	old_merkle_to[i].in[0] <== old_merkle_to[i-1].out - paths2root_to_pos[i]* (old_merkle_to[i-1].out - paths2old_root_to[i]);
    	old_merkle_to[i].in[1] <== paths2old_root_to[i] - paths2root_to_pos[i]* (paths2old_root_to[i] - old_merkle_to[i-1].out);
    }

    current_state === old_merkle_to[n-2].out;

    // authorization check
    component verifier = EdDSAMiMCVerifier();   
    verifier.enabled <== 1;
    verifier.Ax <== from_x;
    verifier.Ay <== from_y;
    verifier.R8x <== R8x
    verifier.R8y <== R8y
    verifier.S <== S;
    verifier.M <== old_hash_from.out;
    
    // balance checks
    token_balance_from-amount <= token_balance_from;
    token_balance_to + amount >= token_balance_to;

    nonce_from != NONCE_MAX_VALUE;

    // check token types for non-withdraw transfers
    if (to_x != ZERO_ADDRESS_X && to_y != ZERO_ADDRESS_Y){
        token_type_to === token_type_from;
    }


    // accounts updates
    component new_hash_from = MultiMiMC7(5,91);
    new_hash_from.in[0] <== from_x;
    new_hash_from.in[1] <== from_y;
    new_hash_from.in[2] <== token_balance_from-amount;
    new_hash_from.in[3] <== nonce_from+1;
    new_hash_from.in[4] <== token_type_from;
    
	component new_merkle_from[n-1];
    new_merkle_from[0] = MultiMiMC7(2,91);
    new_merkle_from[0].in[0] <== new_hash_from.out - paths2root_from_pos[0]* (new_hash_from.out - paths2new_root_from[0]);
    new_merkle_from[0].in[1] <== paths2new_root_from[0] - paths2root_from_pos[0]* (paths2new_root_from[0] - new_hash_from.out);
    
    for (i=1; i<n-1; i++){
    	new_merkle_from[i] = MultiMiMC7(2,91);
    	new_merkle_from[i].in[0] <== new_merkle_from[i-1].out - paths2root_from_pos[i]* (new_merkle_from[i-1].out - paths2new_root_from[i]);
    	new_merkle_from[i].in[1] <== paths2new_root_from[i] - paths2root_from_pos[i]* (paths2new_root_from[i] - new_merkle_from[i-1].out);
    }

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
    

	component new_merkle_to[n-1];
    new_merkle_to[0] = MultiMiMC7(2,91);
    new_merkle_to[0].in[0] <== new_hash_to.out - paths2root_to_pos[0]* (new_hash_to.out - paths2new_root_to[0]);
    new_merkle_to[0].in[1] <== paths2new_root_to[0] - paths2root_to_pos[0]* (paths2new_root_to[0] - new_hash_to.out);
    
    for (i=1; i<n-1; i++){
    	new_merkle_to[i] = MultiMiMC7(2,91);
    	new_merkle_to[i].in[0] <== new_merkle_to[i-1].out - paths2root_to_pos[i]* (new_merkle_to[i-1].out - paths2new_root_to[i]);
    	new_merkle_to[i].in[1] <== paths2new_root_to[i] - paths2root_to_pos[i]* (paths2new_root_to[i] - new_merkle_to[i-1].out);
    	}

   	new_merkle_from[n-2].out === new_merkle_to[n-2].out
    
    out <== new_merkle_to[n-2].out;

    }

component main = Main(6,4);