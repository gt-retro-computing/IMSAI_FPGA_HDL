module wishbone_ram (
    i_rst,
    i_clk,

    i_wb_stb,

    i_wb_we,
    i_wb_addr,
    i_wb_data,

    o_wb_ack,
    o_wb_stall,
    o_wb_data,
);

parameter WIDTH = 8; 
parameter ADDR_LINES = 16;
localparam DEPTH = 1 << ADDR_LINES;

input wire i_rst;
input wire i_clk;

input wire i_wb_stb;

input wire i_wb_we;
input wire [WIDTH-1:0] i_wb_data;
input wire [ADDR_LINES-1:0] i_wb_addr;

output reg o_wb_ack;
output wire o_wb_stall;
output reg [WIDTH-1:0] o_wb_data;

reg [7:0] memory[0:DEPTH];

assign o_wb_stall = 1'b0;

always @(posedge i_clk) begin
    if (i_wb_stb && !o_wb_stall) begin
        if (i_wb_we)
            memory[i_wb_addr] <= i_wb_data;
        else
            o_wb_data <= memory[i_wb_addr];
    end

    if (i_rst)
        o_wb_ack <= 1'b0;
    else
        o_wb_ack <= i_wb_stb && !o_wb_stall;
end

endmodule