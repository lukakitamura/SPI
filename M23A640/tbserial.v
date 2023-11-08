module testbench();


reg csb, sck, si;
wire so;
reg [7:0] dreg;
reg fail;
reg anyfail;



M23A640 dut(csb, so, 1'b1, sck, si);

initial begin
  anyfail = 0;
  csb = 1;
  sck = 1; #5 sck = 0;
  write_read_test();
  write_read_test2();
  broken_write_test();
  alias_test();
  #5 sck = 1; #5 sck = 0;
  #5 sck = 1; #5 sck = 0;
  #5 sck = 1; #5 sck = 0;
  if (anyfail) $display("XXXXX - Failed to pass test suite - XXXXX");
  else $display("***** - ALL TESTS PASSED - *****");
$finish;
end


task write_read_test();
  begin
  // Perform 10 writes then 10 reads to see if the data is read back correctly
    $display("Beginning write-read test");
//    $monitor("dreg = %h, @ %d", dreg,$time);
    fail = 0;
    write(16'h0001, 8'h01);
    write(16'h0002, 8'h12);
    write(16'h0003, 8'h13);
    write(16'h0003, 8'h23);
    write(16'h0004, 8'h34);
    write(16'h0005, 8'h45);
    write(16'h1001, 8'h56);   
    write(16'h1002, 8'h67);
    write(16'h1003, 8'h78);
    write(16'h1004, 8'h89);
    write(16'h1005, 8'h9A);
    read(16'h0001, dreg);  if (dreg !== 8'h01) fail = 1;
    read(16'h0002, dreg);  if (dreg !== 8'h12) fail = 1;
    read(16'h0003, dreg);  if (dreg !== 8'h23) fail = 1;
    read(16'h0004, dreg);  if (dreg !== 8'h34) fail = 1;
    read(16'h0005, dreg);  if (dreg !== 8'h45) fail = 1;
    read(16'h1001, dreg);  if (dreg !== 8'h56) fail = 1;
    read(16'h1002, dreg);  if (dreg !== 8'h67) fail = 1;
    read(16'h1003, dreg);  if (dreg !== 8'h78) fail = 1;
    read(16'h1004, dreg);  if (dreg !== 8'h89) fail = 1;
    read(16'h1005, dreg);  if (dreg !== 8'h9A) fail = 1;
    if (fail == 1) begin
      anyfail = 1;
      $display("XXXXX - Failed write-read test - XXXXX");
    end
    else $display("Passed write-read test");
  end
endtask

task write_read_test2();
  begin
  // Perform some re-writes to if the data is read back correctly
    $display("Beginning write-read test 2");
//    $monitor("dreg = %h, @ %d", dreg,$time);
    fail = 0;
    write(16'h0001, 8'h01);
    write(16'h0002, 8'h12);
    write(16'h0003, 8'h23);
    write(16'h0004, 8'h34);
    write(16'h0005, 8'h45);
    read(16'h0001, dreg);  if (dreg !== 8'h01) fail = 1;
    read(16'h0002, dreg);  if (dreg !== 8'h12) fail = 1;
    read(16'h0003, dreg);  if (dreg !== 8'h23) fail = 1;
    read(16'h0004, dreg);  if (dreg !== 8'h34) fail = 1;
    read(16'h0005, dreg);  if (dreg !== 8'h45) fail = 1;
    write(16'h0001, 8'h10);
    write(16'h0002, 8'h21);
    write(16'h0003, 8'h32);
    read(16'h0001, dreg);  if (dreg !== 8'h10) fail = 1;
    read(16'h0002, dreg);  if (dreg !== 8'h21) fail = 1;
    read(16'h0003, dreg);  if (dreg !== 8'h32) fail = 1;
    read(16'h0004, dreg);  if (dreg !== 8'h34) fail = 1;
    read(16'h0005, dreg);  if (dreg !== 8'h45) fail = 1;   
    if (fail == 1) begin
      anyfail = 1;
      $display("XXXXX - Failed write-read test 2 - XXXXX");
    end
    else $display("Passed write-read test 2");
  end
endtask

task broken_write_test();
  begin
// Test response to a broken write
    $display("Beginning broken write test");
    fail = 0;
    write(16'h0001, 8'h01);
    write(16'h0002, 8'h12);
    read(16'h0001, dreg);  if (dreg !== 8'h01) fail = 1;
    read(16'h0002, dreg);  if (dreg !== 8'h12) fail = 1;
    write(16'h0001, 8'h34);
    broken_write(16'h0002, 8'h56);
    write(16'h0003, 8'h78);
    read(16'h0001, dreg);  if (dreg !== 8'h34) fail = 1;
    read(16'h0002, dreg);  if (dreg !== 8'h12) fail = 1; 
    read(16'h0003, dreg);  if (dreg !== 8'h78) fail = 1; 
    if (fail == 1) begin
      anyfail = 1;
      $display("XXXXX - Failed broken write test - XXXXX");
    end
    else $display("Passed broken write test");
  end
endtask

task alias_test();
  begin
// Test alias behavior
    $display("Beginning alias test");
    fail = 0;
    write(16'h0001, 8'h01);
    write(16'h0002, 8'h12);
    read(16'h0001, dreg);  if (dreg !== 8'h01) fail = 1;
    read(16'h0002, dreg);  if (dreg !== 8'h12) fail = 1;
    read(16'h8001, dreg);  if (dreg !== 8'h01) fail = 1;
    read(16'h8002, dreg);  if (dreg !== 8'h12) fail = 1;
    read(16'h4002, dreg);  if (dreg !== 8'hzz) fail = 1;
    write(16'h4001, 8'h34);
    write(16'h4002, 8'h56);
    read(16'h0001, dreg);  if (dreg !== 8'h34) fail = 1;
    read(16'h0002, dreg);  if (dreg !== 8'h56) fail = 1;
    read(16'h8001, dreg);  if (dreg !== 8'h34) fail = 1;
    read(16'h8002, dreg);  if (dreg !== 8'h56) fail = 1;
    read(16'h4002, dreg);  if (dreg !== 8'hzz) fail = 1;
     if (fail == 1) begin
      anyfail = 1;
      $display("XXXXX - Failed alias test - XXXXX");
    end
    else $display("Passed alias test");
  end
endtask

task write(input [15:0] address, input [7:0] data);
  begin
    csb = 0;				// Start Transaction
    si = 0; #5 sck = 1; 		// Send write instruction 0000 0010
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 1; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;

    #5 si = address[15]; sck = 0; #5 sck = 1;	// Send address MSB first
    #5 si = address[14]; sck = 0; #5 sck = 1;
    #5 si = address[13]; sck = 0; #5 sck = 1;
    #5 si = address[12]; sck = 0; #5 sck = 1;
    #5 si = address[11]; sck = 0; #5 sck = 1;
    #5 si = address[10]; sck = 0; #5 sck = 1;
    #5 si = address[9]; sck = 0; #5 sck = 1;
    #5 si = address[8]; sck = 0; #5 sck = 1;
    #5 si = address[7]; sck = 0; #5 sck = 1;
    #5 si = address[6]; sck = 0; #5 sck = 1;
    #5 si = address[5]; sck = 0; #5 sck = 1;
    #5 si = address[4]; sck = 0; #5 sck = 1;
    #5 si = address[3]; sck = 0; #5 sck = 1;
    #5 si = address[2]; sck = 0; #5 sck = 1;
    #5 si = address[1]; sck = 0; #5 sck = 1;
    #5 si = address[0]; sck = 0; #5 sck = 1;


    #5 si = data[7]; sck = 0; #5 sck = 1;	// Send data MSB first
    #5 si = data[6]; sck = 0; #5 sck = 1;
    #5 si = data[5]; sck = 0; #5 sck = 1;
    #5 si = data[4]; sck = 0; #5 sck = 1;
    #5 si = data[3]; sck = 0; #5 sck = 1;
    #5 si = data[2]; sck = 0; #5 sck = 1;
    #5 si = data[1]; sck = 0; #5 sck = 1;
    #5 si = data[0]; sck = 0; #5 sck = 1;
    #5 sck = 0; #5 csb = 1; #5;
  end
endtask


task read(input [15:0] address, output reg [7:0] data);
  begin
    csb = 0;				// Start Transaction
    si = 0; #5 sck = 1; 		// Send read instruction 0000 0011
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 1; sck = 0; #5 sck = 1;
    #5 si = 1; sck = 0; #5 sck = 1;

    #5 si = address[15]; sck = 0; #5 sck = 1;	// Send address MSB first
    #5 si = address[14]; sck = 0; #5 sck = 1;
    #5 si = address[13]; sck = 0; #5 sck = 1;
    #5 si = address[12]; sck = 0; #5 sck = 1;
    #5 si = address[11]; sck = 0; #5 sck = 1;
    #5 si = address[10]; sck = 0; #5 sck = 1;
    #5 si = address[9]; sck = 0; #5 sck = 1;
    #5 si = address[8]; sck = 0; #5 sck = 1;
    #5 si = address[7]; sck = 0; #5 sck = 1;
    #5 si = address[6]; sck = 0; #5 sck = 1;
    #5 si = address[5]; sck = 0; #5 sck = 1;
    #5 si = address[4]; sck = 0; #5 sck = 1;
    #5 si = address[3]; sck = 0; #5 sck = 1;
    #5 si = address[2]; sck = 0; #5 sck = 1;
    #5 si = address[1]; sck = 0; #5 sck = 1;
    #5 si = address[0]; sck = 0; #5 sck = 1;


    #5 sck = 0; #5 data[7] = so; sck = 1;	// Receive data MSB first
    #5 sck = 0; #5 data[6] = so; sck = 1;
    #5 sck = 0; #5 data[5] = so; sck = 1;
    #5 sck = 0; #5 data[4] = so; sck = 1;
    #5 sck = 0; #5 data[3] = so; sck = 1;
    #5 sck = 0; #5 data[2] = so; sck = 1;
    #5 sck = 0; #5 data[1] = so; sck = 1;
    #5 sck = 0; #5 data[0] = so; sck = 1;
    #5 sck = 0; #5 csb = 1; #5;
//  $display("performing read from %h, data is %h",address, data);
  end
endtask

task broken_write(input [15:0] address, input [7:0] data);
  begin
    csb = 0;				// Start Transaction
    si = 0; #5 sck = 1; 		// Send write instruction 0000 0010
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;
    #5 si = 1; sck = 0; #5 sck = 1;
    #5 si = 0; sck = 0; #5 sck = 1;

    #5 si = address[15]; sck = 0; #5 sck = 1;	// Send address MSB first
    #5 si = address[14]; sck = 0; #5 sck = 1;
    #5 si = address[13]; sck = 0; #5 sck = 1;
    #5 si = address[12]; sck = 0; #5 sck = 1;
    #5 si = address[11]; sck = 0; #5 sck = 1;
    #5 si = address[10]; sck = 0; #5 sck = 1;
    #5 si = address[9]; sck = 0; #5 sck = 1;
    #5 si = address[8]; sck = 0; #5 sck = 1;
    #5 si = address[7]; sck = 0; #5 sck = 1;
    #5 si = address[6]; sck = 0; #5 sck = 1;
    #5 si = address[5]; sck = 0; #5 sck = 1;
    #5 si = address[4]; sck = 0; #5 sck = 1;
    #5 si = address[3]; sck = 0; #5 sck = 1;
    #5 si = address[2]; sck = 0; #5 sck = 1;
    #5 si = address[1]; sck = 0; #5 sck = 1;
    #5 si = address[0]; sck = 0; #5 sck = 1;


    #5 si = data[7]; sck = 0; #5 sck = 1;	// Send data MSB first
    #5 si = data[6]; sck = 0; #5 sck = 1;
    #5 si = data[5]; sck = 0; #5 sck = 1;
    #5 si = data[4]; sck = 0; #5 sck = 1;
    #5 si = data[3]; sck = 0; #5 sck = 1;
    #5 si = data[2]; sck = 0; #5 sck = 1;
    #5 si = data[1]; sck = 0; #5 sck = 1;csb = 1;
    #5 si = data[0]; sck = 0; #5 sck = 1;
    #5 sck = 0; #5 ; #5;
  end
endtask
endmodule
