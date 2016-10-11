module RestDojo.Games.Cluedo.GameDontCheat exposing (tileDescriptor, Model, Msg, update, view)

import Html exposing (Html, text, div, span, button, img)
import Html.Attributes exposing (disabled, title, src, width, height)
import Html.Events exposing (onClick)
import Html.App
import Http
import Task
import Random exposing (Generator)

import RestDojo.Util exposing (zipAsLongest)
import RestDojo.Types exposing (..)
import RestDojo.Games.Cluedo.API as API exposing (..)

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Program Never
main =
      Html.App.program {
        init = initModel [
          Player 0 "http://localhost:3001"
          , Player 1 "http://localhost:3002"
          , Player 2 "http://localhost:3003"
          -- , Player 3 "http://localhost:3004"
          -- , Player 4 "http://localhost:3005"
          -- , Player 5 "http://localhost:3006"
          ] ! [],
        update = update,
        view = view,
        subscriptions = \_ -> Sub.none}

--PUBLIC ---------------------------------------------------------------------------------------------------------------
tileDescriptor : (Model -> a) -> TileDescriptor a
tileDescriptor modelWrapper = {
  title = "Cluedo",
  isDisabled = List.isEmpty,
  initGame = \players -> modelWrapper (initModel players)
 }

--MODEL-----------------------------------------------------------------------------------------------------------------
type alias Round = {
  nr : Int
  , askedby : PlayerId
  , question : Question
  , answers : List (PlayerId, Maybe Card)
  }

type alias Model = {
  started : Bool
  , gameId : Maybe GameId
  , secret : Maybe Secret
  , bots : List Bot
  , countAckBots : Int
  , nextRoundNr : Int
  , rounds : List Round
  }

initModel : List Player -> Model
initModel players = {
  started = False
  , gameId = Nothing
  , secret = Nothing
  , bots = List.map initBot players
  , countAckBots = 0
  , nextRoundNr = 0
  , rounds = []
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
  | BotGaveAnswer BotId String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case Debug.log "Cluedo update" msg of
    StartGame ->
      {model
        | started = True
        , bots = List.map (\bot -> {bot | state = WaitingToJoin}) model.bots}
      ! [Random.generate Shuffled gameGenerator]

    Shuffled (randomness, cards) ->
      let
        botIds = List.map (\bot -> bot.id) model.bots
        botIdsAndCards = zipAsLongest botIds cards

        addCardToBot bot card =
          case card of
              WeaponCard weapon -> { bot | weapons = weapon :: bot.weapons}
              SuspectCard suspect -> { bot | suspects = suspect :: bot.suspects}
              LocationCard location -> { bot | locations = location :: bot.locations}

        findBotAndAddCard (botId, card) bots =
          List.map (\bot -> if (bot.id == botId) then (addCardToBot bot card) else bot) bots

        updatedModel = {model
          | gameId = Just randomness.gameId
          , secret = Just randomness.secret
          , bots = List.foldl (findBotAndAddCard) model.bots botIdsAndCards}
      in
        updatedModel ! List.map (startBot randomness.gameId) updatedModel.bots

    BotJoinSucceed botId result ->
        let
          updatedModel = updateBot model botId (\bot -> {bot | state = Joined, description = result})
          newModel = {updatedModel | countAckBots = updatedModel.countAckBots + 1 }
          newCmds = if newModel.countAckBots == List.length newModel.bots
            then [waitBotToAnswer (Maybe.withDefault 0 model.gameId) "http://localhost:3001"]
            else []
        in
          newModel ! newCmds

    BotGaveAnswer botId result ->
        model ! []

    BotJoinFail botId reason ->
        (updateBot model botId (\bot -> {bot | state = JoinFailed (toString reason)})) ! []

updateBot : Model -> Int -> (Bot -> Bot) -> Model
updateBot model botId updater =
      {model | bots = List.map (\bot -> if (bot.id == botId) then (updater bot) else bot) model.bots}

startBot : GameId -> Bot -> Cmd Msg
startBot gameId bot =
      Task.perform (BotJoinFail bot.id) (BotJoinSucceed bot.id) (API.startGame gameId bot)

waitBotToAnswer : GameId -> String -> Cmd Msg
waitBotToAnswer gameId botUrl =
      let
        question = { weapon = Revolver, location = Kitchen, suspect = RevGreen}
      in
        Task.perform (BotJoinFail 0) (BotGaveAnswer 0) (API.giveAnswer gameId botUrl Interrogation question)

--VIEW------------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =
  div [] [
    button [onClick StartGame, disabled model.started] [text "Start"]
    , div [] [viewSecret model.secret]
    , div [] <| List.map viewBot model.bots
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
viewCard =
  viewCardWithSize 144 180

viewCardSmall : String -> Html Msg
viewCardSmall =
  viewCardWithSize 80 100

viewCardWithSize : Int -> Int -> String -> Html Msg
viewCardWithSize w h name =
  img [src <| "img/" ++ name ++ ".png", width w, height h, title name] []

viewBot : Bot -> Html Msg
viewBot bot =
    let
      botImg = img [src <| "https://robohash.org/" ++ bot.url, width 80, height 80] []
      toCard a = if (bot.state == Joined) then toString a else "None"
      cards = List.map (\w -> viewCardSmall <| toCard w)
    in
      span [] <| [botImg] ++ (cards bot.suspects)  ++ (cards bot.locations) ++ (cards bot.weapons)
