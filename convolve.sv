module convolve #(parameter ACTIVATION_DIMENSIONS = 4) (
    input logic [31:0] weight_in [9],
    input logic [31:0] activation,
    input logic clk,
    input logic rst_n,
    input logic start,
    output logic [31:0] result,
    output logic finished
);

    logic[31:0] weight[9];
    logic[31:0] outputs_a[3];
    logic[31:0] outputs_b[3];
    logic[31:0] outputs_c[3];
    logic[31:0] shift_temp[3];

    logic [ACTIVATION_DIMENSIONS-1:0] counter;
    genvar i;
    genvar j;
    genvar a;
generate
    for (i = 0; i < 3; i++) begin
        mac mac_written_1 (
            .weight(weight[(i*3)]),
            .activation(activation),
            .previous(shift_temp[i]),
            .output_val(outputs_a[i]),
            .clk(clk),
            .rst_n(rst_n)
        );
        mac mac_written_2 (
            .weight(weight[(i*3)+1]),
            .activation(activation),
            .previous(outputs_a[i]),
            .output_val(outputs_b[i]),
            .clk(clk),
            .rst_n(rst_n)
        );
        mac mac_written_3 (
            .weight(weight[(i*3)+2]),
            .activation(activation),
            .previous(outputs_b[i]),
            .output_val(outputs_c[i]),
            .clk(clk),
            .rst_n(rst_n)
        );
    end

    for (j = 0; j < 2; j++) begin
        shift_reg #(.N(ACTIVATION_DIMENSIONS-3)) shifter (
            .input_number(outputs_c[j]),
            .output_number(shift_temp[j+1]),
            .clk(clk),
            .rst_n(rst_n)
        );
    end
endgenerate

    always_ff @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            weight <= '{default:0};
            result <= '0;
            shift_temp[0] <= '0;
            counter <= '0;
        end else begin
            if (start) begin
                weight <= weight_in;
                counter <= '0;
                finished <= '0;
            end
            result <= outputs_c[2];
            counter <= counter + 1;
            if (counter == ACTIVATION_DIMENSIONS*ACTIVATION_DIMENSIONS) begin
                finished <= 1;
            end
        end
    end

endmodule