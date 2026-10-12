module mux32_5
  (
    input  wire [4:0]  sel,
	 input  wire [31:0] in[0:31],
	 output wire [31:0] out
  );
  
  wire out0;
  wire out1;
  
  mux32_4 m0(sel[2:0], in[0:15],  out0);
  mux32_4 m1(sel[2:0], in[16:31], out1);
  
  assign out = sel[4] ? out1 : out0;
endmodule

module mux32_4
  (
    input  wire [3:0]  sel,
	 input  wire [31:0] in[0:15],
	 output wire [31:0] out
  );
  
  wire out0;
  wire out1;
  
  mux32_3 m0(sel[2:0], in[0:7],  out0);
  mux32_3 m1(sel[2:0], in[8:15], out1);
  
  assign out = sel[3] ? out1 : out0;
endmodule

module mux32_3
  (
    input  wire [2:0]  sel,
	 input  wire [31:0] in[0:7],
	 output wire [31:0] out
  );
  
  wire out0;
  wire out1;
  
  mux32_2 m0(sel[1:0], in[0:3], out0);
  mux32_2 m1(sel[1:0], in[4:7], out1);
  
  assign out = sel[2] ? out1 : out0;
endmodule

module mux32_2
  (
    input  wire [1:0]  sel,
	 input  wire [31:0] in[0:3],
	 output wire [31:0] out
  );
  
  assign out = sel[1] ? (sel[0] ? in[3] : in[2])
                      : (sel[0] ? in[1] : in[0]);
endmodule