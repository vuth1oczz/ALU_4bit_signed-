//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////                                                                  ///////////////////////
/////////////////////                           FULL_ADDER 4 BIT                       ///////////////////////         
/////////////////////                                                                  ///////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

module full_adder( input a, input b, input carry_in, output s_out, output carry_out);
     assign s_out = (a ^ b) ^ carry_in;
     assign carry_out = (a & b) | ((a ^ b) & carry_in);
endmodule
module alu_add(
    input signed [3:0] f_num,
    input signed [3:0] s_num,
    input clk, 
    input add_en,
    output reg signed [7:0] result_add
);
wire carry_out;
wire [3:0] carry;
wire carry_in;
genvar i;
wire signed [4:0] result;
generate 
  for (i=0; i<4; i = i+1) begin : full_adder_ins
       full_adder fa(
                 .a(f_num[i]),
                 .b(s_num[i]),
                 .carry_in(i==0? 1'b0: carry[i-1]),
                 .s_out(result[i]),
                 .carry_out(carry[i])
       );
  end
 
endgenerate
     
    
assign result[4] = (f_num[3] == 0 ) ? 
                   ((s_num[3] == 1) ? 
                       ((carry[3] == 0) ? 1'b1 : 1'b0) 
                       : 1'b0
                   ) 
                   : ((s_num[3] == 0)? (
                        ((carry[3] == 0) ? 1'b1: 1'b0)
                   ) : 1'b1 ) ;

always @(posedge clk) begin
    if(add_en) result_add <= (result[4] == 1)? {3'b111, result} : {3'b000, result};
    else result_add <= 8'bx;
end
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////                                                                  ///////////////////////
/////////////////////                           FULL_ADDER 4 BIT                       ///////////////////////         
/////////////////////                                                                  ///////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////                                                                  ///////////////////////
/////////////////////                           SUB 4 BIT                              ///////////////////////         
/////////////////////                                                                  ///////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
module alu_sub(
    input signed [3:0] f_num,
    input signed [3:0] s_num,
    input clk,
    input enable_sub,
    output reg signed [7:0] result_sub
);
wire [3:0] s_num_temp = ~s_num +1;
wire signed [4:0] pre_result;
alu_add add(f_num, s_num_temp, clk, 1'b1, pre_result);
always @(posedge clk) begin
    if(enable_sub) result_sub <= (pre_result[4] == 1)? {3'b111, pre_result} : {3'b000, pre_result};
    else result_sub <= 8'bx;
end


endmodule


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////                                                                  ///////////////////////
/////////////////////                           SUB 4 BIT                              ///////////////////////         
/////////////////////                                                                  ///////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////








//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////                                                                  ///////////////////////
/////////////////////                           MULTIPLY 4 BIT                         ///////////////////////         
/////////////////////                                                                  ///////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

module multiplier(
       input signed [3:0] f_num,
       input signed [3:0] s_num,
       input clk,
       input rst,
       input enable_mul,
	   output reg signed [7:0] result_mul
);
reg [7:0] FNUM;
reg [3:0] SNUM;
reg FLAG_DAU;	
integer counter;
reg [7:0] product;
reg flag;
always @(posedge clk,  posedge rst) begin
if(enable_mul) begin
    if(rst) begin 
		    FNUM <= f_num[3] ? {4'b0,~f_num + 1}: {4'b0,f_num};
			SNUM <= s_num[3] ? ~s_num +1: s_num;
            FLAG_DAU <= ((f_num[3] == 1) ^ (s_num[3] == 1)) == 1 ? 1: 0;
		    counter <= 0 ;
		    flag <= 0;
		    product <= 0;
            result_mul <= 0;
    end else begin 
        if( counter <3 ) begin
                        if (SNUM[0] == 1) product <= product + FNUM;
                        else product <= product + 0;
                        FNUM <= FNUM << 1;
                        SNUM <= SNUM >> 1;
                        counter <= counter +1;
            
            end 
        else  begin 
            result_mul <= FLAG_DAU == 1 ? ~product +1 : product;
        end
    end
end else result_mul <= 8'bx;
end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////                                                                  ///////////////////////
/////////////////////                           MULTIPLY 4 BIT                         ///////////////////////         
/////////////////////                                                                  ///////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////                                                                  ///////////////////////
/////////////////////                           DIVISION 4 BIT                         ///////////////////////         
/////////////////////                                                                  ///////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

module divide(
    input signed [3:0] f_num,  // Q
    input signed [3:0] s_num,  // B
    input clk, rst, enable_divide,
    output  reg  signed [7:0] result_chia,
    output  reg signed [3:0]  remainder 
);

reg [2:0] counter;
reg [3:0] fnum;
reg [3:0] snum;
reg [4:0] remainder_pre;
reg[3:0] result_pre;
reg flag_remainder, flag_result, flag_zero;

always @(posedge clk or posedge rst) begin
if(enable_divide) begin
    if (rst) begin
        if(s_num == 4'b0) flag_zero <=1'b1;
        else flag_zero <= 1'b0;

        if((f_num[3] == 1'b1 & s_num[3] == 1'b0) | ((f_num[3] & s_num[3]) == 1'b1)) flag_remainder <= 1'b1;
        else flag_remainder <= 1'b0;

        if(f_num[3] ^ s_num[3]) flag_result <= 1'b1;
        else flag_result <= 1'b0;

        counter <= 3'b101;
        fnum <= (f_num[3])? ~f_num +4'b0001: f_num;
        snum <= (s_num[3])? ~s_num +4'b0001 : s_num;
        result_pre <= 4'b0;
        remainder_pre <= 5'b0;
    end else begin
    if (counter > 1 ) begin
          if({remainder_pre[2:0], fnum[3]} >= snum) begin
                 remainder_pre <= {remainder_pre[2:0], fnum[3]} - snum;
                 result_pre <= {result_pre[2:0], 1'b1};
                 //result_pre <= result_pre << 1;
                 fnum <= fnum <<1; 
          end else begin
                remainder_pre <= {remainder_pre[2:0], fnum[3]} ;
                result_pre <= {result_pre[2:0], 1'b0};
                //result_pre <= result_pre << 1;
                fnum <= fnum << 1;
          end
          counter <= counter -1;
        end else begin
            if(flag_zero) begin
                 result_chia <= 4'bx;
                 remainder <= 4'bx;
            end
            else begin
                if(flag_result) result_chia <= {3'b1,~{1'b0,result_pre} + 1};
                else result_chia <= {4'b0,result_pre};
                if(flag_remainder == 1'b1) remainder <= ~remainder_pre[3:0] + 1;
                else remainder <= remainder_pre[3:0];
            end
        end
    end
end else   
    begin 
        result_chia <= 4'bx;
        remainder <= 4'bx;
    end
end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////                                                                  ///////////////////////
/////////////////////                           DIVISION 4 BIT                         ///////////////////////         
/////////////////////                                                                  ///////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
module led7seg (
    input wire [3:0] binary_input, // Đầu vào 8 bit
    output reg [0:6] led_output // Đầu ra cho LED 7 thanh
);

    always @(*) begin
        case (binary_input)
            4'b0000: led_output = 7'b0000001; // 0
            4'b0001: led_output = 7'b1001111; // 1
            4'b0010: led_output = 7'b0010010; // 2
            4'b0011: led_output = 7'b0000110; // 3
            4'b0100: led_output = 7'b1001100; // 4
            4'b0101: led_output = 7'b0100100; // 5
            4'b0110: led_output = 7'b0100000; // 6
            4'b0111: led_output = 7'b0001111; // 7
            4'b1000: led_output = 7'b0000000; // 8
            4'b1001: led_output = 7'b0000100; // 9
            4'b1010: led_output = 7'b1111110;  // dau -
            default: led_output = 7'b1111111; // Tắt tất cả
        endcase
    end

endmodule

module encode_bcd(
    input wire [7:0]  decimal,
    input wire dau,
    output wire [0:6] led_unit,
    output wire [0:6]  led_tens,
    output wire [0:6] led_hund,
    output wire [0:6] led_dau
);
 reg [11:0] result = 12'b0;
 reg [19:0] temp = 20'b0;
 reg [3:0] ones, tens, hund, sign;
integer i;
always @(*) begin
    temp = {{result}, {decimal}};
for (i = 7; i >= 0; i = i-1 ) begin
        if (temp[11:8] >= 5) temp[11:8] = temp[11:8] + 4'b0011;
        if (temp[15:12] >= 5) temp [15:12] = temp[15:12] + 4'b0011;
        if (temp[19:16] >= 5) temp [19:16] = temp[19:16] + 4'b0011; 
        temp = temp << 1; 
end
if(dau == 1) sign = 4'b1010;
else sign  = 4'b1111;
ones = temp[11:8];
 tens = temp[15:12];
 hund = temp[19:16];
end

led7seg led_donvi (.binary_input(ones), .led_output(led_unit));
led7seg led_chuc ( .binary_input(tens), .led_output(led_tens));
led7seg led_tram (.binary_input(hund), .led_output(led_hund));
led7seg led_dauuu(.binary_input(sign), .led_output(led_dau));
endmodule



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////                                                                  ///////////////////////
/////////////////////                           FULL_ADDER 4 BIT                       ///////////////////////         
/////////////////////                                                                  ///////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////                                                                  ///////////////////////
/////////////////////                           ALU 4 BIT                              ///////////////////////         
/////////////////////                                                                  ///////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

module ALU(
    input signed [3:0] f_num,
    input signed [3:0] s_num,
    input [1:0] op_code,
    input clk,
    input rst,
    output reg signed [7:0] result_alu
    //output[0:6] led_f_num, led_f_num_signed, led_s_num, led_s_num_signed, led_unit, led_tens, led_hund, led_result_dau
);
 wire[7:0] result_add, result_sub;
 wire [7:0] result_mul;
 wire [7:0] result_division;
 wire [3:0] remainder;
 reg enable_add, enable_sub, enable_mul, enable_divide;
alu_add add(
    .f_num(f_num),
    .s_num(s_num),
    .clk(clk),
    .add_en(enable_add),
    .result_add(result_add)
 );
 alu_sub sub(
    .f_num(f_num),
    .s_num(s_num),
    .clk(clk),
    .enable_sub(enable_sub),
    .result_sub(result_sub)
 );
 multiplier mul(
    .f_num(f_num),
    .s_num(s_num),
    .clk(clk),
    .rst(rst),
    .enable_mul(enable_mul),
    .result_mul(result_mul)
 );
divide division(
    .f_num(f_num),
    .s_num(s_num),
    .clk(clk),
    .rst(rst),
    .enable_divide(enable_divide),
    .result_chia(result_division),
    .remainder(remainder)
);
always @(posedge clk or negedge rst) begin
    case(op_code)
    2'b00: begin
            enable_add <= 1;
            enable_sub <= 0;
            enable_divide <= 0;
            enable_mul <= 0;
            result_alu <= result_add;
    end
     2'b01: begin
        enable_sub <= 1;
        enable_add <= 0;
        enable_divide <= 0;
        enable_mul <= 0;
        result_alu <=result_sub;
    end
     2'b10: begin
        enable_sub <= 0;
        enable_add <= 0;
        enable_divide <= 0;
        enable_mul <= 1;
        result_alu <= result_mul;
    end
     2'b11: begin
         enable_sub <= 0;
        enable_add <= 0;
        enable_mul <= 0;
        enable_divide <= 1;
        result_alu <= result_division;
    end
    endcase
end
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////                                                                  ///////////////////////
/////////////////////                           ALU 4 BIT                              ///////////////////////         
/////////////////////                                                                  ///////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////