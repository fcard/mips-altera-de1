module idivider
  (
    input  wire clk,
    input  wire [31:0] a,
	 input  wire [31:0] b,
	 output wire [31:0] div,
	 output wire [31:0] rem
  );
  
  wire signed [63:0] rem0;
  wire signed [63:0] rem1;
  wire signed [63:0] rem2;
  wire signed [63:0] rem3;

  wire signed [31:0] divu;
  wire signed [31:0] divp;
  wire signed [63:0] remf;
  
  wire signed [63:0] d;
  
  assign d = {b,32'h0000_0000};

  idivider_step #(24,31) step0(clk,a,d,divu[31:24],rem0);
  idivider_step #(16,23) step1(clk,rem0,d,divu[23:16],rem1);
  idivider_step #( 8,15) step2(clk,rem1,d,divu[15: 8],rem2);
  idivider_step #( 0, 7) step3(clk,rem2,d,divu[ 7: 0],rem3);
  
  assign divp = divu - (~divu);
  assign remf = rem3 < 0 ? rem3 + d : rem3;
  assign div  = rem3 < 0 ? divp - 1 : divp;
  assign rem  = remf[63:32];
endmodule

module idivider_step
  #(
    parameter START,
    parameter END
  )
  (
    input wire clk,
	 input wire signed [63:0] a,
	 input wire signed [63:0] b,
	 output wire signed [END-START:0] divp,
	 output wire signed [63:0] remp
  );
  
  integer i;
  
  reg signed [END-START:0] div;
  reg signed [63:0] rem;
  
  always @(posedge clk)
  begin
    rem = a;
    for (i = END-START; i >= 0; i = i - 1)
    begin
      if (rem >= 0)
	   begin
	     rem = (rem << 1) - b;
        div[i] = 1;
	   end
      else
	   begin
	     rem = (rem << 1) + b;
        div[i] = 0;
	   end
    end
  end
  
  assign divp = div;
  assign remp = rem;
endmodule
