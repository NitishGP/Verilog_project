module moore_1011_nonoverlap(input clk,rst,valid,data_in,
                             output reg pat_dec);
  
  parameter S_R=  5'b00001;
  parameter S_1=  5'b00010;
  parameter S_10= 5'b00100;
  parameter S_101=5'b01000;
  parameter S_1011=5'b10000;
  
  reg[4:0] prestate, nexstate;
  
  always@(posedge clk)begin
    if(rst)    begin
      prestate = S_R;
    end
    else begin
      if(valid) begin
        case(prestate)
          S_R : begin
            pat_dec=0;
            if(data_in) begin
              nexstate = S_1;
            end
            else begin
              nexstate = S_R;
            end
          end 
          S_1 : begin
            pat_dec=0;
            if(data_in) begin
              nexstate = S_1;
            end
            else begin
              nexstate = S_10;
            end
          end 
          S_10: begin
            pat_dec=0;
            if(data_in) begin
              nexstate = S_101;
            end
            else begin
              nexstate = S_R;
            end
          end 
          S_101:begin
            pat_dec=0;
            if(data_in) begin
              nexstate = S_1011;
            end
            else begin
              nexstate = S_10;
            end
          end
          S_1011:begin
            pat_dec=1;
            if(data_in) begin
              nexstate = S_1;
            end
            else begin
              nexstate = S_R ;
            end
          end
        endcase
      end
    end
  end
      
  always@(nexstate) prestate=nexstate;
  
endmodule

module tb;
  reg clk,rst,valid,data_in;
  wire pat_dec;
  
  integer count;
  moore_1011_nonoverlap dut( clk,rst,valid,data_in,pat_dec);
  always begin
    clk=0;#5;
    clk=1;#5;
  end
  
  initial begin
    count=0;
    rst=1;
    valid=0;
    repeat(2)@(posedge clk);
    rst=0;
    valid=1;
    
    repeat(500)begin
      @(posedge clk);
      valid=1;
      data_in=$random;
      @(posedge clk); 
      valid=0;
      data_in=0;
    end
    
  end
  
  always@(posedge pat_dec) count=count+1;
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    #5000;
    $display("Total sequence detected = %0d", count);
    $finish();
  end
  
endmodule
