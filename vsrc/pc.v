// corresponds to `PC_8bit_setNum_IO` of `sCPU.circ`
module pc (
    input 			 clk,
    input 			 arst,
	input 			 en,
	input 			 wen,
	input      [7:0] wdata,
    output reg [7:0] out
);
	always @(posedge clk or posedge arst)
	begin
		if (arst) 	  out <= 8'b0;
		else if (en)  out <= wen ? wdata : out + 8'd1;
	end
endmodule

