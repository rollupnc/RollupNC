include "/home/austin/Repositories/Github/iden3/circomlib/circuits/comparators.circom"
include "/home/austin/Repositories/Github/iden3/circomlib/circuits/switcher.circom"
include "/home/austin/Repositories/Github/iden3/circomlib/circuits/gates.circom"
include "../if-gadgets.circom"


template CheckLeaves() {
// input: two transaction leaves
// will have constraints that are always satisfied 
// if the two transactions form an atomic swap
 
    signal input tx1_swap_from_x; // atomic swap tx from address x coordinate
    signal input tx1_swap_from_y; // atomic swap tx from address y coordinate
    signal input tx1_swap_to_x;   // atomic swap tx to address x coordinate
    signal input tx1_swap_to_y;   // atomic swap tx to address y coordinate
    signal input tx1_swap_amount; //
    signal input tx1_swap_type;   // atomic swap tx token type

    signal input tx2_from_x;
    signal input tx2_from_y;
    signal input tx2_to_x;
    signal input tx2_to_y;
    signal input tx2_amount;
    signal input tx2_type;

    // check if tx1 is an atomic transaction
    component is_swap = AllHigh(2);
    is_swap.in[0] <== tx1_swap_from_x;
    is_swap.in[1] <== tx1_swap_from_y;

    component check_from_xs = ForceEqualIfEnabled(); 
    component check_from_ys = ForceEqualIfEnabled(); 
    component check_to_xs = ForceEqualIfEnabled(); 
    component check_to_ys = ForceEqualIfEnabled(); 
    component check_amounts = ForceEqualIfEnabled(); 
    component check_types = ForceEqualIfEnabled(); 
 
    check_from_xs.enabled <== is_swap.out;
    check_from_ys.enabled <== is_swap.out;
    check_to_xs.enabled <== is_swap.out;
    check_to_ys.enabled <== is_swap.out;
    check_amounts.enabled <== is_swap.out;
    check_types.enabled <== is_swap.out;
 
    check_from_xs.in[0] <== tx1_swap_from_x;
    check_from_xs.in[1] <== tx2_from_x;
    check_from_ys.in[0] <== tx1_swap_from_y;
    check_from_ys.in[1] <== tx2_from_y;
    check_to_xs.in[0] <== tx1_swap_to_x;
    check_to_xs.in[1] <== tx2_to_x;
    check_to_ys.in[0] <== tx1_swap_to_y;
    check_to_ys.in[1] <== tx2_to_y;
    check_amounts.in[0] <== tx1_swap_amount;
    check_amounts.in[1] <== tx2_amount;
    check_types.in[0] <== tx1_swap_type;
    check_types.in[1] <== tx2_type;

}


component main = CheckLeaves();
