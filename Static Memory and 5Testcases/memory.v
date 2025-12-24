module memory1(clk,rst,valid,wr_rd, addr,wdata, ready, rdata);
 
  
  parameter WIDTH=8;
  parameter DEPTH=8;
  parameter ADDR_WIDTH = $clog2(DEPTH);
  
  input clk,rst,valid,wr_rd; 
  input [ADDR_WIDTH-1:0]addr;
  input [WIDTH-1:0]wdata;

  output reg ready;
  output reg [WIDTH-1:0]rdata;
  
  integer i;
  
  reg [WIDTH-1:0] mem [DEPTH-1:0];
  
  always@(posedge clk or posedge rst)begin
    if(rst) begin// Reset
      ready<=0;
      rdata<=0;
      for(i=0;i<DEPTH;i=i+1) 
        mem[i]<=0;
    end 
    else begin
      if(valid) begin //Handshaking
        ready<=1;
        if(wr_rd)begin //Write operation
          
          mem[addr]<=wdata;
          
        end else begin //Read operation
          
          rdata<=mem[addr];
          
        end
      end else begin
        ready<=0;
        rdata<=0;
      end
    end
  end
  
endmodule








