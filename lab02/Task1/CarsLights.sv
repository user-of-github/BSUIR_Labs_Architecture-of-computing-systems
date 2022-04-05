module CarsLights(
input logic clk, input logic reset, 
input logic L, input logic R,
output logic LA, output logic LB, output logic LC,
output logic RA, output logic RB, output logic RC
);
	typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5, S6} statetype;

	statetype state, nextstate;

	// регистр состояния
	always_ff @(posedge clk, posedge reset)
		if (reset) state <= S0;
		else state <= nextstate;

	// логика следующего состояния
	always_comb
		case (state)
		S0: if (L) nextstate = S1;
			else if (R) nextstate = S4;
			else nextstate = S0 ;
		S1: nextstate = S2;
		S2: nextstate = S3;
		S3: nextstate = S0;
		S4: nextstate = S5;
		S5: nextstate = S6;
		S6: nextstate = S0;
		default: nextstate = S0;
	endcase


	// выходная логика
	assign LA = (state == S1);
	assign LB = (state == S2 | state == S1); 
	assign LC = (state == S3 | state == S2 | state == S3); 

	assign RA = (state == S4);
	assign RB = (state == S5 | state == S4); 
	assign RC = (state == S6 | state == S4 | state == S3); 

endmodule	