//Assume the tb to be the processor and give input
module tb;
  parameter WIDTH=8;
  parameter DEPTH=8;
  parameter ADDR_WIDTH = $clog2(DEPTH);
  
  reg [1000:0]testcase;
  
  reg clk=0;
  reg rst,valid,wr_rd;
  reg [ADDR_WIDTH-1:0]addr,startindex,endindex;
  reg [WIDTH-1:0] wdata;
  
  wire ready;
  wire [WIDTH-1:0] rdata;
  
  integer i;
  
  memory1 dut(.clk(clk), .rst(rst), .valid(valid), .ready(ready), .wdata(wdata), .rdata(rdata), .addr(addr), .wr_rd(wr_rd));
  
  task reset();
    begin
      valid <= 0;
      wr_rd <= 0;
      addr  <= 0;
      wdata <= 0;
    end
  endtask
  
  task write(input reg [ADDR_WIDTH-1:0] startindex,input reg [ADDR_WIDTH:0]endindex);
    begin
      for(i=startindex;i<endindex+1;i=i+1)begin
          @(posedge clk);
          valid <= 1;
          wr_rd <= 1;
          addr  <= i;
          wdata <= $random;

          wait(ready == 1);
    	end
    end
    @(posedge clk);
    reset();
  endtask
  
  task read(input reg [ADDR_WIDTH-1:0] startindex, input reg [ADDR_WIDTH:0]endindex);
    begin
      for(i=startindex;i<endindex+1;i=i+1)begin
          @(posedge clk);
          valid <= 1;
          wr_rd <= 0;
          addr  <= i;
          wait(ready == 1);
    	end
    end
    @(posedge clk);
    reset();
  endtask
  
  task bd_wr();
    begin
      $readmemh("wrt2mem.hex",dut.mem);
    end
  endtask
  
  task bd_rd();
    begin
      $writememh("read2mem.hex",dut.mem);
    end
  endtask
  
  always #5 clk=~clk;
  
  
  initial begin
    rst=1;
    reset();
    repeat(2)@(posedge clk);
    rst=0;
    
    if($value$plusargs("testcase=%s",testcase)) $display("\n **Testcase = %s is executed** \n", testcase);
    
    else $display("\n** Testcase is not captured!\n **",testcase);
//     //generate stimulus for write
//     write();
//     //bd_wr();
    
//     //generate stimulus for read
//     read();
//     //bd_rd();
    
    case(testcase)
      "test_fd_write"   : write(0,DEPTH);
      "test_fd_read"    : read(0,DEPTH);
      "test_fd_wr_rd"   : begin write(0,DEPTH);read(0,DEPTH); end
      "test_half_wr_rd" : begin write(0,DEPTH/2);read(0,DEPTH/2); end
      "test_3_6_wr_rd" : begin write(3,6);read(3,6); end
      "test_bd_read"    : bd_rd();
      "test_bd_write"   : bd_wr();
      "test_bd_wr_rd"   : begin 
        					bd_wr();
        					bd_rd(); 
      					  end
      "test_fd_wr_bd_rd":begin write(0,DEPTH);bd_rd(); end
      "test_bd_wr_fd_rd":begin bd_wr();read(0,DEPTH); end
    endcase

  end
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    #400;
    $finish;                                                                                                                                                 
  end
endmodule
