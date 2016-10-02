module RestDojo.Games.Cluedo.GameDontCheat exposing (tileDescriptor, Model, Msg, update, view)

import Html exposing (Html, text, div, span, button, img)
import Html.Attributes exposing (disabled, title, src, width, height)
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
    , weapons = []
    , suspects = []
    , locations = []
  }

--UPDATE----------------------------------------------------------------------------------------------------------------
type Msg =
  StartGame
  | Shuffled (Randomness, List Card)
  | BotJoinSucceed BotId String
  | BotJoinFail BotId Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case Debug.log "Dont cheat" msg of
    StartGame ->
      {model
        | started = True
        , bots = List.map (\bot -> {bot | state = WaitingToJoin}) model.bots}
      ! [Random.generate Shuffled gameGenerator]

    Shuffled (randomness, cards) ->
      {model
        | gameId = Just randomness.gameId
        , secret = Just randomness.secret}
      ! List.map (startBot randomness.gameId) model.bots

    BotJoinSucceed botId result ->
      let
        updater bot = {bot | state = Joined, description = result}
      in
        (updateBot model botId updater) ! []

    BotJoinFail botId reason ->
      let
        updater bot = {bot | state = JoinFailed (toString reason)}
      in
        (updateBot model botId updater) ! []

updateBot : Model -> Int -> (Bot -> Bot) -> Model
updateBot model botId updater =
      {model | bots = List.map (\bot -> if (bot.id == botId) then (updater bot) else bot) model.bots}

startBot : GameId -> Bot -> Cmd Msg
startBot gameId bot =
      Task.perform (BotJoinFail bot.id) (BotJoinSucceed bot.id) (API.startGame gameId bot)

--VIEW------------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =
  div [] [
    button [onClick StartGame, disabled model.started] [text "Start"]
    , div [] [viewSecret model.secret]
    , div [] <| List.map viewBotCard model.bots
  ]

viewSecret : Maybe Secret -> Html Msg
viewSecret maybeSecret =
  case maybeSecret of
    Nothing ->
      viewSecretCards "None" "None" "None"
    Just secret ->
        viewSecretCards (toString secret.suspect) (toString secret.location) (toString secret.weapon)

viewSecretCards : String -> String -> String -> Html Msg
viewSecretCards suspectName weaponName locationName =
    span [] [
      viewCard suspectName
      , viewCard weaponName
      , viewCard locationName
    ]

viewCard : String -> Html Msg
viewCard name =
  img [src <| "img/" ++ name ++ ".png", width 80, height 100, title name] []

viewBots : List Bot -> Html Msg
viewBots bots =
    div [] <| List.map viewBot bots

viewBot : Bot -> Html Msg
viewBot bot =
  div [] [
    viewBotCard bot
    , text (bot.url ++ ", " ++ bot.description ++ "    :    " ++ (toString bot.state))
    ]

viewBotCard : Bot -> Html Msg
viewBotCard bot =
    let
      botImg = img [src <| "https://robohash.org/" ++ bot.url, width 80, height 80] []
      weaponCards = List.map (\w -> viewCard <| toString w) bot.weapons
      suspectCards = List.map (\w -> viewCard <| toString w) bot.suspects
      locationCards = List.map (\w -> viewCard <| toString w) bot.locations
    in
      span [] ([botImg] ++ weaponCards ++ suspectCards ++ locationCards)
