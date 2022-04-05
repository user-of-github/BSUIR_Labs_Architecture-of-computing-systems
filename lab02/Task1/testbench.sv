module testbench();
	logic clk, reset;
	logic tl, tr, 
			la, lb, lc, 
			ra, rb, rc;
	
	logic la_expected, lb_expected, lc_expected, 
			ra_expected, rb_expected, rc_expected;
			
	logic [31:0] vectornum, errors;
	logic [5:0] testvectors[10000:0];
	// задание (определение) тестируемого 
	// устройства
	
	CarsLights dut(clk, reset, tl, tr, la, lb, lc, ra, rb, rc);
	
	// генерировать такты
	always
		begin
			clk = 1; #5; clk = 0; #5;
		end
	
	initial 
	begin
		tl = 0; tr = 0; la_expected = 0; lb_expected = 0; lc_expected = 0; #5
		ra_expected = 0; rb_expected = 0; rc_expected = 0;
		assert (la === la_expected && 
				  lb === lb_expected && 
				  lc === lc_expected && 
				  ra === ra_expected && 
				  rb === rb_expected && 
				  rc === rc_expected) else $error("00 failed. %b received", {la, lb, lc, ra, rb, rc});
		 
		tl = 1; tr = 0; la_expected = 1; lb_expected = 1; lc_expected = 1; ra_expected = 0; rb_expected = 0; rc_expected = 0; #11
		assert (la === la_expected && lb === lb_expected && lc === lc_expected && ra === ra_expected && rb === rb_expected && rc === rc_expected) else $error("10 failed.%b received", {la, lb, lc, ra, rb, rc}); #5;
		
	end

endmodule