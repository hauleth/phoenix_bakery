defmodule PhoenixBakery.ZstdTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  @assets_dir "test/fixtures/"

  describe "library" do
    @tag :tmp_dir
    test "encode files", %{tmp_dir: tmp_dir} do
      run([Path.join(@assets_dir, "regular"), "-o", tmp_dir])

      files = File.ls!(tmp_dir)

      refute "empty.txt.zst" in files
      assert "test.txt.zst" in files
      assert_integral([tmp_dir, "test.txt.zst"])
      assert "test-2482cc4df40800ca35f6b294884c0fe6.txt.zst" in files
      assert_integral([tmp_dir, "test-2482cc4df40800ca35f6b294884c0fe6.txt.zst"])
    end

    @tag :tmp_dir
    @tag :huge
    test "encode huge files", %{tmp_dir: tmp_dir} do
      run([Path.join(@assets_dir, "huge"), "-o", tmp_dir])

      files = File.ls!(tmp_dir)

      assert "roman-roads.svg.zst" in files
      assert_integral([tmp_dir, "roman-roads.svg.zst"])
      assert "roman-roads-66f13c2999fe805a32699a53e13e2c05.svg.zst" in files
      assert_integral([tmp_dir, "roman-roads-66f13c2999fe805a32699a53e13e2c05.svg.zst"])
    end
  end

  # Erlang's Zstd will always be used when it is defined
  if not Code.ensure_loaded?(:zstd) do
    describe "executable" do
      setup do
        :code.purge(:ezstd)
        :code.delete(:ezstd)
        ebin_path = Mix.Project.compile_path(app: :ezstd, build_per_environment: true)

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

        assert "test.txt.zst" in files
        assert_integral([tmp_dir, "test.txt.zst"])
        assert "test-2482cc4df40800ca35f6b294884c0fe6.txt.zst" in files
        assert_integral([tmp_dir, "test-2482cc4df40800ca35f6b294884c0fe6.txt.zst"])
      end
    end
  end

  defp run(opts) do
    capture_io(fn ->
      Mix.Task.rerun("phx.digest", opts)
    end)
  end

  defp assert_integral(file) do
    path = PhoenixBakery.find_executable(:zstd)

    assert {_, 0} = System.cmd(path, ["--test", Path.join(List.wrap(file))])
  end
end
