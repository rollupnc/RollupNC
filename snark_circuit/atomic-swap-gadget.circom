include "../circomlib/circuits/comparators.circom"
include "../circomlib/circuits/switcher.circom"
include "../circomlib/circuits/gates.circom"

template CheckLeaves() {
// input: two transaction leaves
// will have constraints that are always satisfied 
// if the two transactions form an atomic swap

    signal input tx1_from_x;
    signal input tx1_from_y;
    signal input tx1_to_x;
    signal input tx1_to_y;
    signal input tx1_amount;
    signal input tx1_token_type_from;
    
    signal private input tx1_swap_from_x; // atomic swap tx from address x coordinate
    signal private input tx1_swap_from_y; // atomic swap tx from address y coordinate
    signal private input tx1_swap_to_x;   // atomic swap tx to address x coordinate
    signal private input tx1_swap_to_y;   // atomic swap tx to address y coordinate
    signal private input tx1_swap_amount; //
    signal private input tx1_swap_type;   // atomic swap tx token type

    signal input tx2_from_x;
    signal input tx2_from_y;
    signal input tx2_to_x;
    signal input tx2_to_y;
    signal input tx2_amount;
    signal input tx2_token_type_from;


    signal private input tx2_swap_from_x; // atomic swap tx from address x coordinate
    signal private input tx2_swap_from_y; // atomic swap tx from address y coordinate
    signal private input tx2_swap_to_x;   // atomic swap tx to address x coordinate
    signal private input tx2_swap_to_y;   // atomic swap tx to address y coordinate
    signal private input tx2_swap_amount; //
    signal private input tx2_swap_type;   // atomic swap tx token type

    // check that the dependencies are correct
    tx1_from_x === tx2_swap_from_x;
    tx1_from_y === tx2_swap_from_y;
    tx1_to_x === tx2_swap_to_x;
    tx1_to_y === tx2_swap_to_x;

    tx2_from_x === tx1_swap_from_x;
    tx2_from_y === tx1_swap_from_y;
    tx2_to_x === tx1_swap_to_x;
    tx2_to_y === tx1_swap_to_x;

    // check that amounts are correct
    tx1_amount === tx2_swap_amount;
    tx2_amount === tx1_swap_amount;

    // check that types are correct
    tx1_type === tx2_swap_type;
    tx2_type === tx1_swap_type;
    


}
