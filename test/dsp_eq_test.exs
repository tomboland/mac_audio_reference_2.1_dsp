defmodule DspEqTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  doctest DspEq

  test "eq gain is greater than 0" do
    check all gain <- StreamData.float(min: -12, max: 12) do
      assert DspEq.dsp_eq_gain(gain) > 0
    end
  end

  test "gain of 0 return 1.0" do
    assert DspEq.dsp_eq_gain(0.0) == 1.0
  end

  test "eq coeffs runs" do
    check all freq <-     StreamData.integer(1..20000),
              q_factor <- StreamData.float(max: 100.0),
              gain <-     StreamData.float() do
      [a_coeff: a, b_coeff: b] = DspEq.dsp_eq_coeffs(freq, q_factor, gain)
      assert(a < 1.0 and a > -1.0)
      assert(b < 1.0 and b > -1.0)
    end
  end
end
