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

allGames : List Game
allGames = [
  IntroGame
 ]

gameToGameDescriptor : Game -> GameDescriptor
gameToGameDescriptor game =
  case game of
    IntroGame -> Game1.gameDescriptor

gameModelToGameDescriptor : GameModel -> GameDescriptor
gameModelToGameDescriptor gameModel =
  case gameModel of
    IntroGameModel _ -> Game1.gameDescriptor

initGameModel : List Player -> Game -> GameModel
initGameModel players game =
  case game of
    IntroGame -> IntroGameModel (Game1.initModel players)

-- UPDATE --------------------------------------------------------------------------------------------------------------
type Action =
  NoOp
  | EditNewPlayerUrl String
  | AddPlayer
  | RemovePlayer Int
  | SelectGame Game
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
        div [] (List.map (viewTile address model) allGames)
    ]

viewTile : Signal.Address Action -> Model -> Game -> Html
viewTile address model game =
  let
    gameDescr = gameToGameDescriptor game
  in
    button [onClick address (SelectGame game), disabled (gameDescr.isDisabled model.players)] [text gameDescr.title]

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