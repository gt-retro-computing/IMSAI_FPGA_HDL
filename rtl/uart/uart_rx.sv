`default_nettype none

module uart_rx (
    i_uart_clk_x16,
    i_reset,

    o_data,
    o_data_rdy,
    i_rdy_ack,
    o_rdy_ack_clr,

    i_uart_rx
);

input wire i_uart_clk_x16, i_reset;
input wire i_uart_rx;

output reg [7:0] o_data;
output reg o_data_rdy;
input wire i_rdy_ack;
output reg o_rdy_ack_clr;

localparam  STATE_PENDING = 0,
            STATE_IDLE = 1,
            STATE_START = 2,
            STATE_RX = 3,
            STATE_END = 4;

reg [3:0] state = STATE_PENDING;

reg [3:0] oversample_counter = 0;
reg [2:0] bit_counter = 0;
reg [7:0] rx_buffer;

/* Synchorize external input to the correct clock domain */
reg uart_rx, uart_rx_buf;
always @(posedge i_uart_clk_x16) begin
    {uart_rx, uart_rx_buf} <= {uart_rx_buf, i_uart_rx};
end

always @(posedge i_uart_clk_x16) begin
    if (i_rdy_ack) begin
        o_data_rdy <= 0;
        o_rdy_ack_clr <= 1;
    end
    if (o_rdy_ack_clr && !i_rdy_ack) begin
        o_rdy_ack_clr <= 0;
    end

    if (i_reset) begin
        o_data_rdy <= 0;
        o_rdy_ack_clr <= 0;
        oversample_counter <= 0;
        bit_counter <= 0;
        o_data <= 0;
        state <= STATE_PENDING;
    end

    if (state == STATE_PENDING) begin
        if (uart_rx)
            state <= STATE_IDLE; 
    end
    if (state == STATE_IDLE) begin
        if (~uart_rx) begin
            state <= STATE_START;
            oversample_counter <= 4;
        end
    end
    if (state == STATE_START) begin
        if (oversample_counter == 0) begin
            state <= STATE_RX;
            bit_counter <= 7;
        end
        oversample_counter <= oversample_counter - 1;
    end
    if (state == STATE_RX) begin
        oversample_counter <= oversample_counter - 1;
        if (oversample_counter == 0) begin
            rx_buffer <= {rx_buffer[6:0], uart_rx};
            bit_counter <= bit_counter - 1;
            if (bit_counter == 0) begin
                state <= STATE_END;
            end
        end
    end
    if (state == STATE_END) begin
        o_data <= rx_buffer;
        o_data_rdy <= 1;
        state <= STATE_PENDING;
    end
end

endmodule