module RestDojo.Main where

import Html exposing (..)
import Html.Attributes exposing (placeholder, value, disabled)
import Html.Events exposing (onClick, on, targetValue)
import Signal exposing (Mailbox, mailbox)

import RestDojo.Types exposing (..)
import RestDojo.Games.GameIntroduceYourself as Game1

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Signal Html
main = Signal.map (view box.address) (Signal.foldp update initModel box.signal)

box : Mailbox Action
box = mailbox NoOp

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
type Action =
  NoOp
  | EditNewPlayerUrl String
  | AddPlayer
  | RemovePlayer Int
  | SelectGame Game
  | BackToMain
  | PlayIntroGame Game Game1.Model Game1.Action

update : Action -> Model -> Model
update action model =
  case action of
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
view : Signal.Address Action -> Model -> Html
view address model =
  case model.screen of
    MainScreen -> viewMainScreen address model
    GameScreen (game, gameModel) -> viewGameScreen address game gameModel

viewMainScreen : Signal.Address Action -> Model -> Html
viewMainScreen address model =
    div [] [
        div [] (List.map (\player -> div [] [text player.url, button [onClick address (RemovePlayer player.id)] [text "Remove"]]) model.players),
        input [placeholder "URL", value model.playerUrl, on "input" targetValue (Signal.message address << EditNewPlayerUrl)] [],
        button [onClick address AddPlayer] [text "Add"],
        hr [] [],
        div [] (List.map (viewTile address model) allGames)
    ]

viewTile : Signal.Address Action -> Model -> Game -> Html
viewTile address model game =
    button [onClick address (SelectGame game), disabled (game.isDisabled model.players)] [text game.title]

viewGameScreen : Signal.Address Action -> Game -> GameModel -> Html
viewGameScreen address game gameModel =
  div [] [
    button [onClick address BackToMain] [text "Back"],
    span [] [text game.title],
    hr [] [],
    viewGame address game gameModel
  ]

viewGame : Signal.Address Action -> Game -> GameModel -> Html
viewGame address game gameModel =
  case gameModel of
    IntroGameModel model -> Game1.view (Signal.forwardTo address (PlayIntroGame game model)) model
