module Main where

import Html exposing (..)
import Signal exposing (Mailbox, mailbox)

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Signal Html
main = Signal.map view (Signal.foldp update initModel box.signal)

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
  nextId = 0,
  players = []
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
  -- | RemovePlayer Int
  -- | JumpTo Step

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model

-- VIEW ----------------------------------------------------------------------------------------------------------------
view : Model -> Html
view model =
    div [] [
        div [] (List.map (\player -> div [] [text player.url, button [] [text "Remove"]]) model.players),
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
