module RestDojo.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, value, disabled)
import Html.Events exposing (onClick, on, targetValue)
import Html.App

import Json.Decode as Json

import RestDojo.Types exposing (..)
import RestDojo.Games.GameIntroduceYourself as Game1
import RestDojo.Games.Cluedo.GameDontCheat as Game2

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Program Never
main =
      Html.App.program {
        init = initModel,
        update = update,
        view = view,
        subscriptions = \_ -> Sub.none}

-- MODEL ---------------------------------------------------------------------------------------------------------------
type GameModel =
  IntroGameModel Game1.Model
  | DontCheatGameModel Game2.Model

type alias Game = GameDescriptor GameModel

allGames : List Game
allGames = [
  Game1.gameDescriptor IntroGameModel
  , Game2.gameDescriptor DontCheatGameModel
 ]

type Screen  =
  MainScreen
  | GameScreen GameModel

type alias Model = {
  nextId : Int,
  playerUrl: String,
  players: List Player,
  screen: Screen
}

initModel : (Model, Cmd Msg)
initModel = {
  nextId = 3,
  playerUrl = "",
  players = [Player 0 "http://localhost:3001", Player 1 "http://localhost:3002", Player 2 "http://localhost:3003"],
  screen = MainScreen
 } ! []

-- UPDATE --------------------------------------------------------------------------------------------------------------
type Msg =
  EditNewPlayerUrl String
  | AddPlayer
  | RemovePlayer Int
  | SelectGame Game
  | BackToMain
  | PlayIntroGame Game1.Model Game1.Msg
  | PlayDontCheatGame Game2.Model Game2.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case Debug.log "Main" msg of
    EditNewPlayerUrl url                  -> {model | playerUrl = url} ! []
    AddPlayer                             -> {model | players =  (Player model.nextId model.playerUrl) :: model.players
                                                    , playerUrl = ""
                                                    , nextId = model.nextId + 1} ! []
    RemovePlayer id                       -> {model | players = List.filter (\p -> p.id /= id) model.players} ! []
    SelectGame game                       -> {model | screen = GameScreen (game.initModel model.players)} ! []
    PlayIntroGame gameModel msg'  ->
      let
        (newGameModel, newGameCmd) = (Game1.update msg' gameModel)
        newModel = {model | screen = GameScreen (IntroGameModel newGameModel)}
      in
        (newModel, Cmd.map (PlayIntroGame newGameModel) newGameCmd)
    PlayDontCheatGame gameModel msg'  ->
      let
        (newGameModel, newGameCmd) = (Game2.update msg' gameModel)
        newModel = {model | screen = GameScreen (DontCheatGameModel newGameModel)}
      in
        (newModel, Cmd.map (PlayDontCheatGame newGameModel) newGameCmd)
    BackToMain                            -> {model | screen = MainScreen } ! []

-- VIEW ----------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =
  case model.screen of
    MainScreen -> viewMainScreen model
    GameScreen gameModel -> viewGameScreen gameModel

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

viewGameScreen : GameModel -> Html Msg
viewGameScreen gameModel =
  div [] [
    button [onClick BackToMain] [text "Back"],
    span [] [text "fuck"], --TODO game.title],
    hr [] [],
    viewGame gameModel
  ]

viewGame : GameModel -> Html Msg
viewGame gameModel =
  case gameModel of
    IntroGameModel model      -> Html.App.map (PlayIntroGame model) (Game1.view model)
    DontCheatGameModel model  -> Html.App.map (PlayDontCheatGame model) (Game2.view model)
