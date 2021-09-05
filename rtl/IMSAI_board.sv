`default_nettype	none

module IMSAI_board(
    i_clk,
    i_reset_n,
    i_key1,
    o_uart_tx
);

input wire i_clk, i_reset_n;
input wire i_key1;
output wire o_uart_tx;

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
reg uart_ack_clr = 0;

always @(posedge i_clk) begin
    if (!btn && btn_b) begin
        savedBtn <= 1;
        uart_ack_clr <= 0;
    end
    if (uart_ack && savedBtn && !uart_ack_clr) begin
        savedBtn <= 0;
        uart_ack_clr <= 1;
    end
    if (uart_ack_clr && !uart_ack) begin
        uart_ack_clr <= 0;
    end
end

uart_tx mut(
    .i_uart_clk(serial_clk),
    .i_reset(i_reset),
    .i_data(8'h5A),
    .i_data_w(savedBtn),
    .o_data_ack(uart_ack),
    .i_data_ack_clr(uart_ack_clr),
    .o_uart_tx(o_uart_tx)
);


endmodule