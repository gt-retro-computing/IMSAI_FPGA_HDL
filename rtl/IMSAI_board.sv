`default_nettype	none

module IMSAI_board(
    i_clk,
    i_reset_n,
    i_key1,
    o_uart_tx,

    // S100 Signals
    o_do_en_n, // CPU -> DEVICE
    o_di_en_n, // DEVICE -> CPU
    o_addr_en_n,
    o_sts_en_n,

    // S100 Status
    o_phantom_n,
    o_hold_n,
    o_rdy,
    o_xrdy,
    o_int_n,
    i_memr,
);

input wire i_clk, i_reset_n;
input wire i_key1;
output wire o_uart_tx;

// S100
output reg o_do_en_n = 1, o_di_en_n = 1, o_addr_en_n = 1, o_sts_en_n = 0;
output reg o_phantom_n = 1, o_hold_n = 1, o_rdy = 1, o_xrdy = 1, o_int_n = 1;
input wire i_memr;

wire i_reset = !i_reset_n;

reg [8:0] divider = 0;
reg serial_clk = 0;
always @(posedge i_clk) begin
    divider <= divider + 1;
    if (divider == (434 / 2)) begin
        serial_clk <= 1;
    end
    if (divider == 434) begin
        divider <= 0;
        serial_clk <= 0;
    end
end

reg savedBtn = 0;
reg btn, btn_b;
always @(posedge i_clk)
    {btn, btn_b} <= {btn_b, !i_key1};

wire uart_ack;
wire uart_ack_clr;

// always @(posedge i_clk) begin
//     if (!btn && btn_b) begin
//         savedBtn <= 1;
//         uart_ack_clr <= 0;
//     end
//     if (uart_ack && savedBtn && !uart_ack_clr) begin
//         savedBtn <= 0;
//         uart_ack_clr <= 1;
//     end
//     if (uart_ack_clr && !uart_ack) begin
//         uart_ack_clr <= 0;
//     end
// end

wire [7:0] uart_data;
wire uart_wr;

uart_debug u0 (
	.source ({uart_ack_clr, uart_wr, uart_data}), // sources.source
	.probe  (uart_ack)   //  probes.probe
);

uart_tx mut(
    .i_uart_clk(serial_clk),
    .i_reset(i_reset),
    .i_data(uart_data),
    .i_data_w(uart_wr),
    .o_data_ack(uart_ack),
    .i_data_ack_clr(uart_ack_clr),
    .o_uart_tx(o_uart_tx)
);

// Testing
always @(posedge i_clk) begin
    if (i_memr)
        o_rdy <= 0;
    if (btn)
        o_rdy <= 1; 
end

endmodule