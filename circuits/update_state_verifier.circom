include "../circomlib/circuits/mimc.circom";
include "../circomlib/circuits/eddsamimc.circom";
include "../circomlib/circuits/bitify.circom";
include "../circomlib/circuits/comparators.circom";
include "./helpers/tx_existence_check.circom";
include "./helpers/balance_existence_check.circom";
include "./helpers/balance_leaf.circom";
include "./helpers/get_merkle_root.circom";
include "./helpers/if-gadgets.circom";

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

    // intermediate roots (two for each tx), final element is last.
    signal private input intermediate_roots[2**(m+1)+1];

    // Merkle proof for sender account in balance tree
    signal private input paths2root_from[2**m, n];

    // Merkle proof for receiver account in balance tree
    signal private input paths2root_to[2**m, n];

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

    
    component txExistence[2**m];
    component senderExistence[2**m];
    component ifBothHighForceEqual[2**m];
    component newSender[2**m];
    component merkle_root_from_new_sender[2**m];
    component receiverExistence[2**m];
    component newReceiver[2**m];
    component allLow[2**m];
    component ifThenElse[2**m];
    component merkle_root_from_new_receiver[2**m];

    current_state === intermediate_roots[0];

    for (var i = 0; i < 2**m; i++) {

        //-----TX EXISTENCE AND SIG CHECK -----//
        txExistence[i] = TxExistence(m);
        txExistence[i].from_x <== from_x[i];
        txExistence[i].from_y <== from_y[i];
        txExistence[i].to_x <== to_x[i];
        txExistence[i].to_y <== to_y[i];
        txExistence[i].nonce <== nonce_from[i];
        txExistence[i].amount <== amount[i];
        txExistence[i].token_type_from <== token_type_from[i];

        txExistence[i].tx_root <== tx_root;

        for (var j = 0; j < m; j++){
            txExistence[i].paths2_root_pos[j] <== paths2tx_root_pos[i, j] ;
            txExistence[i].paths2_root[j] <== paths2tx_root[i, j];
        }

        txExistence[i].R8x <== R8x[i];
        txExistence[i].R8y <== R8y[i];
        txExistence[i].S <== S[i];
        //-----END TX EXISTENCE AND SIG CHECK -----//

        //-----SENDER IN TREE 1 BEFORE DEDUCTING CHECK -----//
        senderExistence[i] = BalanceExistence(n);
        senderExistence[i].x <== from_x[i];
        senderExistence[i].y <== from_y[i];
        senderExistence[i].token_balance <== token_balance_from[i];
        senderExistence[i].nonce <== nonce_from[i];
        senderExistence[i].token_type <== token_type_from[i];

        senderExistence[i].balance_root <== intermediate_roots[2*i];
        for (var j = 0; j < n; j++){
            senderExistence[i].paths2_root_pos[j] <== paths2root_from_pos[i, j];
            senderExistence[i].paths2_root[j] <== paths2root_from[i, j];
        }
        //-----END SENDER IN TREE 1 BEFORE DEDUCTING CHECK -----//


        // TODO: check this
        // balance checks
        token_balance_from[i] - amount[i] <= token_balance_from[i];
        token_balance_to[i] + amount[i] >= token_balance_to[i];

        nonce_from[i] != NONCE_MAX_VALUE;

        //-----CHECK TOKEN TYPES === IF NON-WITHDRAWS-----//
        ifBothHighForceEqual[i] = IfBothHighForceEqual();
        ifBothHighForceEqual[i].check1 <== to_x[i];
        ifBothHighForceEqual[i].check2 <== to_y[i];
        ifBothHighForceEqual[i].a <== token_type_to[i];
        ifBothHighForceEqual[i].b <== token_type_from[i];
        //-----END CHECK TOKEN TYPES-----//  


        //-----CHECK SENDER IN TREE 2 AFTER DEDUCTING -----//
        newSender[i] = BalanceLeaf();
        newSender[i].x <== from_x[i];
        newSender[i].y <== from_y[i];
        newSender[i].token_balance <== token_balance_from[i] - amount[i];
        newSender[i].nonce <== nonce_from[i] + 1;
        newSender[i].token_type <== token_type_from[i];

        // get intermediate root from new sender leaf
        merkle_root_from_new_sender[i] = GetMerkleRoot(n);
        merkle_root_from_new_sender[i].leaf <== newSender[i].out;
        for (var j = 0; j < n; j++){
            merkle_root_from_new_sender[i].paths2_root[j] <== paths2root_from[i, j];
            merkle_root_from_new_sender[i].paths2_root_pos[j] <== paths2root_from_pos[i, j];
        }

        // check that intermediate root is consistent with input
        merkle_root_from_new_sender[i].out === intermediate_roots[2*i  + 1];
        //-----END SENDER IN TREE 2 AFTER DEDUCTING CHECK-----//

        //-----RECEIVER IN TREE 2 BEFORE INCREMENTING CHECK-----//
        receiverExistence[i] = BalanceExistence(n);
        receiverExistence[i].x <== to_x[i];
        receiverExistence[i].y <== to_y[i];
        receiverExistence[i].token_balance <== token_balance_to[i];
        receiverExistence[i].nonce <== nonce_to[i];
        receiverExistence[i].token_type <== token_type_to[i];

        receiverExistence[i].balance_root <== intermediate_roots[2*i + 1];
        for (var j = 0; j < n; j++){
            receiverExistence[i].paths2_root_pos[j] <== paths2root_to_pos[i, j] ;
            receiverExistence[i].paths2_root[j] <== paths2root_to[i, j];
        }
        //-----END CHECK RECEIVER IN TREE 2 BEFORE INCREMENTING -----//

        //-----CHECK RECEIVER IN TREE 3 AFTER INCREMENTING-----//
        // if receiver is zero address, do not change balance
        newReceiver[i] = BalanceLeaf();
        newReceiver[i].x <== to_x[i];
        newReceiver[i].y <== to_y[i];

        
        // if receiver is zero address, do not change balance
        // otherwise add amount to receiver balance
	allLow[i] = AllLow(2);
	allLow[i].in[0] <== to_x[i];
	allLow[i].in[1] <== to_y[i];

	ifThenElse[i] = IfAThenBElseC();
	ifThenElse[i].aCond <== allLow[i].out;
	ifThenElse[i].bBranch <== token_balance_to[i];
	ifThenElse[i].cBranch <== token_balance_to[i] + amount[i];   
        newReceiver[i].nonce <== nonce_to[i];
        newReceiver[i].token_type <== token_type_to[i];

        // get intermediate root from new receiver leaf
        merkle_root_from_new_receiver[i] = GetMerkleRoot(n);
        merkle_root_from_new_receiver[i].leaf <== newReceiver[i].out;
        for (var j = 0; j < n; j++){
            merkle_root_from_new_receiver[i].paths2_root[j] <== paths2root_to[i, j];
            merkle_root_from_new_receiver[i].paths2_root_pos[j] <== paths2root_to_pos[i, j];
        }

        // check that intermediate root is consistent with input
        merkle_root_from_new_receiver[i].out === intermediate_roots[2*i  + 2];
        //-----END CHECK RECEIVER IN TREE 3 AFTER INCREMENTING-----//
    }
    out <== merkle_root_from_new_final_receiver.out;

}

component main = Main(4,2);