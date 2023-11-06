// module branch_predictor
// (
//     clk_i, 
//     rst_i,

//     update_i,
// 	result_i,
// 	predict_o
// );
// input clk_i, rst_i, update_i, result_i;
// output predict_o;

// // TODO

// endmodule

/*吃branchi 來決定 是不是真的是 branch來的*/
module branch_predictor
(
    clk_i, 
    rst_i,

    update_i, /*來自update update 1 /0  */
	//result_i, /*決定要不要看 */ 
    branch_i,
	predict_o,
    last_branch_o,
    bit1_o,
    bit2_o,
);
input clk_i, rst_i, update_i, branch_i;
output predict_o;
output last_branch_o;
output bit1_o,bit2_o;
localparam [1:0]
    StrongPredict = 2'b00,
    WeakPredict = 2'b01,
    WeakNotPredict = 2'b10,
    StrongNotPredict=2'b11;

reg[1:0] statePredict , statePredict_next;
reg branchbuffer;

assign predict_o = ~statePredict[1];
assign bit1_o = statePredict[1];
assign bit2_o = statePredict[0];
assign last_branch_o = branchbuffer;

always @(posedge clk_i, posedge rst_i)
begin
    if(rst_i) // go to state zero if rese
        begin
        statePredict <= StrongPredict;
        branchbuffer <= 1'b0;
        end
    else // otherwise update the states
        begin

        statePredict <= statePredict_next;
        branchbuffer <= branch_i;
        end
end

always @(branch_i or update_i) //statePredict
begin
    // store current state as next
    statePredict_next = statePredict; // required: when no case statement is satisfied
    
    //Moore_tick = 1'b0; // set tick to zero (so that 'tick = 1' is available for 1 cycle only)
    if (branch_i)
    begin
    case(statePredict)
        StrongPredict: begin // if state is zero,
            if(update_i) // and update_i is 1
                statePredict_next = StrongPredict; // then go to state edge.
            else
                statePredict_next = WeakPredict;
        end
        WeakPredict: begin
                if(update_i) // if update_i is 1, 
                    statePredict_next = StrongPredict; // go to state one,
                else    
                    statePredict_next = WeakNotPredict; // else go to state zero.
        end
        WeakNotPredict: begin
            if(update_i) // if update_i is 0,
                statePredict_next = StrongNotPredict; // then go to state zero.      
            else
                statePredict_next = WeakPredict;
        end
        StrongNotPredict: begin
            if(update_i) // if update_i is 0,
                statePredict_next = StrongNotPredict; // then go to state zero.      
            else
                statePredict_next = WeakNotPredict;
        end 
    endcase
    end
end

// TODO

endmodule
