defmodule Eventually do
  @moduledoc """
  Macros to support assertions/refutations that might not be correct immediately
  but will eventually become so due to, say, eventual consistency.
  """

  @default_timeout 1000
  @default_interval 10

  @doc """
  Assert that the passed clause eventually returns `true`.
  """
  defmacro assert_eventually(
             clause,
             timeout \\ @default_timeout,
             interval \\ @default_interval
           ) do
    quote do
      fun = fn -> unquote(clause) end

      case eventually(fun, true, unquote(timeout), unquote(interval)) do
        :ok ->
          :ok

        {:fail, value} ->
          raise ExUnit.AssertionError,
            expr: unquote(escape_quoted(:assert_eventually, clause)),
            message: "Expected truthy, last got #{inspect(value)}"
      end
    end
  end

  @doc """
  Assert that the passed clause eventually returns `false`.
  """
  defmacro refute_eventually(
             clause,
             timeout \\ @default_timeout,
             interval \\ @default_interval
           ) do
    quote do
      fun = fn -> unquote(clause) end

      case eventually(fun, false, unquote(timeout), unquote(interval)) do
        :ok ->
          :ok

        {:fail, value} ->
          raise ExUnit.AssertionError,
            expr: unquote(escape_quoted(:refute_eventually, clause)),
            message: "Expected false or nil, last got #{inspect(value)}"
      end
    end
  end

  @doc false
  @spec eventually(fun(), boolean(), non_neg_integer(), non_neg_integer()) ::
          :ok | {:fail, any()}
  def eventually(fun, result, timeout, interval),
    do:
      do_eventually(
        fun,
        result,
        interval,
        DateTime.add(DateTime.utc_now(), timeout, :millisecond)
      )

  defp do_eventually(fun, result, interval, stop_at) do
    case check_condition(fun, result) do
      :ok ->
        :ok

      {:fail, value} ->
        if DateTime.compare(stop_at, DateTime.utc_now()) == :lt do
          {:fail, value}
        else
          Process.sleep(interval)
          do_eventually(fun, result, interval, stop_at)
        end
    end
  end

  # Convert the truthiness of the condition to a boolean reflecting whether
  # it matches the test result
  defp check_condition(fun, result) do
    value = fun.()

    if (value && result) || (!value && !result) do
      :ok
    else
      {:fail, value}
    end
  end

  defp escape_quoted(kind, expr) do
    Macro.escape({kind, [], [expr]})
  end
end
