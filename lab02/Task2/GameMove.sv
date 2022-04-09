module GameMove(
	input logic clk,
	input logic reset,
	input logic west, north, east, south,
	output logic [1:0] room_number;
);
	typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5, S6} statetype;
	statetype state, nextstate;

	
	always_ff @(posedge clk, posedge reset)
		if (reset) state <= S0;
		else state <= nextstate;
		
	
	always_comb
		case (state)
		// cave
		S0: if (east) nextstate = S1;
			 else nextstate = S0;
		
		// tonnel
		S1: if (west) nextstate = S1;
			 else if (south) nextstate = S2;
			 else nextstate = S1;
		
		// river
		S2: if (north) nextstate = S1;
			 else if (east) nextstate = S2;
			 else if (west) nextstate = S4;
			 else nextstate = S1;
		
		// secret room
		S3: if (east) nextstate = S2;
			 else nextstate = S3;
		
		// drogon
		S4: if (east) nextstate = S6;
			 else if (north) nextstate = S5;
			 else if (west) nextstate = S2;
		
		// trap
		S5: nextstate = S5;
		
		// final
		S6: nextstate = S6;
		
		default: nextstate = S0;
		
		endcase
		
		// he is without weapon or in trap
		assign room_number = {1, 0};

endmodule