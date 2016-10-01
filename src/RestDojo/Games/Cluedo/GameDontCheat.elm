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
        init = initModel [Player 0 "http://localhost:3001"] ! [],
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
      | Joined
      | JoinFailed String

type alias BotId = Int

type alias Bot = {
    id : BotId
    , url : String
    , description : String
    , state : State
  }


type alias Model = {
  started: Bool
  , bots: List Bot
 }

initModel : List Player -> Model
initModel players = {
  started = False
  , bots = List.map (\p -> Bot p.id p.url "" None) players
 }

--UPDATE----------------------------------------------------------------------------------------------------------------
type Msg =
  StartGame
  | StartGameSucceed BotId String
  | StartGameFail BotId Http.Error

currentGameId : GameId
currentGameId =
  78245789

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case Debug.log "Dont cheat" msg of
    StartGame ->
      {model
        | started = True
        , bots = List.map (\bot -> {bot | state = WaitingToJoin}) model.bots}
      ! List.map startGame model.bots

    StartGameSucceed botId result ->
      let
        updater bot = {bot | state = Joined, description = result}
      in
        (updateBot model botId updater) ! []

    StartGameFail botId reason ->
      let
        updater bot = {bot | state = JoinFailed (toString reason)}
      in
        (updateBot model botId updater) ! []

updateBot : Model -> Int -> (Bot -> Bot) -> Model
updateBot model botId updater =
      {model | bots = List.map (\bot -> if (bot.id == botId) then (updater bot) else bot) model.bots}

startGame : Bot -> Cmd Msg
startGame bot =
      Task.perform (StartGameFail bot.id) (StartGameSucceed bot.id) (API.startGame currentGameId bot.url)

--VIEW------------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =
  div [] [
    button [onClick StartGame, disabled model.started] [text "Start"],
    div [] (List.map viewBot model.bots)
  ]

viewBot : Bot -> Html Msg
viewBot bot =
  div [] [text (bot.url ++ ", " ++ bot.description ++ "    :    " ++ (toString bot.state))]
