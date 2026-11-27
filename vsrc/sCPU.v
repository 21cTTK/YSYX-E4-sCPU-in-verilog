// corresponds to Single-cycle sCPU_pro from sCPU.circ
module sCPU (
    input clk, en, btn, arst,
    input [3:0] dpsw,
    output [5:0] led,
    output [7:0] seg0, seg1, seg_off
);
    wire [7:0] pc_out,  //PC reading
               instr;   //current instruction 
    wire [1:0] opcode = instr[7:6];

    // decides current operation
    wire
        is_li     = (opcode == 2'b00),
        is_add    = (opcode == 2'b01),
        is_branch = (opcode == 2'b10),
        is_io     = (opcode == 2'b11);
    
    // names for `io` instruction's fields
    wire io_read = instr[3];  //the bit that decide if it's r/w for io operation
    wire idx     = instr[0];      //I/O device address

    /* ROM */

    //ROM only sees low four bits of the eight-bit PC.
    rom program_rom (.pc_in(pc_out[3:0]), .rom_out(instr));

    /* Control Logic */// wiring up sCPU's core RAM's input/output pins

    // for read-select (R0S0,R0S1,R1S0,R1S1)
    //reg is specified in different bits in an instruction or being a constant:
    //for R0S0,R0S1: `io`:[5:4], `add`:[3:2], `bner0`:[1:0]
    wire [1:0] read0 = is_io ? instr[5:4] :
                       (is_add ? instr[3:2] : instr[1:0]);
    //for R1S0,R1S1: `io`:{1,0}, `add`:[1:0], `bner0`:{0,0} (no use)
    wire [1:0] read1 = is_io ? 2'b10 :
                       (is_add ? instr[1:0] : 2'b00);
    // for the output reading of core RAM (RD0,RD1)
    wire [5:0] rd0, rd1;

    // for 6-bit FA (that box right to the core RAM)
    //(offset_sext) `bner0`'s `offset` field of the instruction extended to fit the FA
    wire [5:0] offset = {{2{instr[5]}}, instr[5:2]};
    //(S) result of the 6-bit FA
    //two addends are the two MUX of FA's input
    wire [5:0] sum = (is_branch ? {1'b0, pc_out[4:0]} : rd0)
                     + (is_branch ? offset : rd1);
    
    /* PC */
    pc program_counter (
        .clk(clk), .arst(arst), .en(en),
        .wen(is_branch && rd0 != rd1),
        .wdata({3'b000, sum[4:0]}),
        .out(pc_out)
    );

    /* RAM for sCPU core */

    //shifted `imm` field of new `li` instruction
    wire [5:0] immediate = {4'b0000, instr[1:0]} << {instr[3:2], 1'b0};
    //input device's address (extended)
    wire [5:0] device_in = idx ? {5'b00000, btn} : {2'b00, dpsw};

    //our big ass core RAM
    ram program_register (
        .clk(clk), .arst(arst), .en(en && (is_li || is_add || (is_io && io_read))),
        .wen(is_io ? 2'b00 : instr[5:4]),
        .wdata(is_io ? device_in : is_add ? sum : immediate),
        .ren({read1, read0}), .rdata({rd1, rd0})
    );

    /* RAM for I/O Devices */

    //to be fed into I/O device's RAM's EN pin
    wire io_write = en && is_io && !io_read;
    //numeric value of input for 7seg
    wire [5:0] display_value;

    // two RAMs for I/O
    ramio led_register (
        .clk(clk), .arst(arst), .en(io_write && !idx), .wdata(rd0), .rdata(led)
    );
    ramio display_register (
        .clk(clk), .arst(arst), .en(io_write && idx), .wdata(rd1), .rdata(display_value)
    );

    /* Display */

    function [7:0] decimal_digit;
        input [5:0] digit;
        begin
            case (digit)
                0: decimal_digit = 8'b00000011;
                1: decimal_digit = 8'b10011111;
                2: decimal_digit = 8'b00100101;
                3: decimal_digit = 8'b00001101;
                4: decimal_digit = 8'b10011001;
                5: decimal_digit = 8'b01001001;
                6: decimal_digit = 8'b01000001;
                7: decimal_digit = 8'b00011111;
                8: decimal_digit = 8'b00000001;
                9: decimal_digit = 8'b00001001;
                default: decimal_digit = 8'b11111111;
            endcase
        end
    endfunction

    assign seg0 = decimal_digit(display_value % 6'd10);
    assign seg1 = decimal_digit(display_value / 6'd10);
    assign seg_off = 8'b11111111;
endmodule
