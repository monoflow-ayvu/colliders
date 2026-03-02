defmodule Colliders do
  @moduledoc """
  Colliders module for polygon operations and collision detection.
  """

  alias Colliders.Types.BBox
  alias Colliders.Types.PolygonPoint
  alias Colliders.Clipper
  alias Colliders.Polygon

  @eps 1.0e-9

  @doc """
  Checks if a bounding box overlaps a polygon by at least `threshold`% of the bbox area.

  Uses an AABB pre-check for fast rejection, then computes the exact overlap percentage
  via the Sutherland-Hodgman clipping algorithm.

  ## Parameters
  - bbox: A `%BBox{}` struct (x, y = top-left corner, w = width, h = height)
  - polygon: A `%Polygon{}` struct (use `Colliders.Polygon.new/1` to create one)
  - threshold: Minimum overlap percentage required (default: `5.0`)
  """
  def bbox_intersects_polygon?(%BBox{} = bbox, %Polygon{} = polygon, threshold \\ 5.0) do
    if outside_aabb?(bbox, polygon) do
      false
    else
      bbox_overlap_percentage(bbox, polygon) + @eps >= threshold
    end
  end

  # Returns true if the bbox is entirely outside the polygon's AABB
  # AABB stads for Axis-Aligned Bounding Box, it is basically a bounding box for the polygon
  defp outside_aabb?(
         %BBox{x: bx, y: by, w: bw, h: bh},
         %Polygon{min_x: min_x, max_x: max_x, min_y: min_y, max_y: max_y}
       ) do
    bx + bw < min_x or bx > max_x or by + bh < min_y or by > max_y
  end

  @doc """
  Returns the percentage of the bbox area that overlaps with the polygon.

  A value of `100.0` means the bbox is fully inside the polygon.
  A value of `0.0` means no overlap at all.

  ## Parameters
  - bbox: A `%BBox{}` struct
  - polygon: A `%Polygon{}` struct
  """
  @spec bbox_overlap_percentage(BBox.t(), Polygon.t()) :: float()
  def bbox_overlap_percentage(bbox, %Polygon{points: points}) do
    intersection_area =
      points
      |> Clipper.clip_polygon(bbox)
      |> Clipper.area()

    bbox_area =
      bbox
      |> bbox_to_polygon_points()
      |> Clipper.area()

    intersection_area / bbox_area * 100
  end

  defp bbox_to_polygon_points(%BBox{x: x, y: y, w: w, h: h}) do
    [
      # Top-left
      %PolygonPoint{x: x, y: y},
      # Top-right
      %PolygonPoint{x: x + w, y: y},
      # Bottom-right
      %PolygonPoint{x: x + w, y: y + h},
      # Bottom-left
      %PolygonPoint{x: x, y: y + h}
    ]
  end
end
