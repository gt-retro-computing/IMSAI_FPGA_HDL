module uart_devicd (
    i_clk,
    i_clk_uart_src, // This is a 3.6864Mhz clock to drive the baudrate generator
    i_reset,

    i_uart_rx,
    o_uart_tx,

    // Simplified Wishbone B4 interface clocked with the i_clk
    i_wb_cyc,
    i_wb_stb,
    i_wb_we,

    i_wb_addr,
    i_wb_data,
    o_wb_data,

    o_wb_ack,
    o_wb_stall
);

/*
Registers in this device

Four I/O Addresses

Offset| Read Fn         | Write Fn  
    0 | Status Word     | Config Data
    1 | DeQueue Byte    | Queue Tx Byte
    2 | Baudrate LSByte | Baudrate LSByte
    3 | Baudrate MSByte | Baudrate MSByte
*/

input wire i_clk, i_clk_uart_src, i_reset;

input wire i_uart_rx;
output wire o_uart_tx;

input wire i_wb_cyc, i_wb_stb, i_wb_we;
input wire [1:0] i_wb_addr; // We only need 4 addresses
input wire [7:0] i_wb_data;
output reg [7:0] o_wb_data = 0;

output reg o_wb_ack = 0, o_wb_stall = 0;

reg [15:0] baudrate_divider = 0; // BAUD = ((i_clk_uart_src / 2) / (baudrate_divider + 1)) / 16

reg uart_clk = 0;
reg [15:0] baud_gen_cntr;
always @(posedge i_clk_uart_src) begin
    if (baud_gen_cntr == 0) begin
        uart_clk <= ~uart_clk;
        baud_gen_cntr <= baudrate_divider;
    end
    else
        baud_gen_cntr <= baud_gen_cntr - 1;
end

// Define Status Register Content
wire [7:0] status_word = {
    8'h0
};

// Wishbone IO FSM
localparam  WB_IDLE = 0,
            WB_WRITE = 1;
reg wb_state = 0;
wire wb_read = wb_state == WB_IDLE && i_wb_cyc && i_wb_stb && !i_wb_we;

always @(posedge i_clk) begin
    if (i_reset) begin
        wb_state <= WB_IDLE;
    end
    // if(wb_state == WB_IDLE && i_wb_cyc && i_wb_stb) begin
    //     if (i_wb_we) begin
    //         wb_state <= WB_WRITE;
    //         // Write to Queue
    //     end
    // end 
end

// wb_stall
always @(*) begin
    o_wb_stall = wb_state != WB_IDLE;
end

// Mux for wb_ack
always @(*) begin
    if (wb_read) 
        o_wb_ack = 1;
    else
        o_wb_ack = 0;
end

always @(*) begin
    if (wb_read)
        case(i_wb_addr)
            2'b10:      o_wb_data = baudrate_divider[ 7:0];
            2'b11:      o_wb_data = baudrate_divider[15:8];
            default:    o_wb_data = status_word;
        endcase
    else
        o_wb_data = 8'b0;
end

endmodule