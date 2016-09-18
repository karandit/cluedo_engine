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
type Game =
  IntroGame Game1.Model
  | DontCheatGame Game2.Model

type alias Tile = TileDescriptor Game

allGames : List Tile
allGames = [
  Game1.tileDescriptor IntroGame
  , Game2.tileDescriptor DontCheatGame
 ]

type Screen  =
  MainScreen
  | GameScreen Game

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
  | SelectTile Tile
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
    SelectTile tile                       -> {model | screen = GameScreen (tile.initGame model.players)} ! []
    PlayIntroGame gameModel msg'  ->
      let
        (newGameModel, newGameCmd) = (Game1.update msg' gameModel)
        newModel = {model | screen = GameScreen (IntroGame newGameModel)}
      in
        (newModel, Cmd.map (PlayIntroGame newGameModel) newGameCmd)
    PlayDontCheatGame gameModel msg'  ->
      let
        (newGameModel, newGameCmd) = (Game2.update msg' gameModel)
        newModel = {model | screen = GameScreen (DontCheatGame newGameModel)}
      in
        (newModel, Cmd.map (PlayDontCheatGame newGameModel) newGameCmd)
    BackToMain                            -> {model | screen = MainScreen } ! []

-- VIEW ----------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =
  case model.screen of
    MainScreen -> viewMainScreen model
    GameScreen game -> viewGameScreen game

viewMainScreen : Model -> Html Msg
viewMainScreen model =
    div [] [
        div [] (List.map (\player -> div [] [text player.url, button [onClick (RemovePlayer player.id)] [text "Remove"]]) model.players),
        input [placeholder "URL", value model.playerUrl, on "input" (Json.map EditNewPlayerUrl targetValue)] [],
        button [onClick AddPlayer] [text "Add"],
        hr [] [],
        div [] (List.map (viewTile model) allGames)
    ]

viewTile : Model -> Tile -> Html Msg
viewTile model tile =
    button [onClick (SelectTile tile), disabled (tile.isDisabled model.players)] [text tile.title]

viewGameScreen : Game -> Html Msg
viewGameScreen game =
  div [] [
    button [onClick BackToMain] [text "Back"],
    span [] [text "fuck"], --TODO game.title],
    hr [] [],
    viewGame game
  ]

viewGame : Game -> Html Msg
viewGame game =
  case game of
    IntroGame model      -> Html.App.map (PlayIntroGame model) (Game1.view model)
    DontCheatGame model  -> Html.App.map (PlayDontCheatGame model) (Game2.view model)
