module ram
  (
    input  wire clk,
	 input  wire pl_text,
	 input  wire pl_data,
	 input  wire paused,
	 input  wire load,
	 input  wire [1:0]  load_type,
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

  wire [5:0] byte_addr;
  wire [5:0] half_addr;

  wire [1:0]  rb;
  wire [31:0] byte_unsigned;
  wire [31:0] half_unsigned;
  wire [31:0] byte_signed;
  
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
  
  assign rb = dataddr_tmp[1:0];
  assign byte_unsigned = rb[1] ? (rb[0] ? data_tmp[31:24] : data_tmp[23:16])
                               : (rb[0] ? data_tmp[15:8]  : data_tmp[7:0]);
  assign half_unsigned = rb[1] ? (rb[0] ? data_tmp[31:24] : data_tmp[31:16])
                               : (rb[0] ? data_tmp[23:8]  : data_tmp[15:0]);
  assign byte_signed = {{24{byte_unsigned[7]}}, byte_unsigned[7:0]};
  
  assign text = text_tmp;
  assign data = load_type[1] ? (load_type[0] ? half_unsigned : byte_unsigned )
                             : (load_type[0] ? data_tmp : byte_signed );
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
		  case (load_type)
	       2'b00:
			  case (rb)
			    2'b00: data_mem[dataddr_final] = {data_tmp[31:8], write[7:0]};
			    2'b01: data_mem[dataddr_final] = {data_tmp[31:16], write[7:0], data_tmp[7:0]};
			    2'b10: data_mem[dataddr_final] = {data_tmp[31:24], write[7:0], data_tmp[15:0]};
			    2'b11: data_mem[dataddr_final] = {write[7:0], data_tmp[23:0]};
			  endcase
	       2'b01: data_mem[dataddr_final] = write;
	       2'b11:
			  case (rb)
			    2'b00: data_mem[dataddr_final] = {data_tmp[31:16], write[15:0]};
			    2'b01: data_mem[dataddr_final] = {data_tmp[31:24], write[15:0], data_tmp[7:0]};
			    2'b10: data_mem[dataddr_final] = {write[15:0], data_tmp[15:0]};
			    2'b11: data_mem[dataddr_final] = {write[7:0], data_tmp[23:0]};
			  endcase
		  endcase
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
  