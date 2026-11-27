module example(
  input a,
  input b,
  output f
);
  assign f = a ^ b;

  initial begin
    if ($test$plusargs("trace")) begin
      $dumpfile("waveform.fst");
      $dumpvars(0, example);
    end
  end
endmodule

