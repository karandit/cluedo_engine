module CluedoEngine.Main where

import Html exposing (..)
import Html.Attributes exposing (placeholder, value, disabled)
import Html.Events exposing (onClick, on, targetValue)
import Signal exposing (Mailbox, mailbox)

import CluedoEngine.Model exposing (..)
import CluedoEngine.Game1IntroduceYourself as Game1
import CluedoEngine.Game2DontCheat as Game2
import CluedoEngine.Game3PlayInThree as Game3
import CluedoEngine.Game4PlayInSix as Game4
import CluedoEngine.Game5PlaySimultan as Game5

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Signal Html
main = Signal.map (view box.address) (Signal.foldp update initModel box.signal)

box : Mailbox Action
box = mailbox NoOp

allGames : List Game
allGames = [
  Game1.game,
  Game2.game,
  Game3.game,
  Game4.game,
  Game5.game
 ]

-- UPDATE --------------------------------------------------------------------------------------------------------------
type Step =
  IntroduceYourself
  | DontCheat
  | PlayIn3
  | PlayIn6
  | PlaySimultan

type Action =
  NoOp
  | EditNewPlayerUrl String
  | AddPlayer
  | RemovePlayer Int
  | SelectGame
  | BackToMain

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    EditNewPlayerUrl url -> {model | playerUrl <- url}
    AddPlayer -> {model | players <-  (Player model.nextId model.playerUrl) :: model.players
                        , playerUrl <- ""
                        , nextId <- model.nextId + 1}
    RemovePlayer id -> {model | players <- List.filter (\p -> p.id /= id) model.players}
    SelectGame -> {model | mode <- GameScreen }
    BackToMain -> {model | mode <- MainScreen }

-- VIEW ----------------------------------------------------------------------------------------------------------------
view : Signal.Address Action -> Model -> Html
view address model =
  case model.mode of
    MainScreen -> viewMainScreen address model
    GameScreen -> viewGameScreen address model

viewMainScreen : Signal.Address Action -> Model -> Html
viewMainScreen address model =
    div [] [
        div [] (List.map (\player -> div [] [text player.url, button [onClick address (RemovePlayer player.id)] [text "Remove"]]) model.players),
        input [placeholder "URL", value model.playerUrl, on "input" targetValue (Signal.message address << EditNewPlayerUrl)] [],
        button [onClick address AddPlayer] [text "Add"],
        hr [] [],
        div [] (List.map (viewGameTile address model) allGames)
    ]

viewGameTile : Signal.Address Action -> Model -> Game -> Html
viewGameTile address model game =
  button [onClick address SelectGame, disabled (game.isDisabled model)] [text game.title]

viewGameScreen : Signal.Address Action -> Model -> Html
viewGameScreen address model =
  button [onClick address BackToMain] [text "Back"]
