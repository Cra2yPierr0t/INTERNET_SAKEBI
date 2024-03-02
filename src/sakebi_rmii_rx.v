module sakebi_rmii_rx #(
  parameter DATA_WIDTH = 8
) (
// RMII RX INTERFACE
  input  wire                   i_rmii_REF_CLK,
  input  wire                   i_rmii_CRS_DV,
  input  wire [1:0]             i_rmii_RXD,
// AXI-Stream TX INTERFACE
  input  wire                   i_axis_ACLK,
  input  wire                   i_axis_ARESETn,
  output reg                    o_axis_TVALID,
  input  wire                   i_axis_TREADY,
  output reg  [DATA_WIDTH-1:0]  o_axis_TDATA
);

  localparam NIBBLE_WIDTH   = 4;

  reg                    r_crs_dv;
  reg [1:0]              r_rxd;
  reg [NIBBLE_WIDTH-1:0] r_nibble;
  reg [DATA_WIDTH-1:0]   r_byte_fifo;
  reg [DATA_WIDTH-1:0]   r_byte_cnt;
  reg [DATA_WIDTH-1:0]   r_byte;
  reg [3:0]              r_valid_check;

  always @(posedge rmii_REF_CLK) begin
    r_crs_dv    <= i_rmii_CRS_DV;
    r_rxd       <= i_rmii_RXD; 
    r_nibble    <= {r_nibble[1:0], i_rmii_RXD};
  end

  reg [3:0] r_rmii_state;
  localparam RMII_IDLE      = 4'h0;
  localparam RMII_PREAMBLE  = 4'b1;
  localparam RMII_SFD       = 4'h2;
  localparam RMII_DATA = 4'h3;
  localparam RMII_ERROR     = 4'hf;

  always @(posedge rmii_REF_CLK) begin
    case(r_rmii_state) 
      // wait for carrier
      RMII_IDLE     : begin
        if(r_crs_dv == 1'b1) begin
          r_rmii_state  <= RMII_PREAMBLE;
        end else begin
          r_rmii_state  <= r_rmii_state;
        end
      end
      // wait for preamble
      RMII_PREAMBLE : begin
        if(r_rxd == 2'b01) begin
          r_rmii_state  <= RMII_SFD;
        end else if(r_rxd == 2'b10) begin   // bad ssd
          r_rmii_state  <= RMII_ERROR;
        end else begin
          r_rmii_state  <= r_rmii_state;
        end
      end
      // wait for SFD
      RMII_SFD : begin
        if(r_rxd == 2'b11) begin    // sfd
          r_rmii_state  <= RMII_DATA;
          r_byte_cnt    <= 8'h0;
        end else if(r_rxd == 2'b01) begin
          r_rmii_state  <= r_rmii_state;
        end else begin
          r_rmii_state  <= RMII_ERROR;
        end
      end
      // accumlate data and send byte to next module
      // now r_rxd has valid data
      RMII_DATA : begin
        if(r_crs_dv == 1'b1) begin
          r_byte_fifo <= {r_byte_fifo[5:0], r_rxd};
          if(r_byte_cnt == 8'h04) begin
            r_byte_cnt    <= 8'h00;
            o_axis_tdata  <= r_byte_fifo;
            o_axis_tvalid <= 1'b1;
          end else begin
            r_byte_cnt    <= r_byte_cnt + 8'h01;
            o_axis_tdata  <= o_axis_tdata;
            o_axis_tvalid <= o_axis_tvalid;
          end
          r_rmii_state  <= RMII_IDLE;
        end else begin
          o_axis_tvalid <= 1'b0;
          r_rmii_state  <= r_rmii_state;
        end
      end
      // error
      RMII_ERROR    : begin
      end
      default       : begin
      end
    endcase
  end

  always @(posedge i_axis_ACLK) begin
  end

endmodule
