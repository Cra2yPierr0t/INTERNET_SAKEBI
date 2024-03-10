module sakebi_ethernet_frame_rx #(
  parameter DATA_WIDTH = 8
) (
  input  wire                   i_axis_ACLK,
  input  wire                   i_axis_ARESETn,
// AXI-Stream RX INTERFACE
  input  wire                   i_axis_TVALID,
  output reg                    o_axis_TREADY,
  input wire [DATA_WIDTH-1:0]   i_axis_TDATA,
// AXI-Stream TX INTERFACE
  output reg                    o_axis_TVALID,
  input wire                    i_axis_TREADY,
  output reg [DATA_WIDTH-1:0]   o_axis_TDATA,
// MAC ADDR
  input wire [DATA_WIDTH*6-1:0] i_mac_addr,
  output reg [DATA_WIDTH*6-1:0] o_src_mac_addr,
  output reg [DATA_WIDTH*6-1:0] o_dst_mac_addr,
// EtherType
  output reg [DATA_WIDTH*2-1:0] o_ethertype,
// Hardware Offload
  input wire                    i_specify_mac
);

  always @(posedge i_axis_ACLK, negedge i_axis_ARESETn) begin
    if(!i_axis_ARESETn) begin
    end else begin
    end
  end
endmodule
