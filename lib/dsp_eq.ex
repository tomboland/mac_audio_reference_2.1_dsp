defmodule DspEq do
  @moduledoc """
  Documentation for `DspEq`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> DspEq.dsp_eq_coeffs(1000, 1, -1.0)
      [a: 0.9013395575820645, b: 0.9914448613738104]

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

  @spec dsp_eq_coeffs(eq_freq, eq_q_factor, eq_gain) :: eq_coeffs
  @doc """
  Generate the a and b coefficients for the digital peaking EQ filter
  """
  def dsp_eq_coeffs(freq, q_factor, gain) do
    ω0 = 2.0 * :math.pi * freq / sample_rate()
    sin_ω0 = :math.sin(ω0)
    cos_ω0 = :math.cos(ω0)
    q = :math.pow(2.0, (1 / q_factor) / 2.0)
    q2 = q / (q * q - 1.0)
    ω1 = ω0 * (:math.sqrt(4.0 * q2 * q2 + 1.0) - 1.0) / (q2 + q2)
    q3 = :math.sin(ω1) * sin_ω0 / (2.0 * (:math.cos(ω1) - cos_ω0))
    final_q = cond do
      gain < 0.0 -> q3 * :math.pow(10.0, gain / 20.0)
      true -> q3
    end
    [
      a: (2.0 * final_q - sin_ω0) / (2.0 * final_q + sin_ω0),
      b: cos_ω0
    ]
  end

end
