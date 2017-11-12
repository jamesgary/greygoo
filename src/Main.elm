port module Main exposing (..)

import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)


port initOutline : List Pos -> Cmd msg


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }


type alias Model =
    { outline : Outline }


type alias Outline =
    List Cell


type alias Cell =
    { pos : Pos
    , state : CellState
    , north : CellState
    , east : CellState
    , south : CellState
    , west : CellState
    }


type CellState
    = Empty
    | BorderCell
    | InnerCell


type alias Pos =
    { x : Int, y : Int }


init : ( Model, Cmd Msg )
init =
    let
        outline =
            [ { pos = Pos 4 4
              , state = BorderCell
              , north = Empty
              , east = Empty
              , south = Empty
              , west = Empty
              }
            ]
    in
    ( { outline = outline
      }
    , outline
        |> List.map .pos
        |> initOutline
    )



---- UPDATE ----


type Msg
    = Tick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [] [ text "Your Elm App is working!" ]
