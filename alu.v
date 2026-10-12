module alu
  (
    input  wire [31:0] a,
	 input  wire [31:0] b,
	 input  wire [4:0]  shamt,
	 input  wire [5:0]  funct,
	 output wire [31:0] result
  );
  
  assign result = funct == 0  ? b << shamt :
                  funct == 2  ? b >> shamt :
						funct == 3  ? b >>> shamt :
						funct == 15 ? b << 16 :
						funct == 32 ? a + b :
						funct == 33 ? a + b :
						funct == 34 ? a - b :
						funct == 35 ? a - b :
						funct == 36 ? a & b :
						funct == 37 ? a | b :
						funct == 38 ? a ^ b :
						funct == 39 ? ~(a | b) :
						funct == 42 ? a < b :
						funct == 43 ? a < b : 0;
endmodule