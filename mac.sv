module mac(
    input logic [31:0] weight,
    input logic [31:0] activation,
    input logic [31:0] previous,
    output logic [31:0] output_val,
    input logic clk,
    input logic rst_n,
    input logic en
);

    always_ff @( posedge clk, negedge rst_n ) begin
        if (!rst_n) begin
            output_val <= '0;
        end else begin
            if (en) begin
                output_val <= (weight * activation) + previous;
            end else begin
                output_val <= 0;
            end
        end
    end

endmodule