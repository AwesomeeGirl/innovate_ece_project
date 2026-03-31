module convolve #(parameter ACTIVATION_DIMENSIONS = 4) (
    input logic [31:0] input_value_from_processor,
    input logic clk,
    input logic rst_n,
    input logic start,
    output logic [31:0] result
);

    logic[31:0] weight[9];
    logic[31:0] outputs_a[3];
    logic[31:0] outputs_b[3];
    logic[31:0] outputs_c[3];
    logic[31:0] shift_temp[3];
    logic state;
    logic [3:0] counter;
    genvar i;
    genvar j;
    genvar a;
generate
    for (i = 0; i < 3; i++) begin
        mac mac_written_1 (
            .weight(weight[(i*3)]),
            .activation(input_value_from_processor),
            .previous(shift_temp[i]),
            .output_val(outputs_a[i]),
            .clk(clk),
            .rst_n(rst_n),
            .en(state)
        );
        mac mac_written_2 (
            .weight(weight[(i*3)+1]),
            .activation(input_value_from_processor),
            .previous(outputs_a[i]),
            .output_val(outputs_b[i]),
            .clk(clk),
            .rst_n(rst_n),
            .en(state)
        );
        mac mac_written_3 (
            .weight(weight[(i*3)+2]),
            .activation(input_value_from_processor),
            .previous(outputs_b[i]),
            .output_val(outputs_c[i]),
            .clk(clk),
            .rst_n(rst_n),
            .en(state)
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
            shift_temp[0] <= '0;
            if (start) begin
                counter <= '0;
                state <= '0;
                result <= '0;
            end else begin
                if (!state) begin
                    weight[counter] <= input_value_from_processor;
                    counter <= counter + 1;
                    result <= '0;
                    if (counter == 4'h8) begin
                        state <= 1;
                    end
                end else begin
                    result <= outputs_c[2];
                end
            end
        end
    end

endmodule