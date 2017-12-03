module Types exposing (..)

import Dict exposing (Dict)
import Random
import Time


type alias Model =
    { borderCells : Dict Pt Cell
    , seed : Random.Seed
    }


type alias Cell =
    { pt : Pt
    , emptyNeighbors : List Pt
    }


type CellState
    = Empty
    | BorderCell
    | InnerCell


type alias Pt =
    ( Int, Int )


type Msg
    = Tick Time.Time
