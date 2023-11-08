module M23A640(csb, so, holdb, sck, si);
	input csb, holdb, sck, si;
	output so;
	
    wire error;
	wire re, we; 
	wire [7:0] instruction; 
	wire [12:0] address; 
	wire [7:0] data; 
	
	spi2 s1 (csb, sck, si, so, data, re, we, address); 
	SRAM ram (address, re, we, data);
	

endmodule