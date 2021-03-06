defmodule Dsp.MixProject do
  use Mix.Project

  def project do
    [
      app: :dsp,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  defp escript do
    [main_module: Dsp]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:stream_data, "~> 0.4", only: :test},
      {:jason, "~> 1.2"},
      #{:circuits_uart, "~> 1.4"},
      {:circuits_uart, git: "https://github.com/tomboland/circuits_uart.git", tag: "feature/termios2-custom-baud"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
