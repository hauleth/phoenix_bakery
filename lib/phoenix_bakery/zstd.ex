defmodule PhoenixBakery.Zstd do
  @external_resource "README.md"
  @moduledoc File.read!("README.md")
             |> String.split(~r/<!--\s*(start|end):#{inspect(__MODULE__)}\s*-->/, parts: 3)
             |> Enum.at(1)

  @behaviour Phoenix.Digester.Compressor

  import PhoenixBakery

  require Logger

  @impl true
  def file_extensions, do: ~w[.zst]

  @impl true
  def compress_file(file_path, content, opts \\ []) do
    if gzippable?(file_path) do
      compress(content, opts)
    else
      :error
    end
  end

  defp compress(content, opts) do
    case encode(content, opts) do
      {:ok, compressed} when byte_size(compressed) < byte_size(content) ->
        {:ok, compressed}

      _ ->
        :error
    end
  end

  defp encode(content, opts) do
    compress_level = Keyword.get(opts, :level, 22)
    options = options(:ztsd, %{level: compress_level})

    cond do
      Code.ensure_loaded?(:ezstd) and function_exported?(:ezstd, :compress, 1) ->
        {:ok, :ezstd.compress(content, options.level)}

      path = find_executable(:zstd) ->
        run(:zstd, content, path, ~w[-c --ultra -#{options.level}])

      true ->
        raise "No `zstd` utility"
    end
  end
end
