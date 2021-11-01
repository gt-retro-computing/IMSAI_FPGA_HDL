`default_nettype none

module wb_master(
    i_rst,
    i_clk,

    // S100 signals
    i_s_out, // sOUT
    i_s_inp, // sINP
    i_dbin,  // pDBIN
    i_wr_n,  // pWR*

    i_addr,
    i_do, // CPU -> Device
    o_di, // Device -> CPU

    o_rdy,
    o_xrdy,
    o_phantom_n,
    o_int_n,
    o_hold_n,

    // Wishbone Signals
    o_wb_cyc,
    o_wb_stb,

    o_wb_we,
    o_wb_addr,
    o_wb_data,

    i_wb_ack,
    i_wb_stall,
    i_wb_data,
);

parameter WIDTH = 8; 
parameter ADDR_LINES = 16;
localparam DEPTH = 1 << ADDR_LINES;

input wire i_rst;
input wire i_clk;

// S100 Signals
input wire i_s_out;
input wire i_s_inp;
input wire i_dbin;
input wire i_wr_n;

input wire[ADDR_LINES-1:0] i_addr;
input wire[WIDTH-1:0] i_do;
output reg[WIDTH-1:0] o_di;

output wire o_rdy;
output wire o_xrdy;
output reg o_phantom_n = 1, o_int_n = 1, o_hold_n = 1;

// Wishbone Signals
output reg o_wb_cyc;
output reg o_wb_stb;

output reg o_wb_we;
output reg [WIDTH-1:0] o_wb_data;
output reg [ADDR_LINES-1:0] o_wb_addr;

input wire i_wb_ack;
input wire i_wb_stall;
input wire [WIDTH-1:0] i_wb_data;

localparam STATE_IDLE = 0,
           STATE_REQUEST = 1,
           STATE_ACK = 2;

reg state = STATE_IDLE;

assign o_rdy = state == STATE_IDLE;
assign o_xrdy = state == STATE_IDLE;

always @(posedge i_clk) begin
  if (i_rst) begin
    o_wb_cyc <= 1'b0;
    o_wb_stb <= 1'b0;
    state = STATE_IDLE;
  end
end

always @(posedge i_clk) begin
  if (state == STATE_IDLE) begin
    if (!i_s_out && !i_s_inp) begin

      o_wb_addr <= i_addr;
      if (i_dbin) begin
        o_wb_we <= 1'b0;
      end else if (!i_wr_n) begin
        o_wb_we <= 1'b1;
        o_wb_data <= i_do;
      end

      if (i_dbin || !i_wr_n) begin
        o_wb_cyc <= 1'b1;
        o_wb_stb <= 1'b1;
        state <= STATE_REQUEST;
      end
    end
  end else if (state == STATE_REQUEST) begin
    if (!i_wb_stall) begin
      o_wb_stb <= 1'b0;
      state <= STATE_ACK;

      if (i_wb_ack) begin
        o_wb_cyc <= 1'b0;

        if (!o_wb_we) begin
          o_di <= o_wb_data;
        end
        state <= STATE_IDLE;
      end
    end
  end else if (state == STATE_ACK) begin
    if (i_wb_ack) begin
      o_wb_cyc <= 1'b0;

      if (!o_wb_we) begin
        o_di <= o_wb_data;
      end
      state <= STATE_IDLE;
    end
  end
end

endmodule