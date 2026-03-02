defmodule Colliders.Polygon do
  @moduledoc """
  A prepared polygon struct that precomputes its axis-aligned bounding box (AABB)
  at creation time, enabling O(1) rejection of bboxes that clearly don't overlap.

  The Colliders.Polygon.new/2 first argument also accepts a list of maps with x and y keys, or tuples with x and y values.

  ## Usage
  iex> polygon = Colliders.Polygon.new([
  ...>   %PolygonPoint{x: 0, y: 0},
  ...>   %PolygonPoint{x: 10, y: 0},
  ...>   %PolygonPoint{x: 10, y: 10},
  ...>   %PolygonPoint{x: 0, y: 10}
  ...> ])
  ...> Colliders.bbox_intersects_polygon?(%Colliders.Types.BBox{x: 0, y: 0, w: 10, h: 10}, polygon)
  true
  """

  alias Colliders.Types.PolygonPoint

  @type map_point() ::
          %{required(String.t()) => float(), required(String.t()) => float()}
          | %{x: float(), y: float()}

  @type points() :: list(PolygonPoint.t()) | list(map_point()) | list({float(), float()})

  @type t :: %__MODULE__{
          points: points(),
          meta: map(),
          min_x: float(),
          max_x: float(),
          min_y: float(),
          max_y: float()
        }

  defstruct [:points, :meta, :min_x, :max_x, :min_y, :max_y]

  @doc """
  Creates a new `%Polygon{}` from a list of `%PolygonPoint{}` structs,
  precomputing the bounding box bounds.

  Raises `ArgumentError` if fewer than 3 points are provided.
  """
  @spec new(points(), map()) :: t()
  def new(points, meta \\ %{})

  def new(points, _meta) when not is_list(points) do
    raise ArgumentError,
          "First argument must be a list with at least 3 elements, got #{inspect(points)}"
  end

  def new(points, _meta) when length(points) < 3 do
    raise ArgumentError, "A polygon requires at least 3 points, got #{length(points)}"
  end

  def new(points, meta) do
    normalized_points = normalize_points(points)
    x_coords = Enum.map(normalized_points, &axis_coords(&1, :x))
    y_coords = Enum.map(normalized_points, &axis_coords(&1, :y))

    %__MODULE__{
      points: normalized_points,
      meta: meta,
      min_x: Enum.min(x_coords),
      max_x: Enum.max(x_coords),
      min_y: Enum.min(y_coords),
      max_y: Enum.max(y_coords)
    }
  end

  defp normalize_points(points) do
    Enum.map(points, fn
      %PolygonPoint{} = point -> point
      point -> PolygonPoint.new(point)
    end)
  end

  defp axis_coords({x, _y}, :x), do: x
  defp axis_coords(%{x: x, y: _y}, :x), do: x
  defp axis_coords(%{"x" => x, "y" => _y}, :x), do: x

  defp axis_coords({_x, y}, :y), do: y
  defp axis_coords(%{x: _x, y: y}, :y), do: y
  defp axis_coords(%{"x" => _x, "y" => y}, :y), do: y
end
