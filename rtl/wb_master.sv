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

// wb_master state
localparam STATE_IDLE = 0,
           STATE_REQUEST = 1,
           STATE_ACK = 2;

reg state = STATE_IDLE;

// Signal to s100 master whether or not the wishbone master/slave
// is still processing a request. Only ready if wb master is in IDLE state
assign o_rdy = state == STATE_IDLE;
assign o_xrdy = state == STATE_IDLE;

// stb is only active while wishbone is processing a request
assign o_wb_stb = state == STATE_REQUEST;

// cyc is held high while request cycle is happening, aka state is not IDLE
assign o_wb_cyc = state != STATE_IDLE;

always @(posedge i_clk) begin
  if (i_rst) begin
    state = STATE_IDLE;
  end
end

always @(posedge i_clk) begin
  if (state == STATE_IDLE) begin

    // Initiate request if master is not executing output cycle
    // and not executing input cycle
    if (!i_s_out && !i_s_inp) begin

      if (i_dbin) begin
        // Read request
        o_wb_we <= 1'b0;
        
        o_wb_addr <= i_addr;
      end else if (!i_wr_n) begin
        // Write request
        o_wb_we <= 1'b1;

        o_wb_data <= i_do;
        o_wb_addr <= i_addr;
      end

      if (i_dbin || !i_wr_n) begin
        // If write or read request, transition to REQUEST state
        state <= STATE_REQUEST;
      end
    end
  end else if (state == STATE_REQUEST) begin
    if (!i_wb_stall) begin
      state <= STATE_ACK;

      // Handle case where slave device acks in the same cycle of ending stall
      if (i_wb_ack) begin
        // If request was a write, update data input on the s100 bus
        if (!o_wb_we) begin
          o_di <= o_wb_data;
        end

        state <= STATE_IDLE;
      end
    end
  end else if (state == STATE_ACK) begin
    // Wait until wishbone slave acks
    if (i_wb_ack) begin
      // If request was a write, update data input on the s100 bus
      if (!o_wb_we) begin
        o_di <= o_wb_data;
      end

      state <= STATE_IDLE;
    end
  end
end

endmodule