defmodule DspCrossover do

  def c_coeff, do: %{:biquad => 1.0, :first_order => 0.0, :bypass => -1.0}
  @max_biquad 4
  @max_order 8
  def twopi, do: :math.pi() * 2

  # fc is the frequency which the crossovers will be set at
  @min_fc 0.01
  @max_fc 22000.0

  # fs is the sample rate of the audio
  @max_fs 192000.0
  @min_fs 48000.0
  @fs_sample_rate 48000.0

  # omega ω0 is the normalised angular frequency in radians
  def omega_ω0_max, do: twopi() * (@max_fc / @min_fs)
  def omega_ω0_min, do: twopi() * (@min_fc / @max_fs)

  def normalise_frequency(fc, fs) do
    omega_ω0 = twopi() * fc / fs
    cond do
      omega_ω0 > omega_ω0_max() -> omega_ω0_max()
      omega_ω0 < omega_ω0_min() -> omega_ω0_min()
      true -> omega_ω0
    end
  end

  def gain_coefficient_from_db(db) do
    :math.pow(10.0, db / 20.0)
  end

  def zeroth_order_shortcircuit(omega_ω0) do
    [ a: 0.0, b: :math.cos(omega_ω0), c: c_coeff().bypass ]
  end

  def first_order_shortcircuit(omega_ω0) do
    [
      a: (:math.cos(omega_ω0) + :math.sin(omega_ω0) - 1) / (:math.cos(omega_ω0) - :math.sin(omega_ω0) - 1),
      b: :math.cos(omega_ω0),
      c: 0.0
    ]
  end

  def normalise_order(order) do
    case order do
      x when x < 1 -> 1
      x when x > @max_order -> @max_order
      _ -> order
    end
  end

  def normalise_linkwitz_order(order) do
    case rem(order, 2) do
      x when x != 0 -> order + 1
      _ -> order
    end
    |> normalise_order()
  end

  def linkwitz_riley_damping(order, biquad) do
    case div(order, 2) do
      1 -> [2.0, 0.0, 0.0, 0.0]
      2 -> [1.4142135624, 1.4142135624, 0.0, 0.0]
      3 -> [2.0, 1.0, 1.0, 0.0]
      4 -> [1.847759065, 0.7653668647, 1.847759065, 0.7653668647]
    end
    |> Enum.at(biquad)
  end

  def bessel_damping(order, biquad) do
    case order do
      1 -> [1, 0, 0, 0]
      2 -> [1.7320508076, 0, 0, 0]
      3 -> [1.4470803599, 0, 0, 0]
      4 -> [1.9159489237, 1.2414059301, 0, 0]
      5 -> [1.7745107195, 1.0911344114, 0, 0]
      6 -> [1.9595631418, 1.6361402521, 0.9772172032, 0]
      7 -> [1.8784433114, 1.5132682086, 0.8878963849, 0]
      8 -> [1.9763194659, 1.7869614419, 1.4067624418, 0.8158806765]
    end
    |> Enum.at(biquad)
  end

  def descending_order_stream(order) do
    Stream.iterate({0, order}, fn {biquad, order} ->
      {
       biquad + 1,
       (if order - 2 > 0, do: order - 2, else: 0)
      }
    end)
    |> Stream.take(@max_biquad)
  end

  def linkwitz_biquad_calc(omega_ω0, biquad, order, working_order) do
    IO.inspect({omega_ω0, biquad, order, working_order})
    case working_order do
      0 -> zeroth_order_shortcircuit(omega_ω0)
      1 -> first_order_shortcircuit(omega_ω0)
      _ ->
        damping = linkwitz_riley_damping(order, biquad) |> IO.inspect()
        a = (2 - damping * :math.sin(omega_ω0)) / (2 + damping * :math.sin(omega_ω0))
        [
          a: (if omega_ω0 > :math.pi / 2, do: -a, else: a),
          b: :math.cos(omega_ω0),
          c: 1.0
        ]
    end
  end

  def dsp_crossover_coeffs(biquad_func, gain_db, frequency, order) do
    omega_ω0 = normalise_frequency(frequency, @fs_sample_rate)
    gain = gain_coefficient_from_db(gain_db)
    [
      k: gain,
      coeffs: (for {biquad, working_order} <- descending_order_stream(order), do: biquad_func.(omega_ω0, biquad, order, working_order))
    ] |> IO.inspect()
  end

  def linkwitz_dsp_crossover_coeffs(frequency, gain_db, order) do
    normalised_order = normalise_linkwitz_order(order)
    dsp_crossover_coeffs(&linkwitz_biquad_calc/4, gain_db, frequency, normalised_order)
  end

end
