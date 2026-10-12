module program_counter
  (
    input  wire clk,
	 input  wire pl_fetch,
	 input  wire paused,
	 input  wire [25:0] jump,
	 input  wire [1:0]  jump_type,
	 input  wire [15:0] immediate,
	 input  wire [31:0] rs,
	 input  wire        bry,
	 output wire [31:0] address,
	 output wire pl_text
  );
  
  reg [31:0] pc;
  reg pl_text_r;
  
  wire [31:0] jump_goal_direct;
  wire [31:0] jump_goal_branch;
  wire [31:0] jump_goal;
  wire [31:0] next_pc_address;
  wire [31:0] pc_plus_1;
  
  initial
  begin
    pc = 32'h0040_0000;
  end
  
  assign pc_plus_1 = pc + 4;
  
  jump_address_direct jad(pc_plus_1, jump, jump_goal_direct);
  jump_address_branch jab(pc_plus_1, immediate, jump_goal_branch);
  
  assign jump_goal = jump_type[1] ? (jump_type[0] ? rs : jump_goal_branch)
                                  : (jump_type[0] ? jump_goal_direct : pc_plus_1);
  
  assign next_pc_address = bry ? jump_goal : pc_plus_1;
  
  always @(posedge clk)
  begin
    if (~paused & pl_fetch)
    begin
      pc <= next_pc_address;
    end
	 if (pl_fetch)
	   pl_text_r <= 1;
	 else
	   pl_text_r <= 0;
  end
  
  assign address = pc;
  assign pl_text = pl_text_r;
endmodule