module jump_address_branch
  (
    input  wire [31:0] pc_plus_1,
	 input  wire [15:0] immediate,
	 output wire [31:0] jump_goal_branch
  );
  
  wire [31:0] extended_immediate;
  
  assign extended_immediate = {{16{immediate[15]}}, immediate} << 2;
  assign jump_goal_branch = pc_plus_1 + extended_immediate;
endmodule