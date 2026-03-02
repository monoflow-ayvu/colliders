defmodule Colliders.Types do
  defmodule PolygonPoint do
    defstruct x: 0.0, y: 0.0

    @type t() :: %__MODULE__{
            x: float() | integer(),
            y: float() | integer()
          }
  end

  defmodule BBox do
    defstruct x: 0.0, y: 0.0, w: 0.0, h: 0.0

    @type t() :: %__MODULE__{
            x: float() | integer(),
            y: float() | integer(),
            w: float() | integer(),
            h: float() | integer()
          }
  end
end
