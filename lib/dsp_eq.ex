defmodule DspEq do
  @moduledoc """
  Documentation for `DspEq`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> DspEq.dsp_eq_gain(1.0)
      1.1220184543019633

  """

  @type eq_freq :: float
  @type eq_q_factor :: float
  @type eq_gain :: float
  @type eq_a_coeff :: float
  @type eq_b_coeff :: float
  @type eq_coeffs :: [
    a_coeff: eq_a_coeff,
    b_coeff: eq_b_coeff
  ]

  @spec sample_rate :: 48000
  def sample_rate, do: 48000

  @spec dsp_eq_gain(eq_gain) :: float
  def dsp_eq_gain(gain) when gain < -12.0 do
    dsp_eq_gain(-12.0)
  end

  def dsp_eq_gain(gain) when gain > 12.0 do
    dsp_eq_gain(12.0)
  end

  def dsp_eq_gain(gain) do
    :math.pow(10.0, gain / 20.0)
  end


  @spec dsp_eq_coeffs(eq_freq, eq_q_factor, eq_gain) :: eq_coeffs
  def dsp_eq_coeffs(freq, q_factor, gain) when q_factor < 0.1 do
    dsp_eq_coeffs(freq, 0.1, gain)
  end

  def dsp_eq_coeffs(freq, q_factor, gain) do
    omega_c = (2.0 * :math.pi) * freq / sample_rate()
    sin_omega_c = :math.sin(omega_c)
    cos_omega_c = :math.cos(omega_c)
    g = dsp_eq_gain(gain)
    q = :math.pow(2.0, (1 / q_factor) / 2.0)
    q_2 = q / (q * q - 1.0)
    omega_3 = omega_c * (:math.sqrt(4.0 * q_2 * q_2 + 1.0) - 1.0) / (q_2 + q_2)
    q_3 = :math.sin(omega_3) * sin_omega_c / (2.0 * (:math.cos(omega_3) - cos_omega_c))
    final_q = if gain < 0.0, do: q_3 * g, else: q_3
    a = (2.0 * final_q - sin_omega_c) / (2.0 * final_q + sin_omega_c)
    [a_coeff: a, b_coeff: cos_omega_c]
  end

end
