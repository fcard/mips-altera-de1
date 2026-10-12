module mips32
  (
    input  wire CLOCK_50,
	 input  wire [3:0] KEY,
	 input  wire [9:0] SW,
	 output wire [6:0] HEX0,
	 output wire [6:0] HEX1,
	 output wire [6:0] HEX2,
	 output wire [6:0] HEX3,
	 output wire [9:0] LEDR,
	 output wire [7:0] LEDG
  );
  
  wire [31:0] rs;
  wire [31:0] rt;

  wire [15:0] immediate;

  wire [25:0] jump;
  wire [1:0]  jump_type;
  wire bry;
  
  wire load;
  wire [31:0] text_address;
  wire [31:0] data_address;
  wire [31:0] instruction;
  wire [31:0] data;
  
  wire write_to_register;
  wire [4:0] rs_id;
  wire [4:0] rt_id;
  wire [4:0] rd_id;
  wire [4:0] shamt;
  wire [5:0] funct;
  wire use_immediate;
  wire [2:0] branch_type;
  wire [1:0] result_type;
  wire [1:0] load_type;
  wire [5:0] opcode;
  
  wire [31:0] data_to_register;
  wire [31:0] arg2;
  wire [31:0] alu_result;
  wire [31:0] mult_result;
  
  reg paused;
  
  reg [31:0] data_address_display;
  wire [31:0] data_display;
  wire [31:0] dd;
  wire [31:0] display_value;
  wire [31:0] rx;
  
  wire [31:0] data_write;
  
  wire [6:0] hex3_tmp;
  wire [31:0] decimal;
  wire [31:0] dd0;
  wire dds;
  
  wire key_back;
  wire key_forward;
  wire key_pause;
  
  reg pl_fetch;
  wire pl_text;
  wire pl_data;
  wire pl_text_out;
  wire [4:0] pl_data_out;
  wire pl_signals_out;
  wire pl_write_back;
  
  initial
  begin
    data_address_display = 0;
    paused = 1;
	 pl_fetch = 1;
  end
  
  program_counter pc(CLOCK_50, pl_fetch, paused, jump, jump_type, immediate, rs, bry, text_address, pl_text);
  
  assign data_write = rt;

  ram ram(CLOCK_50, pl_text, pl_data, paused, load, load_type, text_address,
          data_address, data_address_display, data_write, instruction,
			 data, data_display, pl_text_out, pl_data_out);

  control_unit cu(CLOCK_50, pl_text_out, instruction, write_to_register, rs_id, rt_id, rd_id,
                  shamt, funct, use_immediate, immediate, jump_type, jump,
						branch_type, load, result_type, load_type, opcode, pl_signals_out);

  assign data_to_register = result_type[1] ? (result_type[0] ? text_address + 4 : data)
                                           : (result_type[0] ? mult_result : alu_result);

  assign data_address = result_type == 2'b10 || ~load ? (rs + {{16{immediate[15]}}, immediate}) : 0;
  
  register_bank rb(CLOCK_50, pl_data_out, pl_signals_out, paused, write_to_register, data_address_display, rs_id, rt_id, rd_id,
                   data_to_register, rs, rt, rx, pl_data, pl_write_back);
  
  assign arg2 = use_immediate ? {{16{immediate[15]}}, immediate} : rt;
  
  alu alu(rs, arg2, shamt, funct, alu_result);
  multiplication_unit mu(CLOCK_50, pl_data, paused, rs, rt, funct, opcode, mult_result);
  branch_unit bu(rs, rt, branch_type, bry);
  
  assign dd = SW[3] ? (SW[2] ? (SW[1] ? (SW[0] ? rs_id : rt_id)
                                      : (SW[0] ? rs : rt))
									  : (SW[1] ? (SW[0] ? immediate : -1)
									           : (SW[0] ? -1 : -1))) :
              SW[2] ? (SW[1] ? (SW[0] ? data_to_register : funct)
                             : (SW[0] ? opcode : result_type )) :
              SW[1] ? (SW[0] ? rd_id : rx) :
              SW[0] ? text_address : data_display;
  
  decimal_converter dc(CLOCK_50, dd, decimal);
  
  assign dd0 = SW[7] ? decimal : dd;
  assign dds = $signed(dd) < 0 ? 1 : 0;
  
  assign display_value = SW[8] ? (dd0 >> 16) : dd0;
  
  seg7_decoder s0(display_value[ 3: 0], HEX0);
  seg7_decoder s1(display_value[ 7: 4], HEX1);
  seg7_decoder s2(display_value[11: 8], HEX2);
  seg7_decoder s3(display_value[15:12], hex3_tmp);
  
  assign HEX3 = dds & SW[7] ? 7'b011_1111 : hex3_tmp;

  keypress kp0(CLOCK_50, KEY[3], key_back);
  keypress kp1(CLOCK_50, KEY[2], key_forward);
  keypress kp2(CLOCK_50, KEY[1], key_pause);
  
  always @(posedge CLOCK_50)
  begin
    if (key_pause)
	   paused = ~paused;
	 else if (SW[9] & pl_fetch)
	   paused = 1;

    if (pl_write_back)
	   pl_fetch = 1;
	 else if (~paused)
	   pl_fetch = 0;

	 if (key_back)
	   data_address_display = data_address_display - 1;
	 else if (key_forward)
	   data_address_display = data_address_display + 1;
  end
  
  assign LEDR[0] = paused;
  assign LEDR[9] = write_to_register;
  assign LEDR[8] = use_immediate;
  assign LEDR[7:6] = jump_type;
  assign LEDR[5:3] = branch_type;
  assign LEDR[2] = load;
  assign LEDR[1] = bry;
  assign LEDG = data_address_display[7:0];
endmodule