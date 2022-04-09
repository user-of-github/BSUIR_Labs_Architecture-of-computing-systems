module GameMove(
	input logic clk,
	input logic reset,
	input logic west, north, east, south,
	output logic win, die
);
	assign win = 1;
	assign die = 0;
	
endmodule