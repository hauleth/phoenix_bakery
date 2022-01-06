defmodule PhoenixBakery.BrotliTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @assets_dir "test/fixtures/"

  describe "library" do
    @tag :tmp_dir
    test "encode files", %{tmp_dir: tmp_dir} do
      run([Path.join(@assets_dir, "regular"), "-o", tmp_dir])
      files = File.ls!(tmp_dir)

      refute "empty.txt.zst" in files
      assert "test.txt.br" in files
      assert_integral([tmp_dir, "test.txt.br"])
      assert "test-2482cc4df40800ca35f6b294884c0fe6.txt.br" in files
      assert_integral([tmp_dir, "test-2482cc4df40800ca35f6b294884c0fe6.txt.br"])
    end

    @tag :tmp_dir
    @tag :huge
    test "encode huge files", %{tmp_dir: tmp_dir} do
      run([Path.join(@assets_dir, "huge"), "-o", tmp_dir])

      files = File.ls!(tmp_dir)

      assert "roman-roads.svg.br" in files
      assert_integral([tmp_dir, "roman-roads.svg.br"])
      assert "roman-roads-66f13c2999fe805a32699a53e13e2c05.svg.br" in files
      assert_integral([tmp_dir, "roman-roads-66f13c2999fe805a32699a53e13e2c05.svg.br"])
    end
  end

  describe "executable" do
    setup do
      :code.purge(:brotli)
      :code.delete(:brotli)
      ebin_path = Mix.Project.compile_path(app: :brotli, build_per_environment: true)

      assert Code.delete_path(ebin_path)

      on_exit(fn ->
        Code.prepend_path(ebin_path)
      end)

      :ok
    end

    @tag :tmp_dir
    test "encode files", %{tmp_dir: tmp_dir} do
      run([Path.join(@assets_dir, "regular"), "-o", tmp_dir])
      files = File.ls!(tmp_dir)

      assert "test.txt.br" in files
      assert_integral([tmp_dir, "test.txt.br"])
      assert "test-2482cc4df40800ca35f6b294884c0fe6.txt.br" in files
      assert_integral([tmp_dir, "test-2482cc4df40800ca35f6b294884c0fe6.txt.br"])
    end

    @tag :tmp_dir
    test "throws error when utility not available", %{tmp_dir: tmp_dir} do
      Application.put_env(:phoenix_bakery, :brotli, nil)

      assert_raise RuntimeError, fn ->
        run([Path.join(@assets_dir, "regular"), "-o", tmp_dir])
      end
    after
      Application.delete_env(:phoenix_bakery, :brotli)
    end
  end

  defp run(opts) do
    capture_io(fn ->
      Mix.Task.rerun("phx.digest", opts)
    end)
  end

  defp assert_integral(file) do
    path = PhoenixBakery.find_executable(:brotli)

    assert {_, 0} = System.cmd(path, ["-t", Path.join(List.wrap(file))])
  end
end
