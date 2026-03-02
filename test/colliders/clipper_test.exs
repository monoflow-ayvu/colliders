defmodule Colliders.ClipperTest do
  use ExUnit.Case, async: true

  alias Colliders.Clipper
  alias Colliders.Types.{BBox, PolygonPoint}

  describe "clip_polygon/2" do
    test "returns empty list for empty input polygon" do
      assert Clipper.clip_polygon([], %BBox{x: 0, y: 0, w: 10, h: 10}) == []
    end

    test "returns full polygon when it is entirely inside the bbox" do
      polygon = square(2, 2, 4)
      bbox = %BBox{x: 0, y: 0, w: 10, h: 10}
      clipped = Clipper.clip_polygon(polygon, bbox)

      assert length(clipped) == 4
      assert_in_delta Clipper.area(clipped), Clipper.area(polygon), 1.0
    end

    test "returns empty list when polygon is entirely outside the bbox" do
      polygon = square(20, 20, 5)
      bbox = %BBox{x: 0, y: 0, w: 10, h: 10}

      assert Clipper.clip_polygon(polygon, bbox) == []
    end

    test "clips to bbox boundaries when bbox is fully inside the polygon" do
      # polygon: 0-20 square; bbox: 5-10 square (completely inside polygon)
      # result must be a 4-point polygon whose points are all within the bbox
      polygon = square(0, 0, 20)
      bbox = %BBox{x: 5, y: 5, w: 5, h: 5}
      clipped = Clipper.clip_polygon(polygon, bbox)

      assert length(clipped) == 4

      Enum.each(clipped, fn %PolygonPoint{x: x, y: y} ->
        assert x >= 5 - 1.0e-6 and x <= 10 + 1.0e-6
        assert y >= 5 - 1.0e-6 and y <= 10 + 1.0e-6
      end)
    end

    test "clips correctly when half of the polygon is outside the bbox" do
      # polygon: 0-10 square; bbox covers right half (x: 5-15, y: 0-10)
      # intersection: x 5-10, y 0-10 → exactly half the polygon area
      polygon = square(0, 0, 10)
      bbox = %BBox{x: 5, y: 0, w: 10, h: 10}
      clipped = Clipper.clip_polygon(polygon, bbox)

      assert_in_delta Clipper.area(clipped) / Clipper.area(polygon), 0.5, 0.001
    end

    test "clips correctly when one corner of the polygon overlaps the bbox" do
      # polygon: 0-10 square; bbox: 5-15 square
      # intersection: x 5-10, y 5-10 → 25% of the polygon area
      polygon = square(0, 0, 10)
      bbox = %BBox{x: 5, y: 5, w: 10, h: 10}
      clipped = Clipper.clip_polygon(polygon, bbox)

      assert length(clipped) == 4
      assert_in_delta Clipper.area(clipped) / Clipper.area(polygon), 0.25, 0.001
    end

    test "handles concave L-shaped polygon: bbox inside the notch gives no area" do
      # L-shape: bottom rect (x:0-10, y:0-5) + left rect (x:0-5, y:5-10)
      # bbox covers the top-right notch (x:6-9, y:6-9) which is NOT part of the L
      polygon = [
        %PolygonPoint{x: 0, y: 0},
        %PolygonPoint{x: 10, y: 0},
        %PolygonPoint{x: 10, y: 5},
        %PolygonPoint{x: 5, y: 5},
        %PolygonPoint{x: 5, y: 10},
        %PolygonPoint{x: 0, y: 10}
      ]

      bbox = %BBox{x: 6, y: 6, w: 3, h: 3}
      clipped = Clipper.clip_polygon(polygon, bbox)

      assert_in_delta Clipper.area(clipped), 0.0, 1.0
    end

    test "handles concave L-shaped polygon: bbox crossing the inner corner" do
      # L-shape: bottom rect (x:0-10, y:0-5) + left rect (x:0-5, y:5-10)
      # bbox: x 3-7, y 3-7
      # intersection: bottom part 4x2=8 + left part 2x2=4 = 12 sq units → 75% of 4x4 bbox
      polygon = [
        %PolygonPoint{x: 0, y: 0},
        %PolygonPoint{x: 10, y: 0},
        %PolygonPoint{x: 10, y: 5},
        %PolygonPoint{x: 5, y: 5},
        %PolygonPoint{x: 5, y: 10},
        %PolygonPoint{x: 0, y: 10}
      ]

      bbox = %BBox{x: 3, y: 3, w: 4, h: 4}
      clipped = Clipper.clip_polygon(polygon, bbox)
      bbox_area = Clipper.area(square(3, 3, 4))

      # 12/16 = 75% of bbox area is inside the L
      assert_in_delta Clipper.area(clipped) / bbox_area, 0.75, 0.01
    end

    test "produces near-zero area when polygon and bbox share only an edge" do
      # polygon: 0-10 square; bbox starts exactly where polygon ends (x: 10)
      polygon = square(0, 0, 10)
      bbox = %BBox{x: 10, y: 0, w: 10, h: 10}
      clipped = Clipper.clip_polygon(polygon, bbox)

      # Shared edge has no area
      assert_in_delta Clipper.area(clipped), 0.0, 1.0
    end
  end

  describe "area/1" do
    test "returns 0.0 for empty polygon" do
      assert Clipper.area([]) == 0.0
    end

    test "returns a positive value for a valid polygon" do
      assert Clipper.area(square(0, 0, 10)) > 0
    end

    test "larger polygon has larger area than smaller polygon" do
      assert Clipper.area(square(0, 0, 10)) > Clipper.area(square(0, 0, 5))
    end

    test "area ratio is exact for rectangles sharing the same latitude range" do
      # Two rectangles with the same y (latitude) range: geographic distortion cancels out,
      # so the ratio of areas equals the ratio of widths exactly
      rect_wide = [
        %PolygonPoint{x: 0, y: 0},
        %PolygonPoint{x: 10, y: 0},
        %PolygonPoint{x: 10, y: 10},
        %PolygonPoint{x: 0, y: 10}
      ]

      rect_narrow = [
        %PolygonPoint{x: 0, y: 0},
        %PolygonPoint{x: 5, y: 0},
        %PolygonPoint{x: 5, y: 10},
        %PolygonPoint{x: 0, y: 10}
      ]

      # rect_wide is twice as wide → exactly 2× the area
      assert_in_delta Clipper.area(rect_wide) / Clipper.area(rect_narrow), 2.0, 0.001
    end
  end

  # Builds a square polygon from a top-left corner and side size
  defp square(x, y, size) do
    [
      %PolygonPoint{x: x, y: y},
      %PolygonPoint{x: x + size, y: y},
      %PolygonPoint{x: x + size, y: y + size},
      %PolygonPoint{x: x, y: y + size}
    ]
  end
end
