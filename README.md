# Eventually

Macros to support assertions/refutations that might not be correct immediately
but will eventually become so due to, say, eventual consistency.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `eventually` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eventually, "~> 1.0"}
  ]
end
```

Documentation can be found at
[https://hexdocs.pm/eventually](https://hexdocs.pm/eventually).

## Usage

```
test "something that will eventually be true" do
  assert_eventually something_that_will_be_true()
end
```
