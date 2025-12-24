module mealy_1011_overlap(input clk,rst,valid,data_in,
                             output reg pat_dec);
  
  parameter S_R=4'b0001;
  parameter S_1=4'b0010;
  parameter S_10=4'b0100;
  parameter S_101=4'b1000;
  
  reg[3:0] prestate, nexstate;
  
  always@(posedge clk)begin
    if(rst)    begin
      prestate = S_R;
      pat_dec=0;
    end
    else begin
      if(valid) begin
        case(prestate)
          S_R : begin
            if(data_in) begin
              nexstate = S_1;
              pat_dec = 0;
            end
            else begin
              nexstate = S_R;
              pat_dec = 0;
            end
          end 
          S_1 : begin
            if(data_in) begin
              nexstate = S_1;
              pat_dec = 0;
            end
            else begin
              nexstate = S_10;
              pat_dec = 0;
            end
          end 
          S_10: begin
            if(data_in) begin
              nexstate = S_101;
              pat_dec = 0;
            end
            else begin
              nexstate = S_R;
              pat_dec = 0;
            end
          end 
          S_101:begin
            if(data_in) begin
              nexstate = S_1;
              pat_dec = 1;
            end
            else begin
              nexstate = S_10;
              pat_dec = 0;
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
  mealy_1011_overlap dut( clk,rst,valid,data_in,pat_dec);
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