module View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra
import Types exposing (..)


view : Model -> Html Msg
view { cachedPop, borderCells, genRate, growthRate, age } =
    let
        borderPop =
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
        [ div [] [ text ("Age: " ++ toString age) ]
        , div [] [ text ("Total population: " ++ toString cachedPop) ]
        , div [] [ text ("Border population: " ++ toString borderPop) ]
        , div [] [ text ("Available Spaces: " ++ toString availableSpaces) ]
        , div []
            [ input [ type_ "checkbox", onClick TogglePause ] []
            , text "Pause"
            ]
        , button [ onClick Reset ] [ text "Reset" ]
        , div []
            [ input
                [ type_ "range"
                , onInput ChangeGenRate
                , Html.Attributes.min "30"
                , Html.Attributes.max "1000"
                , Html.Attributes.defaultValue (toString genRate)
                ]
                []
            , text (toString genRate ++ " : Time to generate (ms)")
            ]
        , div []
            [ input
                [ type_ "range"
                , onInput ChangeGrowthRate
                , Html.Attributes.min "1"
                , Html.Attributes.max "20"
                , Html.Attributes.defaultValue (toString growthRate)
                ]
                []
            , text (toString growthRate ++ "% of total number of cells grown per generation")
            ]
        ]
