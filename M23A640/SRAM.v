module SRAM(address, re, we, data);
	input [12:0] address; 
	input re, we; 
	inout [7:0] data; 
	
	reg [7:0] registers[8191:0];

	
	assign data = re ? registers[address] : 8'hzz;	
	always @(*) begin
		registers[address] = we ? data : registers[address]; 
	end

endmodule

