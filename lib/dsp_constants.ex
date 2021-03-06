defmodule DspConstants do

  def eleven_band_channels(), do: [:rl, :rr, :sl, :sr]
  def third_octave_band_channels(), do: [:fl, :fr]

  def eleven_band_peq_enums() do
    %{
      1 => 32,
      2 => 64,
      3 => 125,
      4 => 250,
      5 => 500,
      6 => 800,
      7 => 1200,
      8 => 3100,
      9 => 6000,
      10 => 10000,
      11 => 16000
    }
  end

  def third_octave_band_peq_enums() do
    %{
      1 => 20.0,
      2 => 25.0,
      3 => 31.5,
      4 => 40.0,
      5 => 50.0,
      6 => 63.0,
      7 => 80.0,
      8 => 100.0,
      9 => 125.0,
      10 => 160.0,
      11 => 200.0,
      12 => 250.0,
      13 => 315.0,
      14 => 400.0,
      15 => 500.0,
      16 => 630.0,
      17 => 800.0,
      18 => 1000.0,
      19 => 1250.0,
      20 => 1600.0,
      21 => 2000.0,
      22 => 2500.0,
      23 => 3150.0,
      24 => 4000.0,
      25 => 5000.0,
      26 => 6300.0,
      27 => 8000.0,
      28 => 10000.0,
      29 => 12500.0,
      30 => 16000.0,
      31 => 20000.0
    }
  end
end
