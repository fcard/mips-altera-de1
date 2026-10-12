module branch_unit
  (
    input  wire [31:0] a,
    input  wire [31:0] b,
	 input  wire [2:0] branch_type,
	 output wire bry
  );
  
  assign bry = branch_type == 3'b000 ? 1'b1 :
               branch_type == 3'b001 ? a == b :
					branch_type == 3'b010 ? a != b :
					branch_type == 3'b011 ? a < 0 :
					branch_type == 3'b100 ? a > 0 : 1'b0;
endmodule