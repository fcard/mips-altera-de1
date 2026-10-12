module register_bank
  (
    input  wire clk,
	 input  wire [4:0] pl_data_out,
	 input  wire pl_signals_out,
	 input  wire paused,
	 input  wire write,
	 input  wire [31:0] rx,
    input  wire [4:0]  rs,
	 input  wire [4:0]  rt,
	 input  wire [4:0]  rd,
	 input  wire [31:0] data,
	 output wire [31:0] rs_content,
	 output wire [31:0] rt_content,
	 output wire [31:0] rx_content,
	 output wire pl_data,
	 output wire pl_write_back
  );
  
  wire [31:0] registers[0:31];
  
  reg [31:0] rs_r;
  reg [31:0] rt_r;
  reg [31:0] rx_r;
  
  reg pl_data_r;
  reg pl_write_back_r;
  reg pl_signals_out_hold;
  
  reg [31:0] zero;
  reg [31:0] at;
  reg [31:0] v0;
  reg [31:0] v1;
  reg [31:0] a0;
  reg [31:0] a1;
  reg [31:0] a2;
  reg [31:0] a3;
  reg [31:0] t0;
  reg [31:0] t1;
  reg [31:0] t2;
  reg [31:0] t3;
  reg [31:0] t4;
  reg [31:0] t5;
  reg [31:0] t6;
  reg [31:0] t7;
  reg [31:0] s0;
  reg [31:0] s1;
  reg [31:0] s2;
  reg [31:0] s3;
  reg [31:0] s4;
  reg [31:0] s5;
  reg [31:0] s6;
  reg [31:0] s7;
  reg [31:0] t8;
  reg [31:0] t9;
  reg [31:0] k0;
  reg [31:0] k1;
  reg [31:0] gp;
  reg [31:0] sp;
  reg [31:0] fp;
  reg [31:0] ra;
  
  assign registers = '{zero, at, v0, v1, a0, a1, a2, a3, t0, t1, t2, t3, t4,
                             t5, t6, t7, s0, s1, s2, s3, s4, s5, s6, s7, t8,
									  t9, k0, k1, gp, sp, fp, ra};

  initial
  begin
    zero = 0;
	 sp = 32'h1001_0ffc;
  end
  
  always @(posedge clk)
  begin
    if (pl_signals_out | pl_signals_out_hold)
	 begin
		pl_data_r = ~paused;
		pl_signals_out_hold = paused;
	 end
	 else
	 begin
		pl_data_r = 0;
	 end
	 
    if ((~paused) & (pl_data_out == 1) & write)
	 begin
      case (rd)
		  1: at = data;
		  2: v0 = data;
		  3: v1 = data;
		  4: a0 = data;
		  5: a1 = data;
		  6: a2 = data;
		  7: a3 = data;
		  8: t0 = data;
		  9: t1 = data;
		 10: t2 = data;
		 11: t3 = data;
		 12: t4 = data;
		 13: t5 = data;
		 14: t6 = data;
		 15: t7 = data;
		 16: s0 = data;
		 17: s1 = data;
		 18: s2 = data;
		 19: s3 = data;
		 20: s4 = data;
		 21: s5 = data;
		 22: s6 = data;
		 23: s7 = data;
		 24: t8 = data;
		 25: t9 = data;
		 26: k0 = data;
		 27: k1 = data;
		 28: gp = data;
		 29: sp = data;
		 30: fp = data;
		 31: ra = data;
	   endcase
    end

	 if (pl_data_out == 1)
  		pl_write_back_r = 1;
	 else
  		pl_write_back_r = 0;
  end
  
  assign rx_content = registers[rx[4:0]];
  assign	rs_content = registers[rs];
  assign rt_content = registers[rt];
  
  assign pl_data = pl_data_r;
  assign pl_write_back = pl_write_back_r;
endmodule
