module decimal_converter
  (
    input  wire clk,
    input  wire signed [31:0] value,
	 output wire [31:0] out
  );
 
  wire signed [31:0] vp; 
  wire signed [31:0] v0;
  wire signed [31:0] v1;
  wire signed [31:0] v2;
  wire signed [31:0] v3;
  wire signed [31:0] v4;
  wire signed [31:0] v5;
  wire signed [31:0] v6;
  wire signed [31:0] v7;
  
  assign vp = value < 0 ? -value : value;
  
  decimal_converter_step step0(clk, vp, v0, out[3:0]);
  decimal_converter_step step1(clk, v0, v1, out[7:4]);
  decimal_converter_step step2(clk, v1, v2, out[11:8]);
  decimal_converter_step step3(clk, v2, v3, out[15:12]);
  decimal_converter_step step4(clk, v3, v4, out[19:16]);
  decimal_converter_step step5(clk, v4, v5, out[23:20]);
  decimal_converter_step step6(clk, v5, v6, out[27:24]);
  decimal_converter_step step7(clk, v6, v7, out[31:28]);
endmodule

module decimal_converter_step
  (
    input  wire clk,
    input  wire signed [31:0] v_in,
    output wire signed [31:0] v_out,
    output wire signed [3:0] digit
  );
  
  reg [31:0] v_div;
  reg [31:0] v_rem;
  
  wire [63:0] v_tmp;
  
  assign v_tmp = v_in * 32'h1999_999A;
  
  always @(posedge clk)
  begin
    v_div = v_tmp[63:32];
    v_rem = v_in - (10 * v_div);
  end
  
  assign v_out = v_div;
  assign digit = v_rem;
endmodule