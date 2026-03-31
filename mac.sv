module mac(
    input logic [31:0] weight,
    input logic [31:0] activation,
    input logic [31:0] previous,
    output logic [31:0] output_val,
    input logic clk,
    input logic rst_n
);

    always_ff @( posedge clk, negedge rst_n ) begin
        if (!rst_n) begin
            output_val <= '0;
        end else begin
            output_val <= (weight * activation) + previous;
        end
    end

endmodule