module mac_16bit_loa_tb;
  reg clk, rst, start;
  reg [15:0] a, b;
  wire [31:0] acc;
  wire done;

  mac_16bit_loa dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .a(a),
    .b(b),
    .done(done),
    .acc(acc)
  );

  always #5 clk = ~clk;

  integer i, j;
  reg [31:0] expected;
  integer total = 0, pass = 0, fail = 0;
  integer curr_error, max_error = 0;
  integer timeout;
  time start_time, end_time;

  initial begin
    $dumpfile("mac_16bit_loa_tb.vcd");
    $dumpvars(0, mac_16bit_loa_tb);
  end

  initial begin
    $display("======= TB: MAC_16BIT_LOA (Lower LOA Adder) =======");
    clk = 0; rst = 1; start = 0; a = 0; b = 0;
    #15 rst = 0;
    start_time = $time;

    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 16; j = j + 1) begin
        rst = 1; @(posedge clk);
        rst = 0; @(posedge clk);

        a = i; b = j;
        start = 1; @(posedge clk);
        start = 0;

        timeout = 0;
        while (!done && timeout < 1000) begin
          @(posedge clk);
          timeout = timeout + 1;
        end

        expected = i * j;
        total = total + 1;

        if (timeout >= 1000) begin
          $display("TIMEOUT: a=%0d, b=%0d", a, b);
          fail = fail + 1;
        end else begin
          curr_error = (acc > expected) ? acc - expected : expected - acc;
          if (curr_error > max_error) max_error = curr_error;

          if (curr_error > 12) begin
            $display("FAIL: a=%0d, b=%0d | acc=%0d, expected=%0d, error=%0d",
                     a, b, acc, expected, curr_error);
            fail = fail + 1;
          end else begin
            $display("PASS: a=%0d, b=%0d | acc=%0d ≈ expected=%0d (error=%0d)",
                     a, b, acc, expected, curr_error);
            pass = pass + 1;
          end
        end
        @(posedge clk);
      end
    end

    end_time = $time;
    $display("===================================================");
    $display("Passed        : %0d", pass);
    $display("Failed        : %0d", fail);
    $display("Total Cases   : %0d", total);
    $display("Efficiency    : %0.2f%%", (pass * 100.0) / total);
    $display("Max Error Seen: %0d", max_error);
    $display("Time Taken    : %0t ns", end_time - start_time);
    $display("===================================================");
    $finish;
  end
endmodule
