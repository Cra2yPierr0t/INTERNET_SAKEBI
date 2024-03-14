module sakebi_ethernet_frame_rx_tb;

  parameter DATA_WIDTH      = 8;
  parameter MAC_ADDR_WIDTH  = DATA_WIDTH*6;
  parameter ETHERTYPE_WIDTH = DATA_WIDTH*2;

  reg                         r_axis_ACLK    = 1'b1;
  reg                         r_axis_ARESETn = 1'b1;
// AXI-Stream RX INTERFACE
  reg                         r_axis_TVALID;
  wire                        w_axis_TREADY;
  reg  [DATA_WIDTH-1:0]       r_axis_TDATA;
// AXI-Stream TX INTERFACE
  wire                        w_axis_TVALID;
  reg                         r_axis_TREADY;
  wire [DATA_WIDTH-1:0]       w_axis_TDATA;
// MAC ADDR
  wire [MAC_ADDR_WIDTH-1:0]   w_src_mac_addr;
  wire [MAC_ADDR_WIDTH-1:0]   w_dst_mac_addr;
// EtherType
  wire [ETHERTYPE_WIDTH-1:0]  w_ethertype;
// Hardware Offload
  reg                         r_specify_mac_en;
  reg  [MAC_ADDR_WIDTH-1:0]   r_mac_addr;
  reg                         r_specify_ethertype_en;
  reg  [ETHERTYPE_WIDTH-1:0]  r_ethertype;

  always #1 begin
    r_axis_ACLK <= ~r_axis_ACLK;
  end

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, DUT);
  end

  sakebi_ethernet_frame_rx DUT(
    .i_axis_ACLK    (r_axis_ACLK    ),
    .i_axis_ARESETn (r_axis_ARESETn ),
// AXI-Stream RX INTERFACE
    .i_axis_TVALID  (r_axis_TVALID  ),
    .o_axis_TREADY  (w_axis_TREADY  ),
    .i_axis_TDATA   (r_axis_TDATA   ),
// AXI-Stream TX INTERFACE
    .o_axis_TVALID  (w_axis_TVALID  ),
    .i_axis_TREADY  (r_axis_TREADY  ),
    .o_axis_TDATA   (w_axis_TDATA   ),
// MAC ADDR
    .o_src_mac_addr (w_src_mac_addr ),
    .o_dst_mac_addr (w_dst_mac_addr ),
// EtherType
    .o_ethertype    (w_ethertype    ),
// Hardware Offload
    .i_specify_mac_en       (r_specify_mac_en       ),
    .i_mac_addr             (r_mac_addr             ),
    .i_specify_ethertype_en (r_specify_ethertype_en ),
    .i_ethertype            (r_ethertype            )
  );

  initial begin
    r_axis_TVALID   = 1'b0;
    r_axis_TDATA    = 8'h00;
    #10
    // DST MAC
    r_axis_TVALID   = 1'b1;
    r_axis_TDATA    = 8'hde;
    #2
    r_axis_TDATA    = 8'had;
    #2
    r_axis_TDATA    = 8'hbe;
    #2
    r_axis_TDATA    = 8'hef;
    #2
    r_axis_TDATA    = 8'hca;
    #2
    r_axis_TDATA    = 8'hfe;
    #2
    // SRC MAC
    r_axis_TDATA    = 8'h01;
    #2
    r_axis_TDATA    = 8'h02;
    #2
    r_axis_TDATA    = 8'h03;
    #2
    r_axis_TDATA    = 8'h04;
    #2
    r_axis_TDATA    = 8'h05;
    #2
    r_axis_TDATA    = 8'h06;
    #2
    // ETHER TYPE
    r_axis_TDATA    = 8'h00;
    #2
    r_axis_TDATA    = 8'h08;
    #2
    // PAYLOAD
    r_axis_TDATA    = 8'h55;
    #20
    $finish;
  end
  
endmodule
