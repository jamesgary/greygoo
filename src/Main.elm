port module Main exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, div, h1, img, text)
import List.Extra
import Random
import Random.List
import Time
import Types exposing (..)


port initBorder : List Pt -> Cmd msg


port drawNewCells : List Pt -> Cmd msg


width =
    100


heigth =
    100


genesisPt =
    ( 50, 50 )


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Time.every Time.second Tick
        }


init : ( Model, Cmd Msg )
init =
    { borderCells =
        Dict.fromList
            [ ( genesisPt
              , { pt = genesisPt
                , emptyNeighbors = getNeighborPts genesisPt
                }
              )
            ]
    , seed = Random.initialSeed 420
    }
        ! [ drawNewCells [ genesisPt ] ]


allDirs : List Dir
allDirs =
    [ North, East, South, West ]


randomDirGen : Random.Generator Dir
randomDirGen =
    Random.map
        (\n ->
            case n of
                0 ->
                    North

                1 ->
                    East

                2 ->
                    South

                _ ->
                    West
        )
        (Random.int 0 3)


ptWithDir : Pt -> Dir -> Pt
ptWithDir ( x, y ) dir =
    case dir of
        North ->
            ( x, y - 1 )

        East ->
            ( x + 1, y )

        South ->
            ( x, y + 1 )

        West ->
            ( x - 1, y )


getNeighborPts : Pt -> List Pt
getNeighborPts ( x, y ) =
    [ ( x, y - 1 )
    , ( x + 1, y )
    , ( x, y + 1 )
    , ( x - 1, y )
    ]



---- UPDATE ----


type Msg
    = Tick Time.Time


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
    div []
        [ div [] [ text ("Population: " ++ toString (Dict.size borderCells)) ]
        ]
