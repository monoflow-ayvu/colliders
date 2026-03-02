defmodule Colliders.Clipper do
  @moduledoc """
  Implements the Sutherland-Hodgman polygon clipping algorithm.
  Clips a polygon against a rectangular bounding box.
  """

  alias Colliders.Polygon
  alias Colliders.Types.BBox
  alias Colliders.Types.PolygonPoint
  alias Geo.Turf

  @eps 1.0e-9

  @doc """
  Clips a polygon to the given bounding box.

  ## Parameters
  - subject_polygon: List of `%PolygonPoint{}` structs representing polygon vertices
  - bbox: A `%BBox{}` struct representing the bounding box

  ## Returns
  List of `%PolygonPoint{}` structs representing the clipped polygon vertices,
  or an empty list if there is no intersection.
  """
  @spec clip_polygon(list(PolygonPoint.t() | Polygon.t()), BBox.t()) :: [PolygonPoint.t()]
  def clip_polygon([], _bbox), do: []
  def clip_polygon(%Polygon{points: points}, bbox), do: clip_polygon(points, bbox)

  def clip_polygon([%PolygonPoint{} | _] = polygon_points, %BBox{x: x, y: y, w: w, h: h}) do
    polygon_points
    |> ensure_closed()
    |> clip_edge(:left, x)
    |> clip_edge(:right, x + w)
    |> clip_edge(:bottom, y)
    |> clip_edge(:top, y + h)
    |> unclosed_polygon()
    |> remove_consecutive_duplicates()
  end

  @doc """
  Calculates the area of a polygon in square units.

  ## Parameters
  - polygon_points: List of `%PolygonPoint{}` structs representing the polygon vertices, or the whole `%Colliders.Polygon{}` struct

  ## Returns
  The area as a float in square units.
  """
  @spec area(list(PolygonPoint.t()) | Colliders.Polygon.t()) :: float()
  def area([]), do: 0.0
  def area(%Colliders.Polygon{points: points}), do: area(points)

  def area([%PolygonPoint{} | _] = polygon_points) do
    coordinates = Enum.map(polygon_points, fn %PolygonPoint{x: x, y: y} -> {x, y} end)
    geo_polygon = %Geo.Polygon{coordinates: [coordinates]}
    Turf.Measure.area(geo_polygon)
  end

  defp clip_edge([], _edge, _clip_coordinate), do: []

  defp clip_edge(polygon, edge, clip_coordinate) do
    polygon
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce([], fn [start_point, end_point], clipped_points ->
      start_inside = inside?(start_point, edge, clip_coordinate)
      end_inside = inside?(end_point, edge, clip_coordinate)

      cond do
        start_inside and end_inside ->
          [end_point | clipped_points]

        start_inside and not end_inside ->
          [intersection(start_point, end_point, edge, clip_coordinate) | clipped_points]

        not start_inside and end_inside ->
          [
            end_point,
            intersection(start_point, end_point, edge, clip_coordinate)
            | clipped_points
          ]

        true ->
          clipped_points
      end
    end)
    |> Enum.reverse()
    |> ensure_closed()
  end

  defp ensure_closed([]), do: []

  defp ensure_closed([first | _] = polygon) do
    last = List.last(polygon)
    if same_point?(first, last), do: polygon, else: polygon ++ [first]
  end

  defp unclosed_polygon([]), do: []

  defp unclosed_polygon([first | _] = polygon) do
    last = List.last(polygon)
    if same_point?(first, last), do: Enum.drop(polygon, -1), else: polygon
  end

  defp inside?(%PolygonPoint{x: x, y: _y}, :left, xmin), do: x >= xmin - @eps
  defp inside?(%PolygonPoint{x: x, y: _y}, :right, xmax), do: x <= xmax + @eps
  defp inside?(%PolygonPoint{x: _x, y: y}, :bottom, ymin), do: y >= ymin - @eps
  defp inside?(%PolygonPoint{x: _x, y: y}, :top, ymax), do: y <= ymax + @eps

  defp intersection(%PolygonPoint{x: x1, y: y1}, %PolygonPoint{x: x2, y: y2}, edge, boundary)
       when edge in [:left, :right] do
    if abs(x2 - x1) < @eps do
      %PolygonPoint{x: boundary, y: y1}
    else
      ratio = (boundary - x1) / (x2 - x1)
      %PolygonPoint{x: boundary, y: y1 + ratio * (y2 - y1)}
    end
  end

  defp intersection(%PolygonPoint{x: x1, y: y1}, %PolygonPoint{x: x2, y: y2}, edge, boundary)
       when edge in [:bottom, :top] do
    if abs(y2 - y1) < @eps do
      %PolygonPoint{x: x1, y: boundary}
    else
      ratio = (boundary - y1) / (y2 - y1)
      %PolygonPoint{x: x1 + ratio * (x2 - x1), y: boundary}
    end
  end

  defp remove_consecutive_duplicates([]), do: []

  defp remove_consecutive_duplicates([first_point | remaining_points]) do
    remaining_points
    |> Enum.reduce([first_point], fn point, [last_point | _] = clipped_points ->
      if same_point?(point, last_point),
        do: clipped_points,
        else: [point | clipped_points]
    end)
    |> Enum.reverse()
  end

  defp same_point?(%PolygonPoint{x: x1, y: y1}, %PolygonPoint{x: x2, y: y2}) do
    abs(x1 - x2) < @eps and abs(y1 - y2) < @eps
  end
end
