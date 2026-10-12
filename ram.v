module ram
  (
    input  wire clk,
	 input  wire pl_text,
	 input  wire pl_data,
	 input  wire paused,
	 input  wire load,
	 input  wire [31:0] text_address,
	 input  wire [31:0] data_address,
	 input  wire [31:0] data_display_address,
	 input  wire [31:0] write,
	 output wire [31:0] text,
	 output wire [31:0] data,
	 output wire [31:0] data_display,
	 output wire pl_text_out,
	 output wire [4:0] pl_data_out
  );
  
  wire [31:0] dataddr_tmp;
  wire [9:0]  dataddr_tmp2;
  wire [9:0]  dataddr_final;
  wire [31:0] texaddr_tmp;
  wire [9:0]  texaddr_final;
  
  reg pl_text_out_r;
  reg [4:0] pl_data_out_r;
  
  wire dataddr_in_range;
  wire texaddr_in_range;
  reg [31:0] text_mem[0:1023];
  reg [31:0] data_mem[0:1023];
  reg [31:0] data_tmp;
  reg [31:0] text_tmp;
  
  initial
  begin
    $readmemh("prog.mem", text_mem);
    $readmemh("data.mem", data_mem);
  end
  
  assign dataddr_tmp = data_address - 32'h1001_0000;
  assign dataddr_tmp2 = dataddr_tmp[11:2];
  assign dataddr_in_range = paused | ((dataddr_tmp < 4096) & (dataddr_tmp >= 0));
  assign dataddr_final = (paused & ~pl_data) ? data_display_address[7:0] : dataddr_tmp2; 
  
  assign texaddr_tmp = text_address - 32'h0040_0000;
  assign texaddr_final = texaddr_tmp[11:2];
  assign texaddr_in_range = (texaddr_tmp < 4096) & (texaddr_tmp >= 0);
  
  assign text = text_tmp;
  assign data = data_tmp;
  assign data_display = data_tmp;

  always @(posedge clk)
  begin
    if (texaddr_in_range & pl_text)
	   text_tmp <= text_mem[texaddr_final];

    if (pl_text)
	   pl_text_out_r <= 1;
	 else
	   pl_text_out_r <= 0;
	 
    data_tmp <= data_mem[dataddr_final];
    if (dataddr_in_range)
    begin
	   if (~load & ~paused & pl_data)
	   begin
	     data_mem[dataddr_final] <= write;
	   end
    end

    if (pl_data)
	   pl_data_out_r <= 4;
	 else if ((~paused | pl_data_out_r > 1) & pl_data_out_r > 0)
	   pl_data_out_r <= pl_data_out_r - 1;
	 
  end
	
  assign pl_text_out = pl_text_out_r;
  assign pl_data_out = pl_data_out_r;
endmodule
  