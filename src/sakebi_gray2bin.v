module sakebi_gray2bin #(
  parameter WIDTH = 2
)(
  input  wire [WIDTH-1:0] i_gray,
  output wire [WIDTH-1:0] o_bin
);

  generate
    for(genvar i = WIDTH-1; 0 <= i; i=i-1) begin : GEN_GRAY2BIN
      if(i == WIDTH-1) begin
        assign o_bin[i] = i_gray[WIDTH-1];
      end else begin
        assign o_bin[i] = ^i_gray[WIDTH-1:i];
      end
    end
  endgenerate
endmodule
