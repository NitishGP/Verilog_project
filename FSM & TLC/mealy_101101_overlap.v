module mealy_101101_overlap(input clk,rst,valid,data_in, output reg seq_dec);
  
  parameter S_R 	= 6'b000001;
  parameter S_1 	= 6'b000010;
  parameter S_10 	= 6'b000100;
  parameter S_101 	= 6'b001000;
  parameter S_1011 	= 6'b010000;
  parameter S_10110 = 6'b100000;
  
  reg [5:0] nxtstate,prestate;
  reg op;
  
  always@(posedge clk)begin
    if(rst) begin
      seq_dec=0;
      prestate = S_R;
      nxtstate = S_R;
    end
    else begin
          prestate = nxtstate;
          seq_dec=op;
    end
  end
  
  always@(*)begin
    if(valid) begin
 	  case(prestate)
 	    S_R:begin
 	      if(data_in) 
 	        begin
 	        	nxtstate=S_1;
 	          op=0;
 	        end
 	      else
 	        begin
 	          nxtstate=S_R;
 	               op=0;
 	        end
 	    end 
 	    S_1:begin
 	      if(data_in) 
 	        begin
 	        	nxtstate=S_1;
 	               op=0;
 	        end
 	      else
 	        begin
 	          nxtstate=S_10;
 	               op=0;
 	        end
 	    end 
 	    S_10:begin
 	      if(data_in) 
 	        begin
 	        	nxtstate=S_101;
 	               op=0;
 	        end
 	      else
 	        begin
 	          nxtstate=S_R;
 	               op=0;
 	        end
 	    end 
 	    S_101:begin
 	      if(data_in) 
 	        begin
 	        	nxtstate=S_1011;
 	               op=0;
 	        end
 	      else
 	        begin
 	          nxtstate=S_10;
 	               op=0;
 	        end
 	    end 
 	    S_1011:begin
 	      if(data_in) 
 	        begin
 	        	nxtstate=S_1;
 	               op=0;
 	        end
 	      else
 	        begin
 	          nxtstate=S_10110;
 	               op=0;
 	        end
 	    end 
 	    S_10110:begin
 	      if(data_in) 
 	        begin
 	        	nxtstate=S_101;
 	               op=1;
 	        end
 	      else
 	        begin
 	          nxtstate=S_R;
 	               op=0;
 	        end
 	    end 
 	  endcase
 	 end
    else seq_dec=0;
  end
  
  
endmodule

module tb;
  reg clk=0;
  reg rst,valid,data_in;
  
  wire seq_dec;
  
  integer count;
  
  mealy_101101_overlap dut(.clk(clk), .rst(rst), .valid(valid), .data_in(data_in), .seq_dec(seq_dec));
  
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
    #1000;
    $display("Total no 101101 sequence detected is %0d",count);
    #10;
    $finish();
  end
endmodule