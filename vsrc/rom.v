// Corresponds to ROM_sCPU_pro_io_dpsw_IO of sCPU.circ.
// Stores the sISA program that reads the DIP switches and displays the sum.
module rom (
    input      [3:0] pc_in,
    output reg [7:0] rom_out
);
    parameter [7:0]
        I0 = 8'b11001000,  // io r0, 1, 0       (io: read DIP switches)
        I1 = 8'b00010000,  // li r1, 0, 0
        I2 = 8'b00100000,  // li r2, 0, 0
        I3 = 8'b00110001,  // li r3, 0, 1
        I4 = 8'b01010111,  // add r1, r1, r3
        I5 = 8'b01101001,  // add r2, r2, r1
        I6 = 8'b11010000,  // io r1, 0, 0       (io: write LEDs)
        I7 = 8'b10110101,  // bner0 -3, r1
        I8 = 8'b11001001,  // io r0, 1, 1       (io: read button)
        I9 = 8'b10111111,  // bner0 -1, r3
        IA = 8'b11100001,  // io r2, 0, 1       (io: write seven-segment display)
        IB = 8'b10000001;  // bner0 0, r1       (loop: End of program)

    always @(*) begin
        case (pc_in)
            4'b0000: rom_out = I0;
            4'b0001: rom_out = I1;
            4'b0010: rom_out = I2;
            4'b0011: rom_out = I3;
            4'b0100: rom_out = I4;
            4'b0101: rom_out = I5;
            4'b0110: rom_out = I6;
            4'b0111: rom_out = I7;
            4'b1000: rom_out = I8;
            4'b1001: rom_out = I9;
            4'b1010: rom_out = IA;
            4'b1011: rom_out = IB;
            default: rom_out = 8'bxxxxxxxx;  // as 'UUUUUUUU' in logisim
        endcase
    end
endmodule
