module s100_ram (
    i_clk,
    i_reset,

    i_wr_addr,
    i_wr_data,
    i_wr_enable,

    i_rd_addr,
    o_rd_data,
    o_rd_ready,
    i_rd_enable,

    o_busy
);
    
input wire i_clk, i_reset;

input wire [15:0] i_wr_addr;
input wire [7:0] i_wr_data;
input wire i_wr_enable;

input wire [15:0] i_rd_addr;
input wire i_rd_enable;
output reg [7:0] o_rd_data;
output reg o_rd_ready;

output reg o_busy = 0;


always @(posedge i_clk) begin
    
end


endmodule