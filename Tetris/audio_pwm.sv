//based off of the real digital pwm
//https://www.realdigital.org/doc/333049590c67cb553fc7f9880b2f79c3
module audio_pwm (
    input  logic        clk,    // 100MHz clock
    input  logic        rst,    // Reset
    input  logic        en,     // Enable
    input  logic [31:0] period, // Output period
    input  logic [31:0] width,  // Output pulse width
    output logic        pwm
);
    logic [31:0] counter;

    always_ff @(posedge clk)
    begin
        if (rst == 1'b1)
        begin
            counter <= 32'd0;
        end
        else if (en)
        begin
            if (counter[31:0] >= period[31:0])
                counter <= 32'd0;
            else
                counter <= counter + 1'b1;
        end
    end

    assign pwm = en && ~rst && (counter < width); //send a 1 when at correct width
endmodule