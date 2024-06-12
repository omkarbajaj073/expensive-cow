module sqrt_tb();

    parameter CLK_PERIOD = 10;
    parameter WIDTH = 16;
    parameter FBITS = 8;
    real SF;

    reg clk;
    reg start;             // start signal
    wire busy;             // calculation in progress
    wire valid;            // root and rem are valid
    reg [WIDTH-1:0] rad;   // radicand
    wire [WIDTH-1:0] root; // root
    wire [WIDTH-1:0] rem;  // remainder

    // Intermediate nets for monitoring
    real rad_sf;
    real root_sf;

    sqrt #(WIDTH, FBITS) sqrt_inst (
        .clk(clk),
        .start(start),
        .busy(busy),
        .valid(valid),
        .rad(rad),
        .root(root),
        .rem(rem)
    );

    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        SF = 2.0**-8.0;  // Q8.8 scaling factor is 2^-8
    end

    always @(*) begin
        rad_sf = rad * SF;
        root_sf = root * SF;
    end

    initial begin
        $monitor("\t%d:\tsqrt(%f) = %b (%f) (rem = %b) (V=%b)",
                    $time, rad_sf, root, root_sf, rem, valid);
    end

    initial begin
        clk = 1;

        #100    rad = 16'b1110_1000_1001_0000;  // 232.56250000
                start = 1;
        #10     start = 0;

        #120    rad = 16'b0000_0000_0100_0000;  // 0.25
                start = 1;
        #10     start = 0;

        #120    rad = 16'b0000_0010_0000_0000;  // 2.0
                start = 1;
        #10     start = 0;
        #120    $finish;
    end
endmodule
