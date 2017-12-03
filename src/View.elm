module View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra
import Types exposing (..)


view : Model -> Html Msg
view { cachedPop, borderCells } =
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
        [ div [] [ text ("Total population: " ++ toString cachedPop) ]
        , div [] [ text ("Border population: " ++ toString borderPop) ]
        , div [] [ text ("Available Spaces: " ++ toString availableSpaces) ]
        , div []
            [ input [ type_ "checkbox", onClick TogglePause ] []
            , text "Pause"
            ]
        ]
