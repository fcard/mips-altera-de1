module keypress(input wire clk, input wire key, output wire pressed);

  reg tmp;
  reg pressed_tmp;

  initial
  begin
    tmp = 1;
	 pressed_tmp = 0;
  end
  
  always @(posedge clk)
  begin
    if (key)
	 begin
	   if (tmp)
  	     pressed_tmp = 0;
		else
		begin
  	     pressed_tmp = 1;
		  tmp = 1;
		end
	 end
	 else
	 begin
	   pressed_tmp = 0;
      tmp = 0;
	 end
  end
  assign pressed = pressed_tmp;
endmodule