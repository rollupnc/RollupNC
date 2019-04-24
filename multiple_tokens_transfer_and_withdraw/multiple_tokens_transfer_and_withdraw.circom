include "../circomlib/circuits/mimc.circom";
include "../circomlib/circuits/eddsamimc.circom";
include "../circomlib/circuits/bitify.circom";
include "./tx_existence_check.circom";
include "./balance_existence_check.circom";
include "./balance_leaf.circom";
include "./get_merkle_root.circom";

template Main(n,m) {
// n is depth of balance tree
// m is depth of transactions tree
// for each proof, update 2**m transactions

    // Merkle root of transactions tree
    signal input tx_root;

    // Merkle proof for transaction in tx tree
    signal private input paths2tx_root[2**m, m];

    // binary vector indicating whether node in tx proof is left or right
    signal private input paths2tx_root_pos[2**m, m];

    // Merkle root of old balance tree
    signal input current_state;

    // intermediate roots
    signal private input intermediate_roots[2**m];

    // Merkle proof for sender account in old balance tree
    signal private input paths2old_root_from[2**m, n];

    // Merkle proof for receiver account in old balance tree
    signal private input paths2old_root_to[2**m, n];

    // Merkle proof for sender account in new balance tree
    signal private input paths2new_root_from[2**m, n];

    // Merkle proof for receiver account in new balance tree
    signal private input paths2new_root_to[2**m, n];

    // binary vector indicating whether node in balance proof for sender account
    // is left or right 
    signal private input paths2root_from_pos[2**m, n];

    // binary vector indicating whether node in balance proof for receiver account
    // is left or right 
    signal private input paths2root_to_pos[2**m, n];
    
    signal private input from_x[2**m]; //sender address x coordinate
    signal private input from_y[2**m]; //sender address y coordinate
    signal private input R8x[2**m]; // sender signature
    signal private input R8y[2**m]; // sender signature
    signal private input S[2**m]; // sender signature

    signal private input nonce_from[2**m]; // sender account nonce
    signal private input to_x[2**m]; // receiver address x coordinate
    signal private input to_y[2**m]; // receiver address y coordinate
    signal private input nonce_to[2**m]; // receiver account nonce
    signal private input amount[2**m]; // amount being transferred

    signal private input token_balance_from[2**m]; // sender token balance
    signal private input token_balance_to[2**m]; // receiver token balance
    signal private input token_type_from[2**m]; // sender token type
    signal private input token_type_to[2**m]; // receiver token type

    // new balance tree Merkle root
    signal output out;

    var NONCE_MAX_VALUE = 100;

    // constant zero address
                         
    var ZERO_ADDRESS_X = 0000000000000000000000000000000000000000000000000000000000000000000000000000;
    var ZERO_ADDRESS_Y = 00000000000000000000000000000000000000000000000000000000000000000000000000000;

    
    // component txExistence[2**m - 1];
    // component senderExistence[2**m - 1];
    // component receiverExistence[2**m - 1];
    // component newSenderExistence[2**m - 1];
    // component newReceiverExistence[2**m - 1];

    // for (var i = 0; i < 2**m - 1; i++) {

    //     // transactions existence and signature check
    //     txExistence[i] = TxExistence(m);
    //     txExistence[i].from_x <== from_x[i];
    //     txExistence[i].from_y <== from_y[i];
    //     txExistence[i].to_x <== to_x[i];
    //     txExistence[i].to_y <== to_y[i];
    //     txExistence[i].amount <== amount[i];
    //     txExistence[i].token_type_from <== token_type_from[i];

    //     txExistence[i].tx_root <== tx_root;

    //     for (var j = 0; j < m; j++){
    //         txExistence[i].paths2_root_pos[j] <== paths2tx_root_pos[i, j] ;
    //         txExistence[i].paths2_root[j] <== paths2tx_root[i, j];
    //     }

    //     txExistence[i].R8x <== R8x[i];
    //     txExistence[i].R8y <== R8y[i];
    //     txExistence[i].S <== S[i];
    
    //     // accounts existence check

    //     // for sender address
    //     senderExistence[i] = BalanceExistence(n);
    //     senderExistence[i].x <== from_x[i];
    //     senderExistence[i].y <== from_y[i];
    //     senderExistence[i].token_balance <== token_balance_from[i];
    //     senderExistence[i].nonce <== nonce_from[i];
    //     senderExistence[i].token_type <== token_type_from[i];

    //     senderExistence[i].balance_root <== intermediate_roots[i];
    //     for (var j = 0; j < n; j++){
    //         senderExistence[i].paths2_root_pos[j] <== paths2root_from_pos[i, j];
    //         senderExistence[i].paths2_root[j] <== paths2old_root_from[i, j];
    //     }

    //     // for receiver address
    //     receiverExistence[i] = BalanceExistence(n);
    //     receiverExistence[i].x <== to_x[i];
    //     receiverExistence[i].y <== to_y[i];
    //     receiverExistence[i].token_balance <== token_balance_to[i];
    //     receiverExistence[i].nonce <== nonce_to[i];
    //     receiverExistence[i].token_type <== token_type_to[i];

    //     receiverExistence[i].balance_root <== intermediate_roots[i];
    //     for (var j = 0; j < n; j++){
    //         receiverExistence[i].paths2_root_pos[j] <== paths2root_to_pos[i, j] ;
    //         receiverExistence[i].paths2_root[j] <== paths2old_root_to[i, j];
    //     }
    
    //     // balance checks
    //     token_balance_from[i] - amount[i] <= token_balance_from[i];
    //     token_balance_to[i] + amount[i] >= token_balance_to[i];

    //     nonce_from[i] != NONCE_MAX_VALUE;

    //     // check token types for non-withdraw transfers
    //     if (to_x[i] != ZERO_ADDRESS_X && to_y[i] != ZERO_ADDRESS_Y){
    //         token_type_to[i] === token_type_from[i];
    //     }

    //     // accounts updates and existence checks

    //     // for new sender balance
    //     // subtract amount from sender balance; increase sender nonce 
    //     newSenderExistence[i] = BalanceExistence(n);
    //     newSenderExistence[i].x <== from_x[i];
    //     newSenderExistence[i].y <== from_y[i];
    //     newSenderExistence[i].token_balance <== token_balance_from[i] - amount[i];
    //     newSenderExistence[i].nonce <== nonce_from[i] + 1;
    //     newSenderExistence[i].token_type <== token_type_from[i];

    //     newSenderExistence[i].balance_root <== intermediate_roots[i + 1];
    //     for (var j = 0; j < n; j++){
    //         newSenderExistence[i].paths2_root_pos[j] <== paths2root_from_pos[i, j] ;
    //         newSenderExistence[i].paths2_root[j] <== paths2new_root_from[i, j];
    //     }

    //     // for new receiver balance
    //     // add amount to receiver balance
    //     // if receiver is zero address, do not change balance
    //     newReceiverExistence[i] = BalanceExistence(n);
    //     newReceiverExistence[i].x <== to_x[i];
    //     newReceiverExistence[i].y <== to_y[i];
    //     if (to_x[i] == ZERO_ADDRESS_X && to_y[i] == ZERO_ADDRESS_Y){
    //         newReceiverExistence[i].token_balance <== token_balance_to[i];
    //     }
    //     if (to_x[i] != ZERO_ADDRESS_X && to_y[i] != ZERO_ADDRESS_Y){
    //         newReceiverExistence[i].token_balance <== token_balance_to[i] + amount[i];
    //     }
    //     newReceiverExistence[i].nonce <== nonce_to[i];
    //     newReceiverExistence[i].token_type <== token_type_to[i];

    //     newReceiverExistence[i].balance_root <== intermediate_roots[i + 1];
    //     for (var j = 0; j < n; j++){
    //         newReceiverExistence[i].paths2_root_pos[j] <== paths2root_to_pos[i, j] ;
    //         newReceiverExistence[i].paths2_root[j] <== paths2new_root_to[i, j];
    //     }
    // }

    // final transactions existence and signature check
    component finalTxExistence = TxExistence(m);
    finalTxExistence.from_x <== from_x[2**m - 1];
    finalTxExistence.from_y <== from_y[2**m - 1];
    finalTxExistence.to_x <== to_x[2**m - 1];
    finalTxExistence.to_y <== to_y[2**m - 1];
    finalTxExistence.amount <== amount[2**m - 1];
    finalTxExistence.token_type_from <== token_type_from[2**m - 1];

    finalTxExistence.tx_root <== tx_root;

    for (var j = 0; j < m; j++){
        finalTxExistence.paths2_root_pos[j] <== paths2tx_root_pos[2**m - 1, j] ;
        finalTxExistence.paths2_root[j] <== paths2tx_root[2**m - 1, j];
    }

    finalTxExistence.R8x <== R8x[2**m - 1];
    finalTxExistence.R8y <== R8y[2**m - 1];
    finalTxExistence.S <== S[2**m - 1];

    // final sender existence check
    component final_sender_existence = BalanceExistence(n);
    final_sender_existence.x <== from_x[2**m - 1];
    final_sender_existence.y <== from_y[2**m - 1];
    final_sender_existence.token_balance <== token_balance_from[2**m - 1];
    final_sender_existence.nonce <== nonce_from[2**m - 1];
    final_sender_existence.token_type <== token_type_from[2**m - 1]
    
    final_sender_existence.balance_root <== intermediate_roots[2**m - 1];

    for (var j = 0; j < n; j++){
        final_sender_existence.paths2_root_pos[j] <== paths2root_to_pos[2**m - 1, j] ;
        final_sender_existence.paths2_root[j] <== paths2old_root_to[2**m - 1, j];
    }

    // final receiver existence check
    component final_receiver_existence = BalanceExistence(n);
    final_receiver_existence.x <== to_x[2**m - 1];
    final_receiver_existence.y <== to_y[2**m - 1];
    final_receiver_existence.token_balance <== token_balance_to[2**m - 1];
    final_receiver_existence.nonce <== nonce_to[2**m - 1];
    final_receiver_existence.token_type <== token_type_to[2**m - 1];
    final_receiver_existence.balance_root <== intermediate_roots[2**m - 1];
    for (var j = 0; j < n; j++){
        final_receiver_existence.paths2_root_pos[j] <== paths2root_to_pos[2**m - 1, j] ;
        final_receiver_existence.paths2_root[j] <== paths2old_root_to[2**m - 1, j];
    }

 

    // final balance checks
    token_balance_from[2**m - 1] - amount[2**m - 1] <= token_balance_from[2**m - 1];
    token_balance_to[2**m - 1] + amount[2**m - 1] >= token_balance_to[2**m - 1];

    nonce_from[2**m - 1] != NONCE_MAX_VALUE;

    // check token types for non-withdraw transfers
    if (to_x[2**m - 1] != ZERO_ADDRESS_X && to_y[2**m - 1] != ZERO_ADDRESS_Y){
        token_type_to[2**m - 1] === token_type_from[2**m - 1];
    }

    component new_final_sender = BalanceLeaf();
    new_final_sender.x <== from_x[2**m - 1];
    new_final_sender.y <== from_y[2**m - 1];
    new_final_sender.token_balance <== token_balance_from[2**m - 1] - amount[2**m - 1];
    new_final_sender.nonce <== nonce_from[2**m - 1] + 1;
    new_final_sender.token_type <== token_type_from[2**m - 1];

    component new_merkle_root_from_final_sender = GetMerkleRoot(n);
    new_merkle_root_from_final_sender.leaf <== new_final_sender.out;
    for (var j = 0; j < n; j++){
        new_merkle_root_from_final_sender.paths2_root[j] <== paths2new_root_from[2**m - 1, j];
        new_merkle_root_from_final_sender.paths2_root_pos[j] <== paths2root_from_pos[2**m - 1, j];
    }

    component new_final_receiver = BalanceLeaf();
    new_final_receiver.x <== to_x[2**m - 1];
    new_final_receiver.y <== to_y[2**m - 1];
    if (to_x[2**m - 1] == ZERO_ADDRESS_X && to_y[2**m - 1] == ZERO_ADDRESS_Y){
        new_final_receiver.token_balance <== token_balance_to[2**m - 1];
    }
    if (to_x[2**m - 1] != ZERO_ADDRESS_X && to_y[2**m - 1] != ZERO_ADDRESS_Y){
        new_final_receiver.token_balance <== token_balance_to[2**m - 1] + amount[2**m - 1];
    }
    new_final_receiver.nonce <== nonce_to[2**m - 1];
    new_final_receiver.token_type <== token_type_to[2**m - 1];

    component new_merkle_root_from_final_receiver = GetMerkleRoot(n);
    new_merkle_root_from_final_receiver.leaf <== new_final_receiver.out;
    for (var j = 0; j < n; j++){
        new_merkle_root_from_final_receiver.paths2_root[j] <== paths2new_root_to[2**m - 1, j];
        new_merkle_root_from_final_receiver.paths2_root_pos[j] <== paths2root_to_pos[2**m - 1, j];
    }

    new_merkle_root_from_final_sender.out === new_merkle_root_from_final_receiver.out;   

    // circuit outputs new balance root
    out <== new_merkle_root_from_final_sender.out;

}

component main = Main(2,2);