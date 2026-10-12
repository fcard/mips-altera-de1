module jump_address_direct
  (
    input  wire [31:0] pc_plus_1,
	 input  wire [25:0] jump,
	 output wire [31:0] jump_address_direct
  );
  
  assign jump_address_direct = (pc_plus_1[31:28] << 28) + (jump << 2);
endmodule