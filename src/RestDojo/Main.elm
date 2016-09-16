module RestDojo.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, value, disabled)
import Html.Events exposing (onClick, on, targetValue)
import Html.App

import Json.Decode as Json

import RestDojo.Types exposing (..)
import RestDojo.Games.GameIntroduceYourself as Game1

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Program Never
main =
      Html.App.beginnerProgram {
        model = initModel,
        update = update,
        view = view}

-- PORTS ---------------------------------------------------------------------------------------------------------------
{-
type Request =
  -- NoRequest
  -- |
     GetName

requests : Mailbox Request
requests = mailbox GetName

port backend : Signal (Task String String)
port backend =
  Signal.map apiCall requests.signal

apiCall : Request -> Task String String
apiCall req =
  case req of
    -- NoRequest -> succeed ""
    GetName -> Http.getString "http://localhost:3001/namea" |> mapError (\err -> "Wrong")
          -- `andThen` (\result -> Signal.send box.address (EditNewPlayerUrl (getResult result)))
          `andThen` (\task -> Signal.send box.address (EditNewPlayerUrl "asd"))

getResult : Result String String -> String
getResult res =
  case res of
    Ok name -> name
    Err error -> error
-}
-- MODEL ---------------------------------------------------------------------------------------------------------------
type GameModel =
  IntroGameModel Game1.Model

type alias Game = GameDescriptor GameModel

allGames : List Game
allGames = [
  Game1.gameDescriptor IntroGameModel
 ]

type Screen  =
  MainScreen
  | GameScreen (Game, GameModel)

type alias Model = {
  nextId : Int,
  playerUrl: String,
  players: List Player,
  screen: Screen
}

initModel : Model
initModel = {
  nextId = 2,
  playerUrl = "",
  players = [Player 0 "http://localhost:3001", Player 1 "http://localhost:3002"],
  screen = MainScreen
 }

-- UPDATE --------------------------------------------------------------------------------------------------------------
type Msg =
  NoOp
  | EditNewPlayerUrl String
  | AddPlayer
  | RemovePlayer Int
  | SelectGame Game
  | BackToMain
  | PlayIntroGame Game Game1.Model Game1.Msg

update : Msg -> Model -> Model
update msg model =
  case msg of
    NoOp -> model
    EditNewPlayerUrl url -> {model | playerUrl = url}
    AddPlayer -> {model | players =  (Player model.nextId model.playerUrl) :: model.players
                        , playerUrl = ""
                        , nextId = model.nextId + 1}
    RemovePlayer id -> {model | players = List.filter (\p -> p.id /= id) model.players}
    SelectGame game                       -> {model | screen = GameScreen (game, game.initModel model.players)}
    PlayIntroGame game gameModel action'  -> {model | screen = GameScreen (game, IntroGameModel (Game1.update action' gameModel))}
    BackToMain                            -> {model | screen = MainScreen }

-- VIEW ----------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =
  case model.screen of
    MainScreen -> viewMainScreen model
    GameScreen (game, gameModel) -> viewGameScreen game gameModel

viewMainScreen : Model -> Html Msg
viewMainScreen model =
    div [] [
        div [] (List.map (\player -> div [] [text player.url, button [onClick (RemovePlayer player.id)] [text "Remove"]]) model.players),
        input [placeholder "URL", value model.playerUrl, on "input" (Json.map EditNewPlayerUrl targetValue)] [],
        button [onClick AddPlayer] [text "Add"],
        hr [] [],
        div [] (List.map (viewTile model) allGames)
    ]

viewTile : Model -> Game -> Html Msg
viewTile model game =
    button [onClick (SelectGame game), disabled (game.isDisabled model.players)] [text game.title]

viewGameScreen : Game -> GameModel -> Html Msg
viewGameScreen game gameModel =
  div [] [
    button [onClick BackToMain] [text "Back"],
    span [] [text game.title],
    hr [] [],
    viewGame game gameModel
  ]

viewGame : Game -> GameModel -> Html Msg
viewGame game gameModel =
  case gameModel of
    IntroGameModel model -> Html.App.map (PlayIntroGame game model) (Game1.view model)
