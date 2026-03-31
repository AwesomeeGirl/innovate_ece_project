module shift_reg #(parameter N = 4) (
    input logic [31:0] input_number,
    output logic [31:0] output_number,
    input logic clk,
    input logic rst_n
);
    reg [31:0] sr [N-1:0];

generate
    genvar i;
    for(i=0;i<N;i=i+1)
    begin
        always@(posedge clk or negedge rst_n)
        begin
        if(!rst_n)
        begin
            sr[i] <= 'd0;
        end
        else
            begin
                if(i == 'd0)
                begin
                    sr[i] <= input_number;
                end
                else
                begin
                    sr[i] <= sr[i-1];
                end
            end
        end
    end

    assign output_number = sr[N-1];

endgenerate


endmodule