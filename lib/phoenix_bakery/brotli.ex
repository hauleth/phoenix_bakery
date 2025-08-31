defmodule PhoenixBakery.Brotli do
  @external_resource "README.md"
  @moduledoc File.read!("README.md")
             |> String.split(~r/<!--\s*(start|end):#{inspect(__MODULE__)}\s*-->/, parts: 3)
             |> Enum.at(1)

  @behaviour Phoenix.Digester.Compressor

  @default_opts %{
    quality: 11
  }

  import PhoenixBakery

  require Logger

  @impl true
  def file_extensions, do: ~w[.br]

  @impl true
  def compress_file(file_path, content) do
    if gzippable?(file_path) do
      compress(content)
    else
      :error
    end
  end

  defp compress(content) do
    options = options(:brotli, @default_opts)

    case encode(content, options) do
      {:ok, compressed} when byte_size(compressed) < byte_size(content) ->
        {:ok, compressed}

      _ ->
        :error
    end
  end

  defp encode(content, options) do
    cond do
      Code.ensure_loaded?(:brotli) and function_exported?(:brotli, :encode, 2) ->
        :brotli.encode(content, %{quality: options.quality})

      path = find_executable(:brotli) ->
        run(:brotli, content, path, ~w[-c -q #{options.quality}])

      true ->
        raise "No `brotli` utility"
    end
  end
end
