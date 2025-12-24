module moore_1101_overlap(input clk,rst,valid, input data_in, output reg seq_dec);
  
  parameter S_R 	= 5'b00001;
  parameter S_1 	= 5'b00010;
  parameter S_2 	= 5'b00100;
  parameter S_3 	= 5'b01000;
  parameter S_4 	= 5'b10000;
  
  reg [4:0] nxtstate,prestate;
  
  always@(posedge clk)begin
    if(rst) begin
      seq_dec=0;
      prestate = S_R;
      nxtstate = S_R;
    end
    else    prestate = nxtstate;
  end
  
  always@(*)begin
    if(valid) begin
 	  case(prestate)
 	    S_R:begin
          seq_dec=0;
          if(data_in) nxtstate=S_1;
          else        nxtstate=S_R;
 	    end  
       S_1:begin
          seq_dec=0;
         if(data_in) nxtstate=S_2;
          else        nxtstate=S_R;
 	    end  
       S_2:begin
          seq_dec=0;
         if(data_in) nxtstate=S_2;
          else        nxtstate=S_3;
 	    end  
       S_3:begin
          seq_dec=0;
         if(data_in) nxtstate=S_4;
          else        nxtstate=S_R;
 	    end  
       S_4:begin
          seq_dec=1;
          if(data_in) nxtstate=S_1;
          else        nxtstate=S_R;
 	    end  
      endcase
    end
      else seq_dec=0;
    
  end
endmodule

module tb; 
  reg clk=0;
  reg rst,valid;
  reg data_in;
  wire seq_dec;
  
  integer  count;
  
  moore_1101_overlap dut(.clk(clk), .rst(rst), .valid(valid), .data_in(data_in), .seq_dec(seq_dec));
  
  always #5 clk=~clk;
  
  initial begin
    count=0;
    rst=1;
    valid=0;
    repeat(2)@(posedge clk);
    rst=0;
    repeat(500) begin
      @(posedge clk);
      valid=1;
      data_in=$random;
      @(posedge clk);
      valid=0;
      data_in=0;
    end
    
  end
  
  always @(posedge seq_dec) count = count + 1;
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    #1500;
    $display("Total no 101101 sequence detected is %0d",count);
    #10;
    $finish();
  end
endmodule