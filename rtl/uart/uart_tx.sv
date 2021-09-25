module uart_tx (
    i_uart_clk,
    i_reset,
    i_data,
    i_data_w,
    o_data_ack,
    i_data_ack_clr,
    
    o_uart_tx
);
    
input wire i_uart_clk, i_reset;
input wire [7:0] i_data;
input wire i_data_w;

output reg o_data_ack;
initial o_data_ack = 0;

input wire i_data_ack_clr;

output reg o_uart_tx;

localparam  STATE_IDLE = 0,
            STATE_START = 1,
            STATE_TX = 2,
            STATE_STOP = 3, // TODO The stop state might not be nessrary. You might be able to just shift it to the IDLE state directlry
            STATE_END = 4;  
reg [2:0] state;
initial state = STATE_IDLE;

reg [2:0] tx_bit_cnt;

reg [7:0] tx_data;

always @(posedge i_uart_clk) begin
    if (i_reset) begin
        // Do reset
        state <= STATE_IDLE;
        o_data_ack <= 0;
    end
    if (i_data_w && (state == STATE_IDLE)) begin
        // Save the request data
        tx_data <= i_data;
        // State Transition
        state <= STATE_START;
        o_data_ack <= 1;
    end

    if (o_data_ack && i_data_ack_clr && !i_data_w) begin
        o_data_ack <= 0;
    end

    if (state == STATE_START) begin
        state <= STATE_TX;
        tx_bit_cnt <= 0;
    end

    if (state == STATE_TX) begin
        if (tx_bit_cnt == 7)
            state <= STATE_STOP;
        else
            tx_bit_cnt <= tx_bit_cnt + 1;
    end

    if (state == STATE_STOP) begin
        if (o_data_ack)
            state <= STATE_END;
        else
            state <= STATE_IDLE;
    end

    if (state == STATE_END && !o_data_ack)
        state <= STATE_IDLE;
end

always @* begin
    case(state)
        STATE_START:    o_uart_tx = 0;
        STATE_TX:       o_uart_tx = tx_data[tx_bit_cnt];
        default:        o_uart_tx = 1;
    endcase
end

endmodule