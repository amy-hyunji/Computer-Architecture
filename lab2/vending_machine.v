`include "vending_machine_def.v"

module vending_machine (

	clk,							// Clock signal
	reset_n,						// Reset signal (active-low)

	i_input_coin,				// coin is inserted.
	i_select_item,				// item is selected.
	i_trigger_return,			// change-return is triggered

	o_available_item,			// Sign of the item availability
	o_output_item,				// Sign of the item withdrawal
	o_return_coin,				// Sign of the coin return
	stopwatch,
	current_total,
	return_temp,
);

	// Ports Declaration
	// Do not modify the module interface
	input clk;
	input reset_n;

	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0] i_select_item;
	input i_trigger_return;

	output reg [`kNumItems-1:0] o_available_item;
	output reg [`kNumItems-1:0] o_output_item;
	output reg [`kNumCoins-1:0] o_return_coin;

	output [3:0] stopwatch;
	output [`kTotalBits-1:0] current_total;
	output [`kTotalBits-1:0] return_temp;
	// Normally, every output is register,
	//   so that it can provide stable value to the outside.

//////////////////////////////////////////////////////////////////////	/

	//we have to return many coins
	reg [`kCoinBits-1:0] returning_coin_0;
	reg [`kCoinBits-1:0] returning_coin_1;
	reg [`kCoinBits-1:0] returning_coin_2;
	reg block_item_0;
	reg block_item_1;
	//check timeout
	reg [3:0] stopwatch;
	//when return triggered
	reg have_to_return;
	reg  [`kTotalBits-1:0] return_temp;
	reg [`kTotalBits-1:0] temp;
////////////////////////////////////////////////////////////////////////

	// Net constant values (prefix kk & CamelCase)
	// Please refer the wikepedia webpate to know the CamelCase practive of writing.
	// http://en.wikipedia.org/wiki/CamelCase
	// Do not modify the values.
	wire [31:0] kkItemPrice [`kNumItems-1:0];	// Price of each item
	wire [31:0] kkCoinValue [`kNumCoins-1:0];	// Value of each coin
	assign kkItemPrice[0] = 400;
	assign kkItemPrice[1] = 500;
	assign kkItemPrice[2] = 1000;
	assign kkItemPrice[3] = 2000;
	assign kkCoinValue[0] = 100;
	assign kkCoinValue[1] = 500;
	assign kkCoinValue[2] = 1000;


	// NOTE: integer will never be used other than special usages.
	// Only used for loop iteration.
	// You may add more integer variables for loop iteration.
	integer i, j, k,l,m,n;

	// Internal states. You may add your own net & reg variables.
	reg [`kTotalBits-1:0] current_total;
	reg [`kItemBits-1:0] num_items [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins [`kNumCoins-1:0];

	// Next internal states. You may add your own net and reg variables.
	reg [`kTotalBits-1:0] current_total_nxt;
	reg [`kItemBits-1:0] num_items_nxt [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins_nxt [`kNumCoins-1:0];

	// Variables. You may add more your own registers.
	reg [`kTotalBits-1:0] input_total, output_total, return_total_0,return_total_1,return_total_2;
	reg [`kNumItems-1:0] x_available_item, y_available_item, z_available_item, w_available_item;
	wire [`kNumItems-1:0] wire_output_item;
	assign wire_output_item = o_output_item;
	wire [`kNumCoins-1:0] wire_return_coin;
	assign wire_return_coin = o_return_coin;
	reg reg_trigger_return;
	
	initial begin
		reg_trigger_return = 0;
		stopwatch = 4'b1111;
		current_total = 0;
		current_total_nxt = 0;
		output_total = 0;
		o_return_coin = 0;
		o_output_item = 0;
		for (i=0; i<`kNumCoins; i=i+1) begin
			num_coins[i] = 8'b00000000;
			num_coins_nxt[i] = 8'b00000000;
		end
		for (i=0; i<`kNumItems; i=i+1) begin
			num_items[i] = 8'b00000000;
			num_items_nxt[i] = 8'b00000000;
		end
		//$display("%b", current_total);
	end
 
	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		// Calculate the next current_total state. current_total_nxt =

		for (i=0; i<`kNumCoins; i=i+1)
			num_coins_nxt[i] = num_coins[i] + i_input_coin[i] - wire_return_coin[i];
		for (i=0; i<`kNumItems; i=i+1)
			num_items_nxt[i] = num_items[i] - wire_output_item[i];
		//current_total_nxt
		current_total_nxt = 0;
		for (i=0; i<`kNumCoins; i=i+1)
			current_total_nxt = current_total_nxt + i_input_coin[i] * kkCoinValue[i] - o_return_coin[i] * kkCoinValue[i];
		//$display("o_return_coin %d", current_total_nxt);
		for (i=0; i<`kNumItems; i=i+1)
			current_total_nxt = current_total_nxt - o_output_item[i] * kkItemPrice[i];
		current_total_nxt = current_total_nxt + current_total;
	
		//$display("current_total_nxt: %d", current_total_nxt);		
	end


	// Combinational logic for the outputs
	always @(*) begin
	// TODO: o_available_item
		x_available_item = 4'b0000;
		y_available_item = 4'b0000;
		z_available_item = 4'b0000;
		w_available_item = 4'b0000;

		//?? conditional part?? ???? 
		if ((current_total >= kkItemPrice[0]) & (num_items[0] > 0)) x_available_item = 4'b0001;
		if ((current_total >= kkItemPrice[1]) & (num_items[1] > 0)) y_available_item = 4'b0010;
		if ((current_total >= kkItemPrice[2]) & (num_items[2] > 0)) z_available_item = 4'b0100;
		if ((current_total >= kkItemPrice[3]) & (num_items[3] > 0)) w_available_item = 4'b1000;
		o_available_item = x_available_item | y_available_item | z_available_item | w_available_item;
		
	// TODO: o_output_item
		o_output_item = o_available_item & i_select_item;
		//$display("o_available_item %b", o_available_item);
		//$display("i_select_item %b", i_select_item);
		//$display("o_output_item %b", o_output_item);

	end

	// Sequential circuit to reset or update the states
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			// TODO: reset all states.
			current_total <= 0; 
			current_total_nxt <= 0;
			o_output_item <= 0;
			o_return_coin <= 0;
			stopwatch <= 4'b1111;
			for (i=0; i<`kNumCoins; i=i+1)
				num_coins[i]<=8'b00000000;
			for (i=0; i<`kNumItems; i=i+1)
				num_items[i]<=8'b00001010;
			for (i=0; i<`kNumCoins; i=i+1)
				num_coins_nxt[i]<=8'b00000000;
			for (i=0; i<`kNumItems; i=i+1)
				num_items_nxt[i]<=8'b00001010;
		end
		else begin
			// TODO: update all states.
			for (i=0; i<`kNumItems; i=i+1)
				num_items[i] <= num_items_nxt[i];
			for (i=0; i<`kNumCoins; i=i+1)
				num_coins[i] <= num_coins_nxt[i];
			//$display("%b", current_total);
			current_total <= current_total_nxt;
/////////////////////////////////////////////////////////////////////////

			// decrease stopwatch
			if (!i_input_coin & !i_select_item & !reg_trigger_return) stopwatch = stopwatch - 1;
			else stopwatch = 4'b1111;
		
			//if you have to return some coins then you have to turn on the bit
			
			output_total = current_total_nxt;
			if (i_trigger_return == 1'b1) reg_trigger_return = i_trigger_return;
			//if you have to return some coins then you have to turn on the bit
			if (reg_trigger_return == 1'b1 | stopwatch == 0) begin
				o_output_item = 0;
				return_total_2 = output_total/kkCoinValue[2];
				return_total_1 = output_total/kkCoinValue[1];
				return_total_0 = output_total/kkCoinValue[0];
				if (return_total_2 > 0) begin
					o_return_coin = 3'b100;
					output_total = output_total - kkCoinValue[2];
				end
				else if (return_total_1 > 0) begin
					o_return_coin = 3'b010;
					output_total = output_total - kkCoinValue[1];
				end
				else if (return_total_0 > 0) begin
					o_return_coin = 3'b001;
					output_total = output_total - kkCoinValue[0];
				end
				else begin
					reg_trigger_return = 0;
					o_return_coin = 3'b000;
					current_total = 0;
					current_total_nxt = 0;
					output_total = 0;
				end
				$display("bottom return coin %d", o_return_coin);
			end
/////////////////////////////////////////////////////////////////////////
		end		   //update all state end
	end	   //always end

endmodule