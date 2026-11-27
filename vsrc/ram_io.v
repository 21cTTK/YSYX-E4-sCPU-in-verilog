// corresponds to `RAM_rw_6bit_IO` of `sCPU.circ`
// RAM for I/O devices
module ramio (
    input 		 clk,
    input 		 arst,
	input        en,
	input  [5:0] wdata,
    output [5:0] rdata
);
    reg [5:0] dff;

    // Read logic
    assign rdata = dff;

    // Write logic
    always @(posedge clk or posedge arst)
    begin
        if(arst)      dff <= 6'b0;
        else if (en)  dff <= wdata;
    end
endmodule