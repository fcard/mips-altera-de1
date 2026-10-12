module multiplication_unit
  (
    input  wire clk,
    input  wire pl_data,
	 input  wire paused,
    input  wire signed [31:0] a,
	 input  wire signed [31:0] b,
	 input  wire [5:0]  funct,
	 input  wire [5:0]  opcode,
	 output wire [31:0] result
  );
  
  reg [31:0] a0;
  reg [31:0] b0;
  
  reg [31:0] hi;
  reg [31:0] lo;
  
  reg is_div;
  reg result_is_neg;
  
  wire [31:0] mul_hi;
  wire [31:0] mul_lo;
  wire [31:0] div;
  wire [31:0] rem;
  
  idivider idiv(clk,a0,b0,div,rem);
  
  assign {mul_hi, mul_lo} = a0 * b0;
  
  always @(posedge clk)
  if (~paused)
  begin
    if (is_div)
	 begin
      hi <= rem;
	   if (result_is_neg)
        lo <= -div;
		else
        lo <= div;
	 end
	 else
	 begin
      hi <= mul_hi;
      lo <= mul_lo;
	 end

	 if (pl_data)
	 begin
      if (funct == 24 || funct == 25)
  	   begin
	     a0 <= a;
	     b0 <= b;
		  is_div <= 0;
	   end
      else if (funct == 26)
	   begin
	     a0 <= a < 0 ? -a : a;
	     b0 <= b < 0 ? -b : b;
	     is_div <= 1;
		  result_is_neg <= a < 0 ? b >= 0 : b < 0;
	   end
	   else if (funct == 27)
      begin
	     a0 <= a;
	     b0 <= b;
	  	  is_div <= 1;
		  result_is_neg <= 0;
	   end
    end
  end
  assign result = funct == 16 ? hi :
                  funct == 18 ? lo : -1;
endmodule