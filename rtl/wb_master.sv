`default_nettype none

module wb_master(
    i_rst,
    i_clk,

    // S100 signals
    i_memr,
    i_wo_n,
    i_addr,
    i_do, // CPU -> Device
    o_di, // Device -> CPU

    o_rdy,
    o_xrdy,
    o_phantom_n,
    o_int_n,
    o_hold_n,
    o_wr_n, // pWR*

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
input wire i_memr;
input wire i_wo_n;
input wire[ADDR_LINES-1:0] i_addr;

input wire[WIDTH-1:0] i_do;
output reg[WIDTH-1:0] o_di;

output wire o_rdy;
output wire o_xrdy;
output reg o_phantom_n = 1, o_int_n = 1, o_hold_n = 1;
output reg o_wr_n;

// Wishbone Signals
output reg o_wb_cyc;
output reg o_wb_stb;

output reg o_wb_we;
output reg [WIDTH-1:0] o_wb_data;
output reg [ADDR_LINES-1:0] o_wb_addr;

input wire i_wb_ack;
input wire i_wb_stall;
input wire [WIDTH-1:0] i_wb_data;

assign o_rdy = o_wb_cyc;
assign o_xrdy = o_wb_cyc;

always @(posedge i_clk) begin
  if (i_rst) begin
    o_wb_cyc <= 1'b0;
    o_wb_stb <= 1'b0;
  end else if (o_wb_stb) begin 
    // REQUEST Phase
    if (!i_wb_stall) begin
      o_wb_stb <= 1'b0;
      if (i_wb_ack)
        o_wb_cyc <= 1'b0;
    end
  end else if (o_wb_cyc) begin
    // WAIT Phase
    if (i_wb_ack)
      o_wb_cyc <= 1'b0;
  end else begin
    // IDLE Phase
    if (i_memr)
      o_wb_we <= 1'b0;
    else if (!i_wo_n)
      o_wb_we <= 1'b1;

    if (i_memr || !i_wo_n) begin
      o_wb_cyc <= 1'b1;
      o_wb_stb <= 1'b1;
    end
  end
end

always @(posedge i_clk) begin
  if (o_wb_stb && !i_wb_stall) begin
    o_wb_addr <= i_addr;
  end
end

always @(posedge i_clk) begin
  if (!o_wb_stb || !i_wb_stall) begin
    o_wb_data <= i_do;
  end
end

always @(posedge i_clk) begin
  if (!i_rst && o_wb_cyc && i_wb_ack) begin 
      o_di <= o_wb_data;
      o_wr_n <= 1'b0;
  end
end

endmodule