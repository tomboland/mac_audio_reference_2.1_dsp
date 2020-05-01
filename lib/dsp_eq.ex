defmodule DspEq do
  @moduledoc """
  Documentation for `DspEq`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> DspEq.dsp_eq_coeffs(1000, 1, 2.0)
      [a: 0.9115945267860508, b: 0.9914448613738104, g: 1.2589254117941673]

      iex> DspEq.dsp_eq_coeffs(250, 2.0, -6.0)
      [a: 0.9775134129178111, b: 0.9994645874763657, g: 0.5011872336272722]

  """

  @type eq_freq :: float
  @type eq_q_factor :: float
  @type eq_gain :: float
  @type eq_a_coeff :: float
  @type eq_b_coeff :: float
  @type eq_coeffs :: [
    a: eq_a_coeff,
    b: eq_b_coeff
  ]

  @spec sample_rate :: 48000
  def sample_rate, do: 48000

  def gain_coefficient_from_db(db) do
    :math.pow(10.0, db / 20.0)
  end

  @spec dsp_eq_coeffs(eq_freq, eq_q_factor, eq_gain) :: eq_coeffs
  @doc """
  Generate the a, b, and g coefficients for the digital peaking EQ filter
  I can't quite marry this up with this: https://www.w3.org/2011/audio/audio-eq-cookbook.html
  ω0 is the normalised angular frequency in radians
  a coefficient is the main work here.  Answers on a postcard
  b coefficient is the cosine of ω0
  g coefficient is fundamentally the gain
  """
  def dsp_eq_coeffs(freq, q_factor, gain_db) do
    IO.inspect({freq, q_factor, gain_db})
    ω0 = 2.0 * :math.pi * freq / sample_rate()
    gain = gain_coefficient_from_db(gain_db)
    sin_ω0 = :math.sin(ω0)
    cos_ω0 = :math.cos(ω0)
    q = :math.pow(2.0, (1 / q_factor) / 2.0)
    q2 = q / (q * q - 1.0)
    ω1 = ω0 * (:math.sqrt(4.0 * q2 * q2 + 1.0) - 1.0) / (q2 + q2)
    q3 = :math.sin(ω1) * sin_ω0 / (2.0 * (:math.cos(ω1) - cos_ω0))
    final_q = cond do
      gain_db < 0.0 -> q3 * gain
      true -> q3
    end
    [
      a: (2.0 * final_q - sin_ω0) / (2.0 * final_q + sin_ω0),
      b: cos_ω0,
      g: gain
    ]
  end
end
