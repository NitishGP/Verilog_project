module sync_fifo(rst,wdata,rdata,clk,full,empty,overflow,underflow,rd_en,wr_en);
  parameter WIDTH = 8;
  parameter DEPTH = 8;
  parameter PTR_WIDTH = $clog2(WIDTH);
  
  input rd_en,wr_en,clk,rst;
  input [WIDTH-1:0] wdata; 
  
  output reg [WIDTH-1:0] rdata;
  output reg full,empty, overflow, underflow;

  
  reg[WIDTH-1:0] mem [DEPTH-1:0];
  reg [PTR_WIDTH-1:0]rd_ptr,wr_ptr;
  reg wr_toggle_f, rd_toggle_f;
  
  integer i;
  
  always @(posedge clk)begin
    if(rst) begin
      rdata=0;
      full=0;
      empty=0;
      overflow=0;
      underflow=0;
      wr_toggle_f=0;
      rd_toggle_f=0;
      wr_ptr=0;
      rd_ptr=0;
      
      for(i=0; i< DEPTH;i=i+1) mem[i]=0;
    end 
    else begin
      // Describe functionality of fifo, read and write
      
      //Write:: if wr_en issued, ckeck for full and give overflow or write data
      
      overflow = 0;
      underflow= 0;
      if(wr_en)  if(full) overflow=1;
      else 
        begin
        	mem[wr_ptr] = wdata;
        
          if(wr_ptr == DEPTH-1)   wr_toggle_f = ~wr_toggle_f;
        
        	wr_ptr= wr_ptr +1;
        end
      end
      
      //REad::: if rd_en issued, check for empty and issue underflow error else read from fifo
      
      //Else do rollover
    if(rd_en)  if(empty) underflow =1;
    
      else begin
            rdata = mem[rd_ptr];

        if(rd_ptr == DEPTH-1)  rd_toggle_f = ~rd_toggle_f;

            rd_ptr = rd_ptr + 1;
       end
      
    end
  
      
  always @(*)begin
     if(wr_ptr == rd_ptr && wr_toggle_f != rd_toggle_f) full=1;
     else full=0;
     if(wr_ptr == rd_ptr && wr_toggle_f == rd_toggle_f) empty=1;
     else empty=0;
  end
      
endmodule