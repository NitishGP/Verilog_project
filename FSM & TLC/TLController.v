`timescale 1ms/1ms
module TrafficLight(input clk,rst, output reg[6*8:1]Light);
	parameter S0 = "GREEN";
	parameter S1 ="YELLOW";
	parameter S2 = "RED";
  reg[6*8:1] p_s,n_s;
  
  
  integer count;
  always@(posedge clk)begin
    if(rst) begin 
      p_s = S0;
      n_s = S0;
      count=0;
    end
    else begin
        p_s = n_s;
        count = count + 1;
     	Light = p_s;
      end
  end
  
  always@(p_s or count)begin
    case(p_s)
      S0 : begin
        if(count==30)begin
          n_s = S1;
          count=0;
        end
      end 
      S1 : begin
        if(count==100)begin
          n_s = S2;
          count=0;
        end
      end 
      S2 : begin
        if(count==100)begin
          n_s = S0;
          count=0;
        end
      end
    endcase
  end
endmodule

module tb;
  
  reg clk,rst;
  wire [6*8:1] Light;
  
  TrafficLight dut(clk,rst, Light);
  
  always begin
    clk=0;#50;
    clk=1;#50;
  end
  
  initial begin
    rst=1;
    repeat(2)@(posedge clk);
    rst=0;
  end
  
  initial $monitor("%0t:::%0s", $time,Light);
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    #10000;
    $finish();
  end
endmodul