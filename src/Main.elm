port module Main exposing (..)

import AnimationFrame
import Dict exposing (Dict)
import Html exposing (Html, div, h1, img, text)
import List.Extra
import Random
import Random.List
import Time
import Types exposing (..)
import View exposing (view)


port drawNewCells : List Pt -> Cmd msg


width =
    100


height =
    100


genesisPt =
    ( 50, 50 )


main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


init : Int -> ( Model, Cmd Msg )
init seed =
    { borderCells =
        Dict.fromList
            [ ( genesisPt
              , { pt = genesisPt
                , emptyNeighbors = getNeighborPts genesisPt
                }
              )
            ]
    , cachedPop = 1
    , seed = Random.initialSeed seed
    , paused = False
    }
        ! [ drawNewCells [ genesisPt ] ]


getNeighborPts : Pt -> List Pt
getNeighborPts ( x, y ) =
    [ if x > 0 then
        Just ( x - 1, y )
      else
        Nothing
    , if x + 1 < width then
        Just ( x + 1, y )
      else
        Nothing
    , if y > 0 then
        Just ( x, y - 1 )
      else
        Nothing
    , if y + 1 < height then
        Just ( x, y + 1 )
      else
        Nothing
    ]
        |> List.filterMap identity


numPtsToGrow : Int -> Int
numPtsToGrow population =
    --max 1 (population // 10)
    1


takeRandomly : Int -> List a -> Random.Seed -> ( List a, Random.Seed )
takeRandomly amt list seed =
    Random.step
        (Random.List.shuffle list
            |> Random.map (List.take amt)
        )
        seed


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ borderCells, cachedPop, seed, paused } as model) =
    case msg of
        Tick timeDelta ->
            let
                growablePts =
                    borderCells
                        |> Dict.values
                        |> List.map .emptyNeighbors
                        |> List.concat
                        |> List.Extra.unique

                ( ptsToGrow, newSeed ) =
                    takeRandomly (numPtsToGrow cachedPop) growablePts seed

                newBorderCells =
                    ptsToGrow
                        |> List.foldl
                            (\pt cells ->
                                Dict.insert pt
                                    { pt = pt
                                    , emptyNeighbors =
                                        keepIfNotIn (getNeighborPts pt) borderCells
                                    }
                                    cells
                            )
                            borderCells

                -- now remove not-really-empty neighbors
                newerBorderCells =
                    newBorderCells
                        |> Dict.map
                            (\pt ({ emptyNeighbors } as cell) ->
                                { cell
                                    | emptyNeighbors =
                                        keepIfNotIn emptyNeighbors newBorderCells
                                }
                            )
                        -- remove not-really-empty neighbors
                        |> Dict.filter (\pt { emptyNeighbors } -> not (List.isEmpty emptyNeighbors))
            in
            { model
                | seed = newSeed
                , borderCells = newerBorderCells
                , cachedPop = cachedPop + List.length ptsToGrow
            }
                ! [ drawNewCells ptsToGrow ]

        TogglePause ->
            { model | paused = not paused } ! []


keepIfNotIn : List Pt -> Dict Pt Cell -> List Pt
keepIfNotIn pts cells =
    List.Extra.filterNot (\pt -> Dict.member pt cells) pts


subscriptions : Model -> Sub Msg
subscriptions { paused } =
    if paused then
        Sub.none
    else
        --Time.every (Time.second * secMod) Tick
        AnimationFrame.diffs Tick
