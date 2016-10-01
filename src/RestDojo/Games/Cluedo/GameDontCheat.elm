module RestDojo.Games.Cluedo.GameDontCheat exposing (tileDescriptor, Model, Msg, update, view)

import Html exposing (Html, text, div, button)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick)
import Html.App
import Http
import Task

import RestDojo.Types exposing (..)
import RestDojo.Games.Cluedo.API  as API exposing (..)

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Program Never
main =
      Html.App.program {
        init = initModel [Player 0 "http://localhost:3001", Player 1 "http://localhost:3003"] ! [],
        update = update,
        view = view,
        subscriptions = \_ -> Sub.none}

--PUBLIC ---------------------------------------------------------------------------------------------------------------
tileDescriptor : (Model -> a) -> TileDescriptor a
tileDescriptor modelWrapper = {
  title = "Don't cheat",
  isDisabled = List.isEmpty,
  initGame = \players -> modelWrapper (initModel players)
 }

--MODEL-----------------------------------------------------------------------------------------------------------------
type State = None
      | WaitingToJoin
      | Joined Player String
      | JoinFailed Player Http.Error

type alias Model = {
  started: Bool
  , playerStates: List (Player, State)
 }

initModel : List Player -> Model
initModel players = {
  started = False
  , playerStates = List.map (\p -> (p, None)) players
 }

--UPDATE----------------------------------------------------------------------------------------------------------------
type Msg =
  StartGame
  | StartGameSucceed Player String
  | StartGameFail Player Http.Error

currentGameId : GameId
currentGameId =
  78245789

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    StartGame ->
      {model
        | started = True
        , playerStates = List.map (\(p, _) -> (p, WaitingToJoin)) model.playerStates}
      ! List.map startGame model.playerStates

    _  ->
      model ! []

startGame : (Player, State) -> Cmd Msg
startGame (player, _) =
    let
      url = API.startGame currentGameId player
    in
      Task.perform (StartGameFail player) (StartGameSucceed player) (Http.getString url)

--VIEW------------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =
  div [] [
    button [onClick StartGame, disabled model.started] [text "Start"],
    div [] (List.map viewPlayer model.playerStates)
  ]

viewPlayer : (Player, State) -> Html Msg
viewPlayer (player, state) =
  div [] [text (player.url ++ "    :    " ++ (toString state))]
