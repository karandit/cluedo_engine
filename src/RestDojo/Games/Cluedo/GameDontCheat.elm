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
  title = "Cluedo",
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
  case msg of
    StartGame ->
      {model
        | started = True
        , bots = List.map (\bot -> {bot | state = WaitingToJoin}) model.bots}
      ! [Random.generate Shuffled gameGenerator]

    Shuffled (randomness, cards) ->
      let
        botIds = List.map (\bot -> bot.id) model.bots
        botIdsAndCards = zipToLongest botIds cards

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
        (updateBot model botId (\bot -> {bot | state = Joined, description = result})) ! []

    BotJoinFail botId reason ->
        (updateBot model botId (\bot -> {bot | state = JoinFailed (toString reason)})) ! []

zipToLongest : List Int -> List Card -> List (Int, Card)
zipToLongest botIds cards =
    zipToLongestH [] botIds botIds cards

zipToLongestH : List (a, b) -> List a -> List a -> List b -> List (a, b)
zipToLongestH acc origShorter shorter longer =
  case longer of
    l::ls ->
        case shorter of
          s::ss -> zipToLongestH ((s, l) :: acc) origShorter ss ls
          []  -> zipToLongestH acc origShorter origShorter longer
    [] -> acc

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
  img [src <| "img/" ++ name ++ ".png", width 144, height 180, title name] []

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
      botImg = img [src <| "https://robohash.org/" ++ bot.url, width 144, height 144] []
      suspectCards = List.map (\w -> viewCard <| toString w) bot.suspects
      weaponCards = List.map (\w -> viewCard <| toString w) bot.weapons
      locationCards = List.map (\w -> viewCard <| toString w) bot.locations
    in
      span [] ([botImg] ++ suspectCards  ++ locationCards ++ weaponCards)
