module CluedoEngine.Main where

import Html exposing (..)
import Html.Attributes exposing (placeholder, value, disabled)
import Html.Events exposing (onClick, on, targetValue)
import Signal exposing (Mailbox, mailbox)

import CluedoEngine.Model exposing (..)
import CluedoEngine.Game1IntroduceYourself as Game1

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Signal Html
main = Signal.map (view box.address) (Signal.foldp update initModel box.signal)

box : Mailbox Action
box = mailbox NoOp

-- MODEL ---------------------------------------------------------------------------------------------------------------
type GameType =
  IntroGame

type GameModel =
  IntroGameModel Game1.Model

type Screen  =
  MainScreen
  | GameScreen GameModel

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
  players = [
    Player 0 "http://localhost:3001"
    , Player 1 "http://localhost:3002"
  ],
  screen = MainScreen
 }

allGameTypes : List GameType
allGameTypes = [
  IntroGame
 ]

gameTypeToGame : GameType -> Game
gameTypeToGame gameType =
  case gameType of
    IntroGame -> Game1.game

gameModelToGame : GameModel -> Game
gameModelToGame gameModel =
  case gameModel of
    IntroGameModel _ -> Game1.game

initGameModel : List Player -> GameType -> GameModel
initGameModel players gameType =
  case gameType of
    IntroGame -> IntroGameModel (Game1.initModel players)

-- UPDATE --------------------------------------------------------------------------------------------------------------
type Action =
  NoOp
  | EditNewPlayerUrl String
  | AddPlayer
  | RemovePlayer Int
  | SelectGame GameType
  | BackToMain
  | PlayIntroGame Game1.Model Game1.Action

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    EditNewPlayerUrl url -> {model | playerUrl <- url}
    AddPlayer -> {model | players <-  (Player model.nextId model.playerUrl) :: model.players
                        , playerUrl <- ""
                        , nextId <- model.nextId + 1}
    RemovePlayer id -> {model | players <- List.filter (\p -> p.id /= id) model.players}
    SelectGame gameType -> {model | screen <- GameScreen (initGameModel model.players gameType)}
    PlayIntroGame gameModel action' -> {model | screen <- GameScreen (IntroGameModel (Game1.update action' gameModel))}
    BackToMain -> {model | screen <- MainScreen }

-- VIEW ----------------------------------------------------------------------------------------------------------------
view : Signal.Address Action -> Model -> Html
view address model =
  case model.screen of
    MainScreen        -> viewMainScreen address model
    GameScreen store  -> viewGameScreen address store

viewMainScreen : Signal.Address Action -> Model -> Html
viewMainScreen address model =
    div [] [
        div [] (List.map (\player -> div [] [text player.url, button [onClick address (RemovePlayer player.id)] [text "Remove"]]) model.players),
        input [placeholder "URL", value model.playerUrl, on "input" targetValue (Signal.message address << EditNewPlayerUrl)] [],
        button [onClick address AddPlayer] [text "Add"],
        hr [] [],
        div [] (List.map (viewTile address model) allGameTypes)
    ]

viewTile : Signal.Address Action -> Model -> GameType -> Html
viewTile address model gameType =
  let
    game = gameTypeToGame gameType
  in
    button [onClick address (SelectGame gameType), disabled (game.isDisabled model.players)] [text game.title]

viewGameScreen : Signal.Address Action -> GameModel -> Html
viewGameScreen address gameModel =
  let
    game = gameModelToGame gameModel
  in
    div [] [
      button [onClick address BackToMain] [text "Back"],
      span [] [text game.title],
      hr [] [],
      viewGame address gameModel
    ]

viewGame : Signal.Address Action -> GameModel -> Html
viewGame address gameModel =
  case gameModel of
    IntroGameModel model -> Game1.view (Signal.forwardTo address (PlayIntroGame model)) model
