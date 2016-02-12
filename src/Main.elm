module Main where

import Html exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Mailbox, mailbox)

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Signal Html
main = Signal.map (view box.address) (Signal.foldp update initModel box.signal)

box : Mailbox Action
box = mailbox NoOp

-- MODEL ---------------------------------------------------------------------------------------------------------------
type alias Model = {
  nextId : Int,
  players : List Player
}

type alias Player = {
  id : Int,
  url : String
}

initModel : Model
initModel = {
  nextId = 3,
  players = [
    Player 0 "http://localhost:3001"
    , Player 1 "http://localhost:3002"
    , Player 2 "http://localhost:3003"
  ]
 }

-- UPDATE --------------------------------------------------------------------------------------------------------------
type Step =
  IntroduceYourself
  | DontCheat
  | PlayIn3
  | PlayIn6
  | PlaySimultan

type Action =
  NoOp
  -- | AddPlayer String
  | RemovePlayer Int
  -- | JumpTo Step

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    RemovePlayer id -> {model | players <- List.filter (\p -> p.id /= id) model.players}

-- VIEW ----------------------------------------------------------------------------------------------------------------
view : Signal.Address Action -> Model -> Html
view address model =
    div [] [
        div [] (List.map (\player -> div [] [text player.url, button [onClick address (RemovePlayer player.id)] [text "Remove"]]) model.players),
        input [] [],
        button [] [text "Add"],
        div [] [
          button [] [text "Introduce yourself"],
          button [] [text "Don't cheat"],
          button [] [text "Play in 3"],
          button [] [text "Play in 6"],
          button [] [text "Play simultaneously"]
        ]
    ]
