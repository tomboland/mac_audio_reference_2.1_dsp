defmodule DspEqTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  doctest DspEq

  test "eq coeffs runs" do
    check all freq <-     StreamData.integer(1..20000),
              q_factor <- StreamData.float(min: 0.1, max: 100.0),
              gain <-     StreamData.float(min: -12.0, max: 12.0) do
      [a: a, b: b, g: g] = DspEq.dsp_eq_coeffs(freq, q_factor, gain)
      assert(a < 1.0 and a > -1.0)
      assert(b < 1.0 and b > -1.0)
    end
  end

  test "Test a couple of examples from original for equality" do
    coeffs = DspEq.dsp_eq_coeffs(250.0, 2.0, -6.0)
    IO.inspect(coeffs)
    assert(coeffs[:a] == 0.9775134129178111)
    assert(coeffs[:b] == 0.9994645874763657)
    assert(coeffs[:g] == 0.5011872336272722)
  end
end
