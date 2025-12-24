//Code your design here
module async_fifo(rst,wdata,rdata,clk_wr,clk_rd,full,empty,overflow,underflow,rd_en,wr_en);
  parameter WIDTH = 8;
  parameter DEPTH = 8;
  parameter PTR_WIDTH = $clog2(WIDTH);
  
  input rd_en,wr_en,clk_wr,clk_rd,rst;
  input [WIDTH-1:0] wdata; 
  
  output reg [WIDTH-1:0] rdata;
  output reg full,empty, overflow, underflow;

  
  reg[WIDTH-1:0] mem [DEPTH-1:0];
  reg [PTR_WIDTH-1:0]rd_ptr,wr_ptr,wr_ptr_clk_rd,rd_ptr_clk_wr;
  reg wr_toggle_f, rd_toggle_f,wr_toggle_f_clk_rd,rd_toggle_f_clk_wr;
  
  integer i;
  
  always @(posedge clk_wr )begin
    if(rst) begin
      rdata=0;
      full=0;
      overflow=0;
      wr_toggle_f=0;
      rd_toggle_f_clk_wr=0;
      wr_ptr=0;
      rd_ptr_clk_wr=0;
      
      for(i=0; i< DEPTH;i=i+1) mem[i]=0;
    end 
    else begin
      // Describe functionality of fifo, read and write
      
      //Write:: if wr_en issued, ckeck for full and give overflow or write data
      
      
      overflow= 0;
      if(wr_en)  if(full) overflow=1;
      else 
        begin
        	mem[wr_ptr] = wdata;
        
          if(wr_ptr == DEPTH-1)   wr_toggle_f = ~wr_toggle_f;
        
        	wr_ptr= wr_ptr +1;
        end
      end
      
      
    end
  always @(posedge clk_rd )begin
    if(rst) begin
      rdata=0;
      empty=0;
      underflow=0;
      rd_toggle_f=0;
      wr_toggle_f_clk_rd=0;
      rd_ptr=0;
      wr_ptr_clk_rd=0;
      
      for(i=0; i< DEPTH;i=i+1) mem[i]=0;
    end 
    else begin
      //REad::: if rd_en issued, check for empty and issue underflow error else read from fifo
      
      //Else do rollover
      underflow=0;
    if(rd_en)  if(empty) underflow =1;
    
      else begin
            rdata = mem[rd_ptr];

        if(rd_ptr == DEPTH-1)  rd_toggle_f = ~rd_toggle_f;

            rd_ptr = rd_ptr + 1;
       end
      
    end
  end
  
  always@(posedge clk_rd) begin
      wr_ptr_clk_rd <= wr_ptr;
      wr_toggle_f_clk_rd <= wr_toggle_f;
  end
  always@(posedge clk_wr) begin
      rd_ptr_clk_wr <= rd_ptr;
      rd_toggle_f_clk_wr <= rd_toggle_f;
  end
      
  always @(*)begin
    if(wr_ptr_clk_rd == rd_ptr_clk_wr && wr_toggle_f_clk_rd != rd_toggle_f_clk_wr) full=1;
     else full=0;
    if(wr_ptr_clk_rd == rd_ptr_clk_wr && wr_toggle_f_clk_rd == rd_toggle_f_clk_wr) empty=1;
     else empty=0;
  end
      
endmodule