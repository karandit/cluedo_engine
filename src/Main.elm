module Main where

import Html exposing (..)
import Html.Attributes exposing (placeholder, value, disabled)
import Html.Events exposing (onClick, on, targetValue)
import Signal exposing (Mailbox, mailbox)

import Model exposing (..)

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Signal Html
main = Signal.map (view box.address) (Signal.foldp update initModel box.signal)

box : Mailbox Action
box = mailbox NoOp

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
  -- | JumpTo Step

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    EditNewPlayerUrl url -> {model | playerUrl <- url}
    AddPlayer -> {model | players <-  (Player model.nextId model.playerUrl) :: model.players
                        , playerUrl <- ""
                        , nextId <- model.nextId + 1}
    RemovePlayer id -> {model | players <- List.filter (\p -> p.id /= id) model.players}

-- VIEW ----------------------------------------------------------------------------------------------------------------
view : Signal.Address Action -> Model -> Html
view address model =
    div [] [
        div [] (List.map (\player -> div [] [text player.url, button [onClick address (RemovePlayer player.id)] [text "Remove"]]) model.players),
        input [placeholder "URL", value model.playerUrl, on "input" targetValue (Signal.message address << EditNewPlayerUrl)] [],
        button [onClick address AddPlayer] [text "Add"],
        hr [] [],
        div [] [
          button [disabled (List.isEmpty model.players)] [text "Introduce yourself"],
          button [disabled (List.isEmpty model.players)] [text "Don't cheat"],
          button [disabled (List.length model.players < 3)] [text "Play in 3"],
          button [disabled (List.length model.players < 6)] [text "Play in 6"],
          button [disabled (List.length model.players < 6)] [text "Play simultaneously"]
        ]
    ]
