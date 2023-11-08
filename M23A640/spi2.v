module spi2 (csb, sck, mosi, miso, data, re, we, addr_out);   
    input csb, sck, mosi; 
    //reg [31:0] din;
    output reg miso; 
    inout [7:0] data; 
    output reg re, we; 
    output reg [12:0] addr_out;    

    reg ready, flag; 
    reg[7:0] instruction; 
    reg [15:0] address; 
    reg [2:0] state; 
    reg [7:0] dout; 
    reg [7:0] din; 
    reg [4:0] counter; 

    parameter idle = 3'b001, interp = 3'b011, transmit = 3'b010, addr = 3'b110; 

    assign data = we ? din : 8'hzz; 

    always@(posedge csb) begin
        state <= idle;   
        instruction <= 8'd0;
        address <= 16'd0;
        din <= 8'd0;
        dout <= 8'bz;
        ready <= 1'b0;
        re <=1'b0;
        we <= 1'b0;
        flag <= 1'b0;
        counter <= 5'd0; 
    end
    
    always@(negedge csb) begin
        state <= interp; 
        counter <= 5'd0; 
        //register2 = din; 
    end

    always@(posedge sck) begin
        //register <= {register[30:0], mosi};
        case (state) 
            interp: begin
                //din <= {din[30:0], mosi};
                instruction[7-counter] = mosi; 
                counter = counter + 5'd1;
                if (counter == 5'd8) begin
                        counter <= 6'd0; 
                        state <= addr; 
                end
            end
            addr: begin 
                address[15-counter] = mosi; 
                counter = counter + 5'd1;
                if(counter == 5'd16) begin 
                    addr_out = address[12:0]; 
                    counter <= 5'd0; 
                    state <= transmit;
                    if(instruction == 8'b00000011) begin
                        ready = 1'b1; 
                        if((address > 16'h1fff) && (address < 16'h8000)) begin
                            we = 0;  re = 0; 
                            flag = 1'b1; 
                        end
                        else begin
                            we = 0; re = 1; 
                            flag = 1'b0; 
                        end
                    end
                end
            end
            transmit: begin
                if(instruction == 8'b00000010) begin
						din = {din[6:0],mosi};
                        counter = counter + 5'd1;
						if(counter == 5'd8) begin 
							we = 1; re = 0; 
							state <= idle;
						end
				end
            end
        endcase
    end

    always@(negedge sck) begin
        if (state == transmit) begin
           if(ready == 1'b1) begin
                if((counter == 5'd0) && (flag == 1'b0)) begin
                    dout = data; 
                end
                if (flag == 1'b0) begin 
                    miso = dout[7]; 
                    dout = dout << 1;
                    counter = counter + 5'd1; 
                end
                else if (flag == 1'b1) begin
                    miso = 1'bz; 
                    counter = counter + 5'd1;
                end
           end 
        end
    end
endmodule
