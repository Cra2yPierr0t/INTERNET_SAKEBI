module sakebi_bin2gray #(
  parameter WIDTH = 2
)(
  input  wire [WIDTH-1:0] i_bin,
  output wire [WIDTH-1:0] o_gray
);

  generate
    for(genvar i = 0; i < WIDTH; i=i+1) begin : GEN_BIN2GRAY
      if(i == WIDTH-1) begin
        assign o_gray[i] = i_bin[i];
      end else begin
        assign o_gray[i] = i_bin[i] ^ i_bin[i+1];
      end
    end
  endgenerate
endmodule
