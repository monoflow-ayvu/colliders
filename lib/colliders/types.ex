defmodule Colliders.Types do
  defmodule PolygonPoint do
    @moduledoc """
    A single vertex in a polygon, with `x` and `y` coordinates stored as floats.

    Use `new/1` to build a `%PolygonPoint{}` from a tuple or a map. Integer
    coordinates are automatically converted to floats.
    """

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

  defmodule BBox do
    @moduledoc """
    An axis-aligned bounding box, where `x` and `y` represent the top-left corner,
    and `w` and `h` represent the width and height. All fields are stored as floats.

    Use `new/1` to build a `%BBox{}` from a tuple or a map. Integer values are
    automatically converted to floats.
    """

    defstruct x: 0.0, y: 0.0, w: 0.0, h: 0.0

    @type t() :: %__MODULE__{
            x: float(),
            y: float(),
            w: float(),
            h: float()
          }

    @doc """
    Creates a new `%BBox{}` from a tuple or a map.

    Accepts:
    - `{x, y, w, h}`
    - `%{x: x, y: y, w: w, h: h}`
    - `%{"x" => x, "y" => y, "w" => w, "h" => h}`

    Integer values are converted to floats automatically.
    Raises `ArgumentError` for any other input.

    ## Examples

        iex> Colliders.Types.BBox.new({10, 20, 100, 50})
        %Colliders.Types.BBox{x: 10.0, y: 20.0, w: 100.0, h: 50.0}

        iex> Colliders.Types.BBox.new(%{x: 1.5, y: 3.0, w: 10.0, h: 5.0})
        %Colliders.Types.BBox{x: 1.5, y: 3.0, w: 10.0, h: 5.0}

        iex> Colliders.Types.BBox.new(%{"x" => 0, "y" => 0, "w" => 200, "h" => 100})
        %Colliders.Types.BBox{x: 0.0, y: 0.0, w: 200.0, h: 100.0}
    """
    @spec new(
            {number(), number(), number(), number()}
            | %{x: number(), y: number(), w: number(), h: number()}
            | %{String.t() => number()}
          ) :: t()
    def new(%{x: x, y: y, w: w, h: h}), do: new({x, y, w, h})
    def new(%{"x" => x, "y" => y, "w" => w, "h" => h}), do: new({x, y, w, h})

    def new({x, y, w, h}) when is_integer(x) or is_integer(y) or is_integer(w) or is_integer(h) do
      %__MODULE__{
        x: x / 1,
        y: y / 1,
        w: w / 1,
        h: h / 1
      }
    end

    def new({x, y, w, h}) when is_float(x) and is_float(y) and is_float(w) and is_float(h) do
      %__MODULE__{
        x: x,
        y: y,
        w: w,
        h: h
      }
    end

    def new(coords) do
      raise ArgumentError, """
      Coords argument must be either one of the three:

      - %{"x" => x, "y" => y, "w" => w, "h" => h}
      - %{x: x, y: y, w: w, h: h}
      - {x, y, w, h}

      Got #{inspect(coords)}
      """
    end
  end
end
