// corresponds to `RAM_2r1w_IO` of `sCPU.circ`
// RAM for sCPU itself
module ram (
    input 			 clk,
    input 			 arst,
	input 			 en,
	input 	   [1:0] wen,
	input      [5:0] wdata,
    input      [1:0] ren   [0:1],
    output reg [5:0] rdata [0:1]
);
    reg [5:0] dff[0:3]; // r0-3

    always @(posedge clk or posedge arst)
    begin
        if(arst)
        begin
            rdata[0] <= 6'b0;
            rdata[1] <= 6'b0;
        end
        else
        begin   // Read logic
            for (integer i = 0; i < 2; i++)
            begin   // repeat for the two rdata outputs
                for (integer j = 0; j < 4; j++)
                begin   // repeat for possible read-enable values
                    if(ren[i] == j)  rdata[i] <= dff[j];
                    // May use `case` but i think `for` is cooler
                end
            end
        end

        // Write logic
        for (integer i = 0; i < 4; i++)
        begin
            if(wen == i)  dff[i] = wdata;
        end

    end
endmodule