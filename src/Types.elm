module Types exposing (..)

import Dict exposing (Dict)
import Random
import Time


type alias Model =
    { borderCells : Dict Pt Cell
    , cachedPop : Int
    , cachedPopGainRate : Int
    , ageLastGrown : Time.Time
    , seed : Random.Seed
    , paused : Bool
    , age : Time.Time
    , growthRate : Float
    , genRate : Time.Time
    }


type alias Cell =
    { pt : Pt
    , emptyNeighbors : List Pt
    }


type alias Pt =
    ( Int, Int )


type Msg
    = Tick Time.Time
    | Step
    | Reset
    | TogglePause
    | ChangeGrowthRate String
    | ChangeGenRate String
