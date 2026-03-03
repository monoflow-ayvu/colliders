defmodule Colliders.Types.PolygonPoint do
  @moduledoc """
  A single vertex in a polygon, with `x` and `y` coordinates stored as floats.

  Use `new/1` to build a `%PolygonPoint{}` from a tuple or a map. Integer
  coordinates are automatically converted to floats.
  """

  @derive JSON.Encoder
  defstruct x: 0.0, y: 0.0

  @type t() :: %__MODULE__{
          x: float(),
          y: float()
        }

  @doc """
  Creates a new `%PolygonPoint{}` from a tuple or a map.

  Accepts:
  - `{x, y}`
  - `%{x: x, y: y}`
  - `%{"x" => x, "y" => y}`

  Integer values are converted to floats automatically.
  Raises `ArgumentError` for any other input.

  ## Examples

      iex> Colliders.Types.PolygonPoint.new({10, 20})
      %Colliders.Types.PolygonPoint{x: 10.0, y: 20.0}

      iex> Colliders.Types.PolygonPoint.new(%{x: 1.5, y: 3.0})
      %Colliders.Types.PolygonPoint{x: 1.5, y: 3.0}

      iex> Colliders.Types.PolygonPoint.new(%{"x" => 5, "y" => 8})
      %Colliders.Types.PolygonPoint{x: 5.0, y: 8.0}
  """
  @spec new({number(), number()} | %{x: number(), y: number()} | %{String.t() => number()}) ::
          t()
  def new(%{x: x, y: y}), do: new({x, y})
  def new(%{"x" => x, "y" => y}), do: new({x, y})

  def new({x, y}) when is_integer(x) or is_integer(y) do
    %__MODULE__{
      x: x / 1,
      y: y / 1
    }
  end

  def new({x, y}) when is_float(x) and is_float(y) do
    %__MODULE__{
      x: x,
      y: y
    }
  end

  def new(point) do
    raise ArgumentError, """
    Point argument must be either one of the three:
    - %{"x" => x, "y" => y}
    - %{x: x, y: y}
    - {x, y}

    Got #{inspect(point)}
    """
  end
end
