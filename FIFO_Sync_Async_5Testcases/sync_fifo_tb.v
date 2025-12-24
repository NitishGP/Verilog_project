`include "sync_fifo_d.v"
module tb;
  parameter WIDTH = 8;
  parameter DEPTH = 8;
  parameter PTR_WIDTH = $clog2(WIDTH);
  parameter CLK_TP=10;
  parameter WR_NUM = 5;
  parameter RD_NUM=6;
  parameter MAX_WR_DELAY = 5;
  parameter MAX_RD_DELAY = 5;
  
  
  reg rd_en,wr_en,clk,rst;
  reg [WIDTH-1:0] wdata; 
  
  reg [999:0] testcase;
  
  integer i,j,k,wr_delay,rd_delay;
  
  wire [WIDTH-1:0] rdata;
  wire full,empty, overflow, underflow;
   
  sync_fifo  #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut( 
    			 .rst(rst),
                 .clk(clk),
                 .rd_en(rd_en),
                 .wr_en(wr_en),
                 .rdata(rdata),
                 .wdata(wdata),
                 .full(full),
                 .empty(empty),
                 .overflow(overflow),
                 .underflow(underflow));
  
  
  task write(input reg[DEPTH:0] no_of_loc);
    begin
      for(i=0;i<no_of_loc;i=i+1)begin
        @(negedge clk);
      wr_en=1;
      wdata=$random;
      end
      @(negedge clk);
    wr_en=0;
    wdata=0;
    end
  endtask
  
  task read(input reg[DEPTH:0] no_of_loc);
    
    begin
      for(i=0;i<no_of_loc;i=i+1)begin
        @(negedge clk);
      rd_en=1;
    end
      @(negedge clk);
    rd_en=0;
    end
  endtask
  
  always begin
    clk=0;#(CLK_TP/2);
    clk=1;#(CLK_TP/2);
  end
  
  initial begin
    rst=1;
    repeat(2)@(posedge clk);
    rst=0;
    
    if($value$plusargs("testcase=%0s",testcase)) $display("\n** Testcase %0s is executed successfully! **\n", testcase);
    else $display("\n** Testcase is not captured! **\n");
    
    case(testcase)
      "test_wr":write(DEPTH);
      "test_rd": read(DEPTH);
      "test_full_empty":begin write(DEPTH); read(DEPTH); end
      "test_overflow":write(DEPTH+5);
      "test_underflow":read(DEPTH+5);
      "test_all_error":begin write(DEPTH+5);read(DEPTH+5); end
      "test_concurrency":begin
        fork
          for(j=0;j<WR_NUM;j=j+1)begin
            write(1);
            wr_delay=$urandom_range(0,MAX_WR_DELAY);
            repeat(wr_delay)@(negedge clk);
            
          end
          for(k=0;k<RD_NUM;k=k+1)begin
            repeat(2) @(posedge clk);
             read(1);
            rd_delay=$urandom_range(0,MAX_RD_DELAY);
            repeat(rd_delay)@(negedge clk);
          end
        join
      end
    endcase
      

  end
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    #400;
    $finish;
  end
endmodule