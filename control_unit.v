module control_unit
  (
    input  wire clk,
	 input  wire pl_text_out,
    input  wire [31:0] instruction,
	 output wire write,
	 output wire [4:0] rs,
	 output wire [4:0] rt,
	 output wire [4:0] rd,
	 output wire [4:0] shamt,
	 output wire [5:0] funct,
	 output wire use_immediate,
	 output wire [15:0] immediate,
	 output wire [1:0] jump_type,
	 output wire [25:0] jump,
	 output wire [2:0] branch_type,
	 output wire load,
	 output wire [1:0] result_type,
	 output wire [1:0] load_type,
	 output wire [5:0] opcode,
	 output wire pl_signals_out
  );
  
  reg pl_signals_out_r;
  
  wire [4:0] rt_p;
  wire [4:0] rd_p;
  wire [5:0] funct_p;
  
  wire [20:0] signals_opcode;
  wire [20:0] signals_funct;
  wire [20:0] signals;
  
  assign pl_signals_out = pl_signals_out_r;
  
  assign opcode  = instruction[31:26];
  assign rs      = instruction[25:21];
  assign rt_p    = instruction[20:16];
  assign rd_p    = instruction[15:11];
  assign shamt   = instruction[10:6];
  assign funct_p = instruction[5:0];
  
  assign immediate = instruction[15:0];
  assign jump = instruction[25:0];
  
  signals_from_opcode sfo(opcode, signals_opcode);
  signals_from_funct  sff(funct_p, signals_funct);
  assign signals = opcode == 0 ? signals_funct : signals_opcode;
  
  assign write = signals[20];
  assign rt = rt_p; // signals[19] ? rt_p : 5'b00000;
  assign rd = signals[18] ? (signals[17] ?    0 :   31)
                          : (signals[17] ? rt_p : rd_p);
  assign funct = signals[16:11];
  assign use_immediate = signals[10];
  assign jump_type = signals[9:8];
  assign branch_type = signals[7:5];
  assign load = signals[4];
  assign result_type = signals[3:2];
  assign load_type = signals[1:0];
  
  always @(posedge clk)
  begin
    if (pl_text_out)
      pl_signals_out_r = 1;
    else
	   pl_signals_out_r = 0;
  end
endmodule

module signals_from_opcode(input wire [5:0] o, output wire [20:0] out);
  assign out = o ==  2 ? 21'b0_1_11_111111_0_01_000_1_00_00 : // jump
               o ==  3 ? 21'b1_1_10_111111_0_01_000_1_11_00 : // jump and link
					o ==  4 ? 21'b0_1_11_111111_0_10_001_1_00_00 : // branch if equal
					o ==  5 ? 21'b0_1_11_111111_0_10_010_1_00_00 : // branch if not equal
					o ==  6 ? 21'b0_1_11_111111_0_10_011_1_00_00 : // branch if less than or equal to zero
					o ==  7 ? 21'b0_1_11_111111_0_10_100_1_00_00 : // branch if greater than zero
					o ==  8 ? 21'b1_0_01_100000_1_00_000_1_00_00 : // add immediate
					o ==  9 ? 21'b1_0_01_100001_1_00_000_1_00_00 : // add unsigned immediate
					o == 10 ? 21'b1_0_01_101010_1_00_000_1_00_00 : // set less than immediate
					o == 11 ? 21'b1_0_01_101011_1_00_000_1_00_00 : // set less than immediate unsigned
					o == 12 ? 21'b1_0_01_100100_1_00_000_1_00_00 : // bitwise `and` immediate
					o == 13 ? 21'b1_0_01_100101_1_00_000_1_00_00 : // bitwise `or` immediate
					o == 15 ? 21'b1_0_01_001111_1_00_000_1_00_00 : // load upper immediate
					o == 16 ? 21'b1_0_00_001010_1_00_000_1_00_00 : // move from co-processor 0
					o == 32 ? 21'b1_0_01_111111_1_00_000_1_10_00 : // load byte
					o == 35 ? 21'b1_0_01_111111_1_00_000_1_10_01 : // load word
					o == 36 ? 21'b1_0_01_111111_1_00_000_1_10_10 : // load byte unsigned
					o == 37 ? 21'b1_0_01_111111_1_00_000_1_10_11 : // load halfword unsigned
					o == 40 ? 21'b0_0_01_111111_1_00_000_0_10_00 : // store byte
					o == 41 ? 21'b0_0_01_111111_1_00_000_0_10_11 : // store halfword
					o == 43 ? 21'b0_0_01_111111_1_00_000_0_10_01 : // store word
					          21'b0_1_11_111111_1_11_111_1_00_00;
endmodule

module signals_from_funct(input wire [5:0] f, output wire [20:0] out);
  assign out = f ==  0 ? 21'b1_1_00_000000_0_00_000_1_00_00 : // left logical shift
               f ==  2 ? 21'b1_1_00_000010_0_00_000_1_00_00 : // right logical shift
					f ==  3 ? 21'b1_1_00_000011_0_00_000_1_00_00 : // right arithmetic shift
					f ==  8 ? 21'b0_1_11_001000_0_11_000_1_00_00 : // jump to register
					f ==  9 ? 21'b1_1_10_001001_0_11_000_1_11_00 : // jump and link to register
					f == 16 ? 21'b1_1_00_010000_0_00_000_1_01_00 : // move from HI register
					f == 17 ? 21'b0_1_11_010001_0_00_000_1_00_00 : // move to HI register
					f == 18 ? 21'b1_1_00_010010_0_00_000_1_01_00 : // move from LO register
					f == 19 ? 21'b0_1_11_010011_0_00_000_1_00_00 : // move to LO register
					f == 24 ? 21'b0_1_11_011000_0_00_000_1_00_00 : // multiply
					f == 25 ? 21'b0_1_11_011001_0_00_000_1_00_00 : // multiply (unsigned)
					f == 26 ? 21'b0_1_11_011010_0_00_000_1_00_00 : // divide
					f == 27 ? 21'b0_1_11_011011_0_00_000_1_00_00 : // divide (unsigned)
					f == 32 ? 21'b1_1_00_100000_0_00_000_1_00_00 : // add
					f == 33 ? 21'b1_1_00_100001_0_00_000_1_00_00 : // add (unsigned)
					f == 34 ? 21'b1_1_00_100010_0_00_000_1_00_00 : // sub
					f == 35 ? 21'b1_1_00_100011_0_00_000_1_00_00 : // sub (unsigned)
					f == 36 ? 21'b1_1_00_100100_0_00_000_1_00_00 : // bitwise `and`
					f == 37 ? 21'b1_1_00_100101_0_00_000_1_00_00 : // bitwise `or`
					f == 38 ? 21'b1_1_00_100110_0_00_000_1_00_00 : // bitwise `xor`
					f == 39 ? 21'b1_1_00_100111_0_00_000_1_00_00 : // bitwise `nor`
					f == 42 ? 21'b1_1_00_101010_0_00_000_1_00_00 : // set less than
					f == 43 ? 21'b1_1_00_101011_0_00_000_1_00_00 : // set less than (unsigned)
					          21'b0_1_11_111111_1_11_111_1_00_00;
endmodule
					