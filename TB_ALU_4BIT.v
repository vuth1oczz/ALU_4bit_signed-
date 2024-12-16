 `timescale 1ps/1ps
module alu_4bit_signed_tb();
reg [7:0] input_data [0:511];
reg [4:0] output_golden [0:511];
reg signed [3:0] f_num, s_num;
reg carry_in;
reg signed [4:0]  expected ;
reg select_add_sub;
wire signed [7:0] result;
wire signed [4:0] result_division;
wire signed[3:0] remainder;
 reg clk, rst,enable;
 reg [1:0] op_code;
wire [0:6] led_unit, led_tens, led_hund, led_dau, led_so1, led_so2, led_so1_dau, led_so2_dau;

//ALU dut(f_num, s_num,op_code, clk, rst, result);
ALU dut(f_num, s_num,op_code, clk, rst, result);
integer i;
integer mismatch = 0;
initial begin
    clk =1;
    forever #5 clk = ~clk;
end
initial begin
$readmemb("C:/Users/VU THANH LOC/Verilog/au_4bit_signed/input_ALU.txt",input_data);
for (i=0 ; i<512; i=i+2) begin
    f_num = input_data[i][7:4];
    s_num = input_data[i][3:0];
    op_code = input_data[i+1];
    rst =1;
    #20 rst =0;
    #70;
    case(op_code) 
    2'b00: $display("%d +%d = %d\n", f_num, s_num, result);
    2'b01: $display("%d -%d = %d\n", f_num, s_num, result);
    2'b10: $display("%d *%d = %d\n", f_num, s_num, result);
    2'b11: $display("%d /%d = %d\n", f_num, s_num, result);
    endcase
    
end 

//op_code = 2'b00;
// f_num = 4'b0111;
// s_num = 4'b0101;
// enable = 1;
// rst =1;
// #10 rst =0;
// #100;
// //op_code = 2'b11;
// f_num = 4'b0111;
// s_num = 4'b0111;
// enable =1;
// rst = 1;
// #20 rst =0; 
// #100;
$stop;
end
endmodule 
