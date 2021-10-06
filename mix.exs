defmodule PhoenixBakery.MixProject do
  use Mix.Project

  @description File.read!("README.md")
               |> String.split(~r/<!--\s*(start|end):PhoenixBakery\s*-->/, parts: 3)
               |> Enum.at(1)
               |> String.trim()
               |> String.split(~r/\n/, parts: 2)
               |> List.first()

  @github "https://github.com/hauleth/phoenix_bakery"

  def project do
    version = version()

    [
      app: :phoenix_bakery,
      description: @description,
      version: version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @github,
      docs: [
        main: "PhoenixBakery",
        source_ref: "v#{version}",
        groups_for_modules: [
          Compressors: ~r/^PhoenixBakery\./
        ]
      ],
      package: [
        licenses: ~w[MIT],
        links: %{
          "GitHub" => @github
        }
      ]
    ]
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
      {:phoenix, "~> 1.6.0"},
      {:brotli, "~> 0.3.0", optional: true},
      {:ezstd, "~> 1.0", optional: true},
      {:jason, ">= 0.0.0", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: [:dev]}
    ]
  end

  defp version do
    with :error <- hex_version(),
         :error <- git_version() do
      "0.0.0-dev"
    else
      {:ok, ver} -> ver
    end
  end

  defp hex_version do
    with {:ok, terms} <- :file.consult("hex_metadata.config"),
         {"version", version} <- List.keyfind(terms, "version", 0) do
      {:ok, version}
    else
      _ -> :error
    end
  end

  defp git_version do
    System.cmd("git", ~w[describe])
  else
    {"v" <> ver, 0} -> {:ok, String.trim(ver)}
    _ -> :error
  catch
    _, _ -> :error
  end
end
