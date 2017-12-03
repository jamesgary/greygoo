port module Main exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, div, h1, img, text)
import List.Extra
import Random
import Random.List
import Time
import Types exposing (..)


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
        , subscriptions = \_ -> Time.every (Time.second * 0.1) Tick
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
    , seed = Random.initialSeed seed
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
    max 1 (population // 10)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ borderCells, seed } as model) =
    case msg of
        Tick _ ->
            let
                growablePts =
                    borderCells
                        |> Dict.values
                        |> List.map .emptyNeighbors
                        |> List.concat
                        |> List.Extra.unique

                ( ptsToGrow, newSeed ) =
                    Random.step
                        (Random.List.shuffle growablePts
                            |> Random.map (List.take (numPtsToGrow (Dict.size borderCells)))
                        )
                        seed

                newBorderCells =
                    ptsToGrow
                        |> List.foldl
                            (\pt cells ->
                                let
                                    emptyNeighbors =
                                        getNeighborPts pt
                                in
                                Dict.insert pt
                                    { pt = pt
                                    , emptyNeighbors =
                                        keepIfNotIn emptyNeighbors (Dict.keys borderCells)
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
                                        keepIfNotIn emptyNeighbors (Dict.keys newBorderCells)
                                }
                            )
                        -- remove not-really-empty neighbors
                        |> Dict.filter (\pt { emptyNeighbors } -> not (List.isEmpty emptyNeighbors))
            in
            ( { model
                | seed = newSeed
                , borderCells = newerBorderCells
              }
            , drawNewCells ptsToGrow
            )


keepIfNotIn : List a -> List a -> List a
keepIfNotIn xs ys =
    List.Extra.filterNot (\x -> List.member x ys) xs



---- VIEW ----


view : Model -> Html Msg
view { borderCells } =
    let
        pop =
            borderCells
                |> Dict.size

        availableSpaces =
            borderCells
                |> Dict.values
                |> List.map .emptyNeighbors
                |> List.Extra.unique
                |> List.length
    in
    div []
        [ div [] [ text ("Border population: " ++ toString pop) ]
        , div [] [ text ("Available Spaces: " ++ toString availableSpaces) ]
        ]
