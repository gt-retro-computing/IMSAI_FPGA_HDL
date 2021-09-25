module uart_tb;
    
  /* Make a reset that pulses once. */
  reg reset = 0;
  reg [7:0] data = 0;
  reg write = 0, clr = 0;
  wire ack, uart;
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, uart_tb);
    # 1 reset = 1;
    # 10 reset = 0;
    # 5 data = 8'h5A;
    # 0 write = 1;
    # 2 write = 0;
    # 30 clr = 1;
    # 2 clr = 0;   
    # 0 data = 8'hA5;
    # 2 write = 1;
    # 16 write = 0;



     # 100 $finish;
  end

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #1 clk = !clk;

uart_tx mut(
    .i_uart_clk(clk),
    .i_reset(reset),
    .i_data(data),
    .i_data_w(write),
    .o_data_ack(ack),
    .i_data_ack_clr(clr),
    .o_uart_tx(uart)
);

endmodule