`include "async_fifo_d.v"
module tb;
  parameter WIDTH = 8;
  parameter DEPTH = 8;
  parameter PTR_WIDTH = $clog2(WIDTH);
  parameter RD_CLK_TP=5;
  parameter WR_CLK_TP=8;
  parameter WR_NUM = 19;
  parameter RD_NUM=15;
  parameter MAX_WR_DELAY = 5;
  parameter MAX_RD_DELAY = 5;
  
  
  reg rd_en,wr_en,clk_rd,clk_wr,rst;
  reg [WIDTH-1:0] wdata; 
  //reg [DEPTH:0] no_of_loc;
  reg [999:0] testcase;
  
  integer i,j,k,wr_delay,rd_delay;
  
  wire [WIDTH-1:0] rdata;
  wire full,empty, overflow, underflow;
   
  async_fifo  #(.WIDTH(WIDTH), .DEPTH(DEPTH)) 
  				 dut( 
    			 .rst(rst),
                 .clk_wr(clk_wr),
                 .clk_rd(clk_rd),
                 .rd_en(rd_en),
                 .wr_en(wr_en),
                 .rdata(rdata),
                 .wdata(wdata),
                 .full(full),
                 .empty(empty),
                 .overflow(overflow),
                .underflow(underflow));
  
//   task reset();
//     begin
//       rdata=0;
//       full=0;
//       empty=0;
//       overflow=0;
//       underflow=0;
//     end
//   endtask
  
  task write(input reg[DEPTH:0] no_of_loc);
    begin
      for(i=0;i<no_of_loc;i=i+1)begin
        @(negedge clk_wr);
      wr_en=1;
      wdata=$random;
      end
    
      @(negedge clk_wr);
    wr_en=0;
    wdata=0;
    end
  endtask
  
  task read(input reg[DEPTH:0] no_of_loc);
    begin
      for(i=0;i<no_of_loc;i=i+1)begin
        @(negedge clk_rd);
      rd_en=1;
    end
      @(negedge clk_rd);
    rd_en=0;
    end
  endtask
  
  always begin
    clk_wr=0;#(WR_CLK_TP/2);
    clk_wr=1;#(WR_CLK_TP/2);
  end
  always begin
    clk_rd=0;#(RD_CLK_TP/2);
    clk_rd=1;#(RD_CLK_TP/2);
  end
  
  initial begin
    rst=1;
    repeat(2)@(posedge clk_wr);
    rst=0;
    
    if($value$plusargs("testcase=%s",testcase)) $display("\n** Testcase %0s is executed successfully! **\n", testcase);
    else $display("\n** Testcase is not captured! **\n");
    
    case(testcase)
      "test_wr":write(DEPTH);
      "test_rd": read(DEPTH);
      "test_overflow":write(DEPTH+5);
      "test_underflow":read(DEPTH+5);
      "test_all_error":begin write(DEPTH+5);read(DEPTH+5); end
      "test_concurrency":begin
        fork
          for(j=0;j<WR_NUM;j=j+1)begin
            write(1);
            wr_delay=$urandom_range(0,MAX_WR_DELAY);
            repeat(wr_delay)@(negedge clk_wr);
            
          end
          for(k=0;k<RD_NUM;k=k+1)begin
            
            read(1);
            rd_delay=$urandom_range(0,MAX_RD_DELAY);
            repeat(rd_delay)@(negedge clk_rd);
          end
        join
      end
      default:begin write(DEPTH); read(DEPTH); end
    endcase
      

  end
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    #400;
    $finish;
  end
endmodule