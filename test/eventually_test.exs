defmodule EventuallyTest do
  use ExUnit.Case
  doctest Eventually

  alias ExUnit.AssertionError

  import Eventually

  setup do
    {:ok, start: DateTime.utc_now()}
  end

  describe "assert_eventually/3" do
    test "tests that are always true pass" do
      assert_eventually true
    end

    test "tests that are always false fail" do
      assert_raise AssertionError, fn ->
        assert_eventually false, 5, 1
      end
    end

    test "tests that eventually become true within the timeout pass", ctx do
      assert_eventually wait(ctx.start, 50, true)
    end

    test "tests that do not become true within the timeout fail", ctx do
      assert_raise AssertionError, fn ->
        assert_eventually wait(ctx.start, 11_000, true), 5, 1
      end
    end
  end

  describe "refute_eventually/3" do
    test "tests that are always false pass" do
      refute_eventually false
    end

    test "tests that are always true fail" do
      assert_raise AssertionError, fn ->
        refute_eventually true, 5, 1
      end
    end

    test "tests that eventually become false within the timeout pass", ctx do
      refute_eventually wait(ctx.start, 50, false)
    end

    test "tests that do not become false within the timeout fail", ctx do
      assert_raise AssertionError, fn ->
        refute_eventually wait(ctx.start, 11_000, false), 5, 1
      end
    end
  end

  defp wait(start, time, result) do
    now = DateTime.utc_now()
    stop_at = DateTime.add(start, time, :millisecond)

    if DateTime.compare(now, stop_at) == :gt do
      result
    else
      !result
    end
  end
end
