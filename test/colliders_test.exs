defmodule CollidersTest do
  use ExUnit.Case, async: true
  doctest Colliders

  alias Colliders
  alias Colliders.Polygon
  alias Colliders.Types.BBox

  describe "bbox_intersects_polygon?/3" do
    test "returns true when bbox is fully inside polygon - 100% overlap" do
      bbox = BBox.new(%{x: 4, y: 4, w: 2, h: 2})

      polygon =
        Polygon.new([
          %{x: 0, y: 0},
          %{x: 10, y: 0},
          %{x: 10, y: 10},
          %{x: 0, y: 10}
        ])

      assert Colliders.bbox_intersects_polygon?(bbox, polygon)
    end

    test "returns true when bbox partially overlaps polygon - 25% overlap" do
      # bbox: x 8-12, y 8-12; polygon: x 0-10, y 0-10
      # intersection: x 8-10, y 8-10 → 2x2 = 4 sq units; bbox: 4x4 = 16 sq units → 25%
      bbox = BBox.new(%{x: 8, y: 8, w: 4, h: 4})

      polygon =
        Polygon.new([
          %{x: 0, y: 0},
          %{x: 10, y: 0},
          %{x: 10, y: 10},
          %{x: 0, y: 10}
        ])

      assert Colliders.bbox_intersects_polygon?(bbox, polygon)
    end

    test "returns false when bbox is completely outside polygon" do
      bbox = BBox.new(%{x: 15, y: 15, w: 5, h: 5})

      polygon =
        Polygon.new([
          %{x: 0, y: 0},
          %{x: 10, y: 0},
          %{x: 10, y: 10},
          %{x: 0, y: 10}
        ])

      refute Colliders.bbox_intersects_polygon?(bbox, polygon)
    end

    test "returns false when large bbox contains tiny polygon - 1% overlap fails default 5% threshold" do
      # polygon is 10x10 = 100 sq units inside a 100x100 bbox → 1%
      bbox = BBox.new(%{x: 0, y: 0, w: 100, h: 100})

      polygon =
        Polygon.new([
          %{x: 45, y: 45},
          %{x: 55, y: 45},
          %{x: 55, y: 55},
          %{x: 45, y: 55}
        ])

      refute Colliders.bbox_intersects_polygon?(bbox, polygon)
    end

    test "returns false when bbox corner just touches polygon corner - 0% overlap" do
      # bbox starts at (10,10), polygon ends at (10,10) - they share only a single point
      bbox = BBox.new(%{x: 10, y: 10, w: 5, h: 5})

      polygon =
        Polygon.new([
          %{x: 0, y: 0},
          %{x: 10, y: 0},
          %{x: 10, y: 10},
          %{x: 0, y: 10}
        ])

      refute Colliders.bbox_intersects_polygon?(bbox, polygon)
    end

    test "returns true when exactly at default 5% threshold" do
      bbox = BBox.new(%{x: 9.9, y: 4, w: 2, h: 4})

      polygon =
        Polygon.new([
          %{x: 0, y: 0},
          %{x: 10, y: 0},
          %{x: 10, y: 10},
          %{x: 0, y: 10}
        ])

      assert Colliders.bbox_intersects_polygon?(bbox, polygon)
    end

    test "returns false just below the default 5% threshold" do
      # ~25% overlap at default 5%, passes; but fails a 30% threshold
      bbox = BBox.new(%{x: 9.5, y: 5, w: 2, h: 2})

      polygon =
        Polygon.new([
          %{x: 0, y: 0},
          %{x: 10, y: 0},
          %{x: 10, y: 10},
          %{x: 0, y: 10}
        ])

      refute Colliders.bbox_intersects_polygon?(bbox, polygon, 30.0)
    end

    test "returns true when half of bbox is inside polygon - 50% overlap" do
      # bbox: x 5-15, y 5-15; polygon: x 0-10, y 0-20
      # intersection: x 5-10, y 5-15 → 5x10 = 50 sq units; bbox: 10x10 = 100 sq units → 50%
      bbox = BBox.new(%{x: 5, y: 5, w: 10, h: 10})

      polygon =
        Polygon.new([
          %{x: 0, y: 0},
          %{x: 10, y: 0},
          %{x: 10, y: 20},
          %{x: 0, y: 20}
        ])

      assert Colliders.bbox_intersects_polygon?(bbox, polygon)
    end

    test "returns true with concave L-shaped polygon - 75% overlap" do
      # L-shape: bottom rect (x:0-10, y:0-5) + left rect (x:0-5, y:5-10)
      # bbox: x 3-7, y 3-7
      # intersection with bottom: 4x2 = 8 sq units
      # intersection with left:   2x2 = 4 sq units
      # total: 12 out of 16 sq units → 75%
      polygon =
        Polygon.new([
          %{x: 0, y: 0},
          %{x: 10, y: 0},
          %{x: 10, y: 5},
          %{x: 5, y: 5},
          %{x: 5, y: 10},
          %{x: 0, y: 10}
        ])

      bbox = BBox.new(%{x: 3, y: 3, w: 4, h: 4})

      assert Colliders.bbox_intersects_polygon?(bbox, polygon)
    end

    test "real world - car fully in ROI" do
      # bbox fully inside the polygon
      bbox = BBox.new(%{x: 150, y: 80, w: 100, h: 100})

      polygon =
        Polygon.new([
          %{x: 100, y: 50},
          %{x: 300, y: 50},
          %{x: 300, y: 200},
          %{x: 100, y: 200}
        ])

      assert Colliders.bbox_intersects_polygon?(bbox, polygon)
    end

    test "real world - car barely at edge of ROI - ~16.7% overlap" do
      # bbox: x 295-325, y 100-140; polygon: x 100-300, y 50-200
      # intersection: x 295-300, y 100-140 → 5x40 = 200 sq units
      # bbox area: 30x40 = 1200 sq units → 16.7%
      bbox = BBox.new(%{x: 295, y: 100, w: 30, h: 40})

      polygon =
        Polygon.new([
          %{x: 100, y: 50},
          %{x: 300, y: 50},
          %{x: 300, y: 200},
          %{x: 100, y: 200}
        ])

      assert Colliders.bbox_intersects_polygon?(bbox, polygon)
    end
  end

  describe "bbox_overlap_percentage/2" do
    test "returns 100.0 when bbox is fully inside polygon" do
      bbox = BBox.new(%{x: 2, y: 2, w: 4, h: 4})

      polygon =
        Polygon.new([
          %{x: 0, y: 0},
          %{x: 10, y: 0},
          %{x: 10, y: 10},
          %{x: 0, y: 10}
        ])

      assert_in_delta Colliders.bbox_overlap_percentage(bbox, polygon), 100.0, 0.01
    end

    test "returns 0.0 when bbox is completely outside polygon" do
      bbox = BBox.new(%{x: 20, y: 20, w: 5, h: 5})

      polygon =
        Polygon.new([
          %{x: 0, y: 0},
          %{x: 10, y: 0},
          %{x: 10, y: 10},
          %{x: 0, y: 10}
        ])

      assert_in_delta Colliders.bbox_overlap_percentage(bbox, polygon), 0.0, 0.01
    end

    test "returns ~25.0 for one-corner overlap" do
      # bbox: x 8-12, y 8-12; polygon: x 0-10, y 0-10
      # intersection: 2x2 = 4 sq units; bbox: 4x4 = 16 sq units → 25%
      bbox = BBox.new(%{x: 8, y: 8, w: 4, h: 4})

      polygon =
        Polygon.new([
          %{x: 0, y: 0},
          %{x: 10, y: 0},
          %{x: 10, y: 10},
          %{x: 0, y: 10}
        ])

      assert_in_delta Colliders.bbox_overlap_percentage(bbox, polygon), 25.0, 0.1
    end

    test "returns ~50.0 when half of bbox is inside polygon" do
      # bbox: x 5-15, y 0-10; polygon: x 0-10, y 0-10
      # intersection: x 5-10, y 0-10 → 5x10 = 50; bbox: 10x10 = 100 → 50%
      bbox = BBox.new(%{x: 5, y: 0, w: 10, h: 10})

      polygon =
        Polygon.new([
          %{x: 0, y: 0},
          %{x: 10, y: 0},
          %{x: 10, y: 10},
          %{x: 0, y: 10}
        ])

      assert_in_delta Colliders.bbox_overlap_percentage(bbox, polygon), 50.0, 0.1
    end
  end
end
