module RestDojo.Games.Cluedo.GameDontCheat exposing (tileDescriptor, Model, Msg, update, view)

import Html exposing (Html, text, div, span, button, img)
import Html.Attributes exposing (disabled, src, width, height)
import Html.Events exposing (onClick)
import Html.App
import Http
import Task
import Random exposing (Generator)

import RestDojo.Types exposing (..)
import RestDojo.Games.Cluedo.API as API exposing (..)

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
type alias Secret = {
  weapon: Weapon
  , location: Location
  , suspect: Suspect
  }

type alias Model = {
  started : Bool
  , gameId : Maybe GameId
  , secret : Maybe Secret
  , bots : List Bot
  }

initModel : List Player -> Model
initModel players = {
  started = False
  , gameId = Nothing
  , secret = Nothing
  , bots = List.map initBot players
 }

initBot : Player -> Bot
initBot player = {
    id =  player.id
    , url = player.url
    , description = ""
    , state = None
    , weapons = [Revolver, Rope]
    , suspects = [RevGreen, MrsWhite]
    , locations = [Kitchen, BallRoom, Hall]
  }

--UPDATE----------------------------------------------------------------------------------------------------------------
type Msg =
  StartGame
  | Shuffled Randomness
  | BotStartGameSucceed BotId String
  | BotStartGameFail BotId Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case Debug.log "Dont cheat" msg of
    StartGame ->
      {model
        | started = True
        , bots = List.map (\bot -> {bot | state = WaitingToJoin}) model.bots}
      ! [Random.generate Shuffled gameGenerator]

    Shuffled randomness ->
      {model
        | gameId = Just randomness.gameId
        , secret = Just {weapon = randomness.weapon, location = randomness.location, suspect = randomness.suspect}}
      ! List.map (startBot randomness.gameId) model.bots

    BotStartGameSucceed botId result ->
      let
        updater bot = {bot | state = Joined, description = result}
      in
        (updateBot model botId updater) ! []

    BotStartGameFail botId reason ->
      let
        updater bot = {bot | state = JoinFailed (toString reason)}
      in
        (updateBot model botId updater) ! []

updateBot : Model -> Int -> (Bot -> Bot) -> Model
updateBot model botId updater =
      {model | bots = List.map (\bot -> if (bot.id == botId) then (updater bot) else bot) model.bots}

startBot : GameId -> Bot -> Cmd Msg
startBot gameId bot =
      Task.perform (BotStartGameFail bot.id) (BotStartGameSucceed bot.id) (API.startGame gameId bot)

--VIEW------------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =
  div [] [
    button [onClick StartGame, disabled model.started] [text "Start"]
    , viewSecret model.secret
    , div [] (List.map viewBot model.bots)
  ]

viewSecret : Maybe Secret -> Html Msg
viewSecret maybeSecret =
  case maybeSecret of
    Nothing -> div [] [text "? ? ?"]
    Just secret ->
        div [] [
          span [] [
            img [src <| "img/" ++ (toString secret.suspect) ++ ".png", width 80, height 125] []
            , text (toString secret.location)
            , text (toString secret.weapon)
            ]
        ]

viewBot : Bot -> Html Msg
viewBot bot =
  div [] [
    img [src <| "https://robohash.org/" ++ bot.url, width 80, height 80] []
    , text (bot.url ++ ", " ++ bot.description ++ "    :    " ++ (toString bot.state))
    ]
