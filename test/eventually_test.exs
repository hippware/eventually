defmodule EventuallyTest do
  use ExUnit.Case
  doctest Eventually

  alias ExUnit.AssertionError

  import Eventually

  setup do
    {:ok, start: DateTime.utc_now()}
  end

  describe "assert_eventually/3" do
    test "tests that are always truthy pass" do
      assert_eventually true
      assert_eventually 1
    end

    test "tests that are always falsy fail" do
      assert_raise AssertionError, fn ->
        assert_eventually false, 5, 1
      end

      assert_raise AssertionError, fn ->
        assert_eventually nil, 5, 1
      end
    end

    test "tests that eventually become truthy within the timeout pass", ctx do
      assert_eventually wait(ctx.start, 50, true)
      assert_eventually wait(ctx.start, 50, 1)
    end

    test "tests that do not become truthy within the timeout fail", ctx do
      assert_raise AssertionError, fn ->
        assert_eventually wait(ctx.start, 11_000, true), 5, 1
      end
    end

    test "return value on success should be return value of condition fun", ctx do
      assert assert_eventually(_a = "test value") == "test value"
      assert assert_eventually(wait(ctx.start, 50, _b = "abcd")) == "abcd"
    end
  end

  describe "refute_eventually/3" do
    test "tests that are always falsy pass" do
      refute_eventually false
      refute_eventually nil
    end

    test "tests that are always truthy fail" do
      assert_raise AssertionError, fn ->
        refute_eventually true, 5, 1
      end

      assert_raise AssertionError, fn ->
        refute_eventually 1, 5, 1
      end
    end

    test "tests that eventually become falsy within the timeout pass", ctx do
      refute_eventually wait(ctx.start, 50, false)
      refute_eventually wait(ctx.start, 50, nil)
    end

    test "tests that do not become falsy within the timeout fail", ctx do
      assert_raise AssertionError, fn ->
        refute_eventually wait(ctx.start, 11_000, false), 5, 1
      end
    end

    test "return value on success should be return value of condition fun", ctx do
      assert refute_eventually("test value" != "test value") == false
      assert refute_eventually(wait(ctx.start, 50, "abcd" != "abcd")) == false
      assert refute_eventually(wait(ctx.start, 50, _a = nil)) == nil
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
