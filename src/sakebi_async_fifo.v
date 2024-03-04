module sakebi_async_fifo #(
  parameter DATA_WIDTH  = 8,
  parameter DEPTH       = 4
)(
  // WRITE INTERFACE
  input wire                    i_wr_clk,
  input wire                    i_wr_rstn,
  output reg                    o_wr_ready,
  input wire                    i_wr_en,
  input wire [DATA_WIDTH-1:0]   i_wr_data,
  // READ INTERFACE
  input wire                    i_rd_clk,
  input wire                    i_rd_rstn,
  output reg                    o_rd_ready,
  input wire                    i_rd_en,
  output reg [DATA_WIDTH-1:0]   o_rd_data
);

  localparam ADDR_WIDTH = $clog2(DEPTH);

  wire w_full;
  wire w_empty;
  reg [DATA_WIDTH-1:0] r_ram[DEPTH-1:0];

  // WRITE
  
  reg  [ADDR_WIDTH-1:0] r_wr_addr;
  wire [ADDR_WIDTH-1:0] w_wr_gray;
  reg  [ADDR_WIDTH-1:0] r_rd_gray[2];
  wire [ADDR_WIDTH-1:0] w_rd_addr;

  always @(posedge i_wr_clk, negedge i_wr_rstn) begin
    if(!i_wr_rstn) begin
      r_wr_addr <= 0;
    end else begin
      if(i_wr_en && !w_full) begin
        r_wr_addr           <= r_wr_addr + 1;
        r_ram[r_wr_addr]    <= i_wr_data;
      end else begin
        r_wr_addr           <= r_wr_addr;
      end
    end
  end

  sakebi_bin2gray #(
    .WIDTH  (ADDR_WIDTH )
  ) wr_bin2gray (
    .i_bin  (r_wr_addr  ),
    .o_gray (w_wr_gray  )
  );

  always @(posedge i_wr_clk, negedge i_wr_rstn) begin
    if(!i_wr_rstn) begin
      r_rd_gray[0]  <= 0;
      r_rd_gray[1]  <= 0;
    end else begin
      r_rd_gray[0]  <= w_rd_gray;
      r_rd_gray[1]  <= r_rd_gray[0];
    end
  end

  sakebi_gray2bin #(
    .WIDTH  (ADDR_WIDTH )
  ) rd_gray2bin(
    .i_gray (r_rd_gray[1]),
    .o_bin  (w_rd_addr   )
  );

  assign w_full     = (r_wr_addr - w_rd_addr) == {ADDR_WIDTH{1'b1}};
  assign o_wr_ready = ~w_full;
  
  // READ

  reg  [ADDR_WIDTH-1:0] r_rd_addr;
  wire [ADDR_WIDTH-1:0] w_rd_gray;
  reg  [ADDR_WIDTH-1:0] r_wr_gray[2];
  wire [ADDR_WIDTH-1:0] w_wr_addr;

  always @(posedge i_rd_clk, negedge i_rd_rstn) begin
    if(!i_rd_rstn) begin
      r_rd_addr <= 0;
    end else begin
      if(i_rd_en && !w_empty) begin
        r_rd_addr   <= r_rd_addr + 1;
        o_rd_data   <= r_ram[r_rd_addr];
      end else begin
        r_rd_addr   <= r_rd_addr;
      end
    end
  end

  sakebi_bin2gray #(
    .WIDTH  (ADDR_WIDTH )
  ) rd_bin2gray(
    .i_bin  (r_rd_addr  ),
    .o_gray (w_rd_gray  )
  );

  always @(posedge i_rd_clk, negedge i_rd_rstn) begin
    if(!i_rd_rstn) begin
      r_wr_gray[0]  <= 0;
      r_wr_gray[1]  <= 0;
    end else begin
      r_wr_gray[0]  <= w_wr_gray;
      r_wr_gray[1]  <= r_wr_gray[0];
    end
  end

  sakebi_gray2bin #(
    .WIDTH  (ADDR_WIDTH )
  ) wr_gray2bin(
    .i_gray (r_wr_gray[1]),
    .o_bin  (w_wr_addr   )
  );

  assign w_empty    = w_wr_addr == r_rd_addr;
  assign o_rd_ready = ~w_empty;

endmodule
