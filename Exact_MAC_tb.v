module mac_with_adders_16bit_tb;
  parameter DATA_WIDTH = 16;
  localparam FULL_WIDTH = 2 * DATA_WIDTH;

  // Testbench signals
  reg clk, rst, start;
  reg [DATA_WIDTH-1:0] a, b;       // Inputs: multiplier & multiplicand
  wire [FULL_WIDTH-1:0] acc;       // Output from DUT
  wire done;                       // Completion flag from DUT

  // DUT instantiation
  mac_with_adders_16bit #(DATA_WIDTH) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .a(a),
    .b(b),
    .done(done),
    .acc(acc)
  );

  // Clock generation: 10 ns period (50 MHz)
  always #5 clk = ~clk;

  integer i, j;
  reg [FULL_WIDTH-1:0] expected;
  integer total = 0, pass = 0, fail = 0;
  time start_time, end_time;

  // Waveform dump
  initial begin
    $dumpfile("mac_with_adders_16bit_tb.vcd");
    $dumpvars(0, mac_with_adders_16bit_tb);
  end

  // Main test sequence
  initial begin
    $display("========== MAC_WITH_ADDERS_16BIT TESTBENCH ==========");

    // Initialize signals
    clk   = 0;
    rst   = 1;
    start = 0;
    a     = 0;
    b     = 0;

    #15 rst = 0;                     // Release reset
    start_time = $time;

    // Test 0..15 x 0..15
    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 16; j = j + 1) begin
        // Reset DUT before each test
        rst = 1; @(posedge clk);
        rst = 0; @(posedge clk);

        // Apply inputs and pulse start
        a = i;
        b = j;
        start = 1; @(posedge clk);
        start = 0;

        // Wait for done
        wait(done);

        expected = i * j;
        total = total + 1;

        if (acc !== expected) begin
          $display("FAIL: a=%0d, b=%0d | acc=%0d, expected=%0d", a, b, acc, expected);
          fail = fail + 1;
        end else begin
          $display("PASS: a=%0d, b=%0d | acc=%0d", a, b, acc);
          pass = pass + 1;
        end

        @(posedge clk); // Delay before next iteration
      end
    end

    end_time = $time;

    // Summary report
    $display("=========================================");
    $display("Passed       : %0d", pass);
    $display("Failed       : %0d", fail);
    $display("Total Cases  : %0d", total);
    $display("Efficiency   : %0.2f%%", (pass * 100.0) / total);
    $display("Time Taken   : %0t ns", end_time - start_time);
    $display("=========================================");

    $finish;
  end
endmodule
