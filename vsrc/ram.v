// corresponds to `RAM_2r1w_IO` of `sCPU.circ`
// RAM for sCPU itself
module ram (
    input 			  clk,
    input 			  arst,
	input 			  en,
	input 	   [1:0]  wen,
	input      [5:0]  wdata,
    input      [3:0]  ren,       // seg is ren[3:2,1:0]
    output reg [11:0] rdata     // seg is rdata[11:6,5:0]
);
    reg [5:0] dff[0:3]; // r0-3

    integer i, j;
    always @(*)
    begin   // Read logic
        for (i = 0; i < 2; i++)
        begin   // repeat for the two rdata outputs
            for (j = 0; j < 4; j++)
            begin   // repeat for possible read addresses
                if(ren[2*i +: 2] == j[1:0])  rdata[6*i +: 6] = dff[j];
                // May use `case` but i think `for` is cooler
            end
        end
    end

    // Write logic
    always @(posedge clk or posedge arst)
    begin
        if(arst)
        begin
            for (i = 0; i < 4; i++)
            begin
                dff[i] <= 6'b0;
            end
        end
        else if(en)
        begin
            case (wen)
                2'b00, 2'b01: dff[wen] <= {2'b00, wdata[3:0]};      // r0,r1: 4bit
                2'b10:        dff[wen] <= wdata;                    // r2:    6bit
                2'b11:        dff[wen] <= {4'b0000, wdata[1:0]};    // r3:    2bit
            endcase
        end
    end
endmodule
