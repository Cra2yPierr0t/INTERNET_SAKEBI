module sakebi_ethernet_frame_rx #(
  parameter DATA_WIDTH      = 8,
  parameter MAC_ADDR_WIDTH  = DATA_WIDTH*6,
  parameter ETHERTYPE_WIDTH = DATA_WIDTH*2
) (
  input  wire                       i_axis_ACLK,
  input  wire                       i_axis_ARESETn,
// AXI-Stream RX INTERFACE
  input  wire                       i_axis_TVALID,
  output reg                        o_axis_TREADY,
  input wire [DATA_WIDTH-1:0]       i_axis_TDATA,
// AXI-Stream TX INTERFACE
  output reg                        o_axis_TVALID,
  input wire                        i_axis_TREADY,
  output reg [DATA_WIDTH-1:0]       o_axis_TDATA,
// MAC ADDR
  output reg [MAC_ADDR_WIDTH-1:0]   o_src_mac_addr,
  output reg [MAC_ADDR_WIDTH-1:0]   o_dst_mac_addr,
// EtherType
  output reg [ETHERTYPE_WIDTH-1:0]  o_ethertype,
// Hardware Offload
  input wire                        i_specify_mac_en,
  input wire [MAC_ADDR_WIDTH-1:0]   i_mac_addr,
  input wire                        i_specify_ethertype_en,
  input wire [ETHERTYPE_WIDTH-1:0]  i_ethertype
);

  reg                   r_tvalid;
  reg [DATA_WIDTH-1:0]  r_tdata;

  reg [MAC_ADDR_WIDTH-1:0]  r_dst_mac_addr;
  reg [MAC_ADDR_WIDTH-1:0]  r_src_mac_addr;
  reg [ETHERTYPE_WIDTH-1:0] r_ethertype;

  localparam ETHER_IDLE         = 8'h00;
  localparam ETHER_MAC_DST      = 8'h01;
  localparam ETHER_MAC_SRC      = 8'h02;
  localparam ETHER_ETHERTYPE    = 8'h03;
  localparam ETHER_PAYLOAD      = 8'h04;

  reg [7:0] r_ether_state;
  reg [7:0] r_mac_cnt;
  reg [7:0] r_ethertype_cnt;

  always @(posedge i_axis_ACLK, negedge i_axis_ARESETn) begin
    if(!i_axis_ARESETn) begin
      r_tvalid  <= 1'b0;
      r_tdata   <= {DATA_WIDHT{1'b0}};
    end else begin
      r_tvalid  <= i_axis_TVALID;
      r_tdata   <= i_axis_TDATA;
    end
  end

  always @(posedge i_axis_ACLK, negedge i_axis_ARESETn) begin
    if(!i_axis_ARESETn) begin
      r_ether_state     <= ETHER_IDLE;
      r_mac_cnt         <= 8'h00;
      r_ethertype_cnt   <= 8'h00;
      r_dst_mac_addr    <= {MAC_ADDR_WIDTH{1'b0}};
      r_src_mac_addr    <= {MAC_ADDR_WIDTH{1'b0}};
    end else begin
      case(r_ether_state)
        ETHER_IDLE      : begin
          if(r_tvalid) begin
            r_ether_state   <= ETHER_MAC_DST;
            r_mac_cnt       <= r_mac_cnt + 8'h01;
            r_dst_mac_addr  <= {r_tdata, r_dst_mac_addr[MAC_ADDR_WIDTH-1:8]};
          end else begin
            r_ether_state   <= r_ether_state;
            r_mac_cnt       <= 8'h00;
            r_dst_mac_addr  <= {MAC_ADDR_WIDTH{1'b0}};
          end
        end
        ETHER_MAC_DST   : begin
          if(r_mac_cnt == 8'h04) begin
            r_mac_cnt       <= 8'h00;
            r_ether_state   <= ETHER_MAC_SRC;
          end else begin
            r_mac_cnt       <= r_mac_cnt + 8'h01;
            r_ether_state   <= r_ether_state;
          end
          r_dst_mac_addr    <= {r_tdata, r_dst_mac_addr[MAC_ADDR_WIDTH-1:8]};
        end
        ETHER_MAC_SRC   : begin
          if(r_mac_cnt == 8'h05) begin
            r_mac_cnt       <= 8'h00;
            r_ether_state   <= ETHER_ETHERTYPE;
          end else begin
            r_mac_cnt       <= r_mac_cnt + 8'h01;
            r_ether_state   <= r_ether_state;
          end
          r_src_mac_addr    <= {r_tdata, r_src_mac_addr[MAC_ADDR_WIDTH-1:8]};
        end
        ETHER_ETHERTYPE : begin
          if(r_ethertype_cnt == 8'h01) begin
            r_ethertype_cnt <= 8'h00;
            r_ether_state   <= ETHER_PAYLOAD;
          end else begin
            r_ethertype_cnt <= r_ethertype_cnt + 8'h01;
            r_ether_state   <= r_ether_state;
          end
          r_ethertype   <= {r_tdata, r_ethertype[ETHERTYPE_WIDTH-1:8]};
        end
        ETHER_PAYLOAD   : begin
          o_axis_TVALID     <= r_tvalid;
          o_src_mac_addr    <= r_src_mac_addr;
          o_dst_mac_addr    <= r_dst_mac_addr;
          o_ethertype       <= r_ethertype;
          o_axis_TDATA      <= r_tdata;
          if(r_tvalid == 1'b0) begin
            e_ether_status  <= ETHER_IDLE;
          end else begin
            r_ether_state   <= r_eter_status;
          end
        end
        default         : begin
        end
      endcase
    end
  end
endmodule
