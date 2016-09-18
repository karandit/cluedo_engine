module RestDojo.Games.Cluedo.GameDontCheat exposing (gameDescriptor, Model, Msg, update, view)

import Html exposing (Html, text, div)
import Html.App

import RestDojo.Types exposing (..)

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Program Never
main =
      Html.App.program {
        init = initModel [Player 0 "http://localhost:3001", Player 1 "http://localhost:3003"] ! [],
        update = update,
        view = view,
        subscriptions = \_ -> Sub.none}

--PUBLIC ---------------------------------------------------------------------------------------------------------------
gameDescriptor : (Model -> a) -> GameDescriptor a
gameDescriptor modelWrapper = {
  title = "Don't cheat",
  isDisabled = \players -> List.isEmpty players,
  initModel = \players -> modelWrapper (initModel players)
 }

--MODEL-----------------------------------------------------------------------------------------------------------------
type alias Model = {
  started: Bool
  , players: List Player
 }

initModel : List Player -> Model
initModel players = {
  started = False
  , players = players
 }
--UPDATE----------------------------------------------------------------------------------------------------------------
type Msg =
  NotYet

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    model ! []

--VIEW------------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =
  div [] [
    div [] (List.map viewPlayer model.players)
  ]

viewPlayer : Player -> Html Msg
viewPlayer player =
  div [] [text player.url]
