defmodule DspEqTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  doctest DspEq

  test "eq coeffs runs" do
    check all freq <-     StreamData.integer(1..20000),
              q_factor <- StreamData.float(min: 0.1, max: 100.0),
              gain <-     StreamData.float(min: -12.0, max: 12.0) do
      [a: a, b: b] = DspEq.dsp_eq_coeffs(freq, q_factor, gain)
      assert(a < 1.0 and a > -1.0)
      assert(b < 1.0 and b > -1.0)
    end
  end
end
