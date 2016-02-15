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
type Game =
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

allGames : List (Game, GameDescriptor GameModel)
allGames = [
  (IntroGame, Game1.gameDescriptor IntroGameModel)
 ]

gameModelToGameDescriptor : GameModel -> GameDescriptor GameModel
gameModelToGameDescriptor gameModel =
  case gameModel of
    IntroGameModel _ -> Game1.gameDescriptor IntroGameModel

-- UPDATE --------------------------------------------------------------------------------------------------------------
type Action =
  NoOp
  | EditNewPlayerUrl String
  | AddPlayer
  | RemovePlayer Int
  | SelectGame (GameDescriptor GameModel)
  | BackToMain
  | PlayIntroGame Game1.Model Game1.Action

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    EditNewPlayerUrl url -> {model | playerUrl = url}
    AddPlayer -> {model | players =  (Player model.nextId model.playerUrl) :: model.players
                        , playerUrl = ""
                        , nextId = model.nextId + 1}
    RemovePlayer id -> {model | players = List.filter (\p -> p.id /= id) model.players}
    SelectGame gameDescr -> {model | screen = GameScreen (gameDescr.initModel model.players)}
    PlayIntroGame gameModel action' -> {model | screen = GameScreen (IntroGameModel (Game1.update action' gameModel))}
    BackToMain -> {model | screen = MainScreen }

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
        div [] (List.map (\(_, gameDescr) -> viewTile address model gameDescr) allGames)
    ]

viewTile : Signal.Address Action -> Model -> GameDescriptor GameModel -> Html
viewTile address model gameDescr =
    button [onClick address (SelectGame gameDescr), disabled (gameDescr.isDisabled model.players)] [text gameDescr.title]

viewGameScreen : Signal.Address Action -> GameModel -> Html
viewGameScreen address gameModel =
  let
    gameDescr = gameModelToGameDescriptor gameModel
  in
    div [] [
      button [onClick address BackToMain] [text "Back"],
      span [] [text gameDescr.title],
      hr [] [],
      viewGame address gameModel
    ]

viewGame : Signal.Address Action -> GameModel -> Html
viewGame address gameModel =
  case gameModel of
    IntroGameModel model -> Game1.view (Signal.forwardTo address (PlayIntroGame model)) model
