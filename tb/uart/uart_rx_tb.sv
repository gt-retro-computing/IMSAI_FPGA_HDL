module uart_rx_tb;
    
  /* Make a reset that pulses once. */
  reg reset = 1;
  wire [7:0] data;
  wire data_rdy;
  reg ack = 0;
  wire ack_clr;
  reg uart = 1;
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, uart_rx_tb);
    #4 reset = 0;
    #5 uart = 0;
    #32 uart = 1;
    #32 uart = 0;
    #32 uart = 1;
    #32 uart = 0;
    #32 uart = 1;
    #32 uart = 0;
    #32 uart = 1;
    #32 uart = 0;
    #32 uart = 1;

    #50 $finish;
  end

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #1 clk = !clk;

uart_rx rx0 (
    .i_uart_clk_x16(clk),
    .i_reset(reset),

    .o_data(data),
    .o_data_rdy(data_rdy),
    .i_rdy_ack(ack),
    .o_rdy_ack_clr(ack_clr),

    .i_uart_rx(uart)
);

endmodule