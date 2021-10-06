defmodule PhoenixBakery do
  @moduledoc File.read!("README.md")
             |> String.split(~r/<!--\s*(start|end):#{inspect(__MODULE__)}\s*-->/, parts: 3)
             |> Enum.at(1)

  @otp_app :phoenix_bakery

  @doc false
  def gzippable?(path) do
    Path.extname(path) in Application.fetch_env!(:phoenix, :gzippable_exts)
  end

  @doc false
  def find_executable(name), do: find_executable(name, Atom.to_string(name))

  @doc false
  def find_executable(name, default) do
    case Application.fetch_env(@otp_app, name) do
      {:ok, path} -> path
      _ -> System.find_executable(default)
    end
  end

  @doc false
  def run(type, content, cmd, opts) do
    dir = Path.join([System.tmp_dir!(), "phoenix_bakery", to_string(type)])
    hash = Base.url_encode64(:erlang.md5(content), padding: false)
    File.mkdir_p!(dir)
    file = Path.join(dir, hash)
    File.write!(file, content)

    try do
      case System.cmd(cmd, opts ++ ["--", file], env: []) do
        {output, 0} ->
          {:ok, output}

        _ ->
          :error
      end
    after
      File.rm(file)
    end
  end

  @doc false
  def options(name, default) do
    opts = Application.get_env(@otp_app, :"#{name}_opts", %{})

    Map.merge(default, opts)
  end
end
