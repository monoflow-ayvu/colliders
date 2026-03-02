# Colliders

An Elixir library for detecting whether a bounding box (bbox) meaningfully overlaps a polygon. Designed for use cases such as checking if an AI model detection (a bbox) falls within a region of interest (a polygon).

A detection is considered a hit only when the overlap meets a configurable minimum threshold (default: **5%**).

## How It Works

Colliders uses a two-phase approach for both correctness and performance:

1. **Axis-Aligned Bounding Box (AABB) filter** — Compares the bbox against the polygon's precomputed axis-aligned bounding box. If the bbox is entirely outside it, `false` is returned immediately without any further computation.

2. **Sutherland-Hodgman clipping** — If the AABB check passes, the polygon is clipped to the bbox using the [Sutherland-Hodgman algorithm](https://en.wikipedia.org/wiki/Sutherland%E2%80%93Hodgman_algorithm). The area of the resulting intersection polygon is then compared to the bbox area to compute the overlap percentage.

## Installation

Add `colliders` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:colliders, "~> 0.1.0"}
  ]
end
```

Then fetch dependencies:

```bash
mix deps.get
```

## Usage

### 1. Define your polygon

Use `Colliders.Polygon.new/2` to create a prepared polygon. This precomputes the polygon's bounding box bounds once, so repeated checks against it are fast.

The points list accepts `%PolygonPoint{}` structs, maps with `x`/`y` keys, or `{x, y}` tuples.

```elixir
alias Colliders.Polygon
alias Colliders.Types.PolygonPoint

polygon =
  Polygon.new([
    %PolygonPoint{x: 100, y: 50},
    %PolygonPoint{x: 300, y: 50},
    %PolygonPoint{x: 300, y: 200},
    %PolygonPoint{x: 100, y: 200}
  ])
```

You can also attach arbitrary metadata to a polygon (e.g. an ID or label):

```elixir
polygon = Polygon.new(points, %{id: "zone_a", label: "Entrance"})
```

### 2. Check if a bounding box hits the polygon

```elixir
alias Colliders
alias Colliders.Types.BBox

# A detection bbox: x/y is the top-left corner, w/h are width and height
bbox = %BBox{x: 295, y: 100, w: 30, h: 40}

Colliders.bbox_intersects_polygon?(bbox, polygon)
# => true
```

The default threshold is **5%** — the bbox must overlap at least 5% of its own area with the polygon to return `true`.

### 3. Custom threshold

```elixir
# Require at least 50% of the bbox to be inside the polygon
Colliders.bbox_intersects_polygon?(bbox, polygon, 50.0)
```

### 4. Get the exact overlap percentage

```elixir
Colliders.bbox_overlap_percentage(bbox, polygon)
# => 16.666...
```

Returns a float between `0.0` (no overlap) and `100.0` (bbox fully inside polygon).

## Types

### `%Colliders.Types.PolygonPoint{}`

A vertex in a polygon.

| Field | Type | Description |
|-------|------|-------------|
| `x`   | `float \| integer` | Horizontal coordinate |
| `y`   | `float \| integer` | Vertical coordinate |

### `%Colliders.Types.BBox{}`

An axis-aligned bounding box. `x` and `y` are the **top-left corner**.

| Field | Type | Description |
|-------|------|-------------|
| `x`   | `float \| integer` | Left edge |
| `y`   | `float \| integer` | Top edge |
| `w`   | `float \| integer` | Width |
| `h`   | `float \| integer` | Height |

### `%Colliders.Polygon{}`

A prepared polygon. Create it with `Colliders.Polygon.new/1` — do **not** build the struct manually, as the precomputed AABB bounds (`min_x`, `max_x`, `min_y`, `max_y`) will be missing.

| Field | Type | Description |
|-------|------|-------------|
| `points` | `[PolygonPoint.t()]` | Polygon vertices |
| `meta`   | `map()` | Arbitrary metadata |
| `min_x`  | `float \| integer` | Precomputed left bound |
| `max_x`  | `float \| integer` | Precomputed right bound |
| `min_y`  | `float \| integer` | Precomputed top bound |
| `max_y`  | `float \| integer` | Precomputed bottom bound |

## API

### `Colliders.bbox_intersects_polygon?(bbox, polygon, threshold \\ 5.0)`

Returns `true` if at least `threshold`% of the bbox area overlaps the polygon.

### `Colliders.bbox_overlap_percentage(bbox, polygon)`

Returns the percentage of the bbox area that overlaps the polygon, as a float between `0.0` and `100.0`.

### `Colliders.Polygon.new(points, meta \\ %{})`

Creates a `%Polygon{}` struct, precomputing its AABB bounds. Raises `ArgumentError` if fewer than 3 points are given.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b my-feature`)
3. Write tests for your changes
4. Make sure all tests pass (`mix test`)
5. Open a pull request

## License

See [LICENSE](LICENSE) for details.
