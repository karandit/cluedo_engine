module CluedoEngine.Game2DontCheat (game) where

import Html exposing (Html, text)

import CluedoEngine.Model exposing (..)

game : Game
game = {
  title = "Don't cheat",
  isDisabled = \players -> List.isEmpty players,
  view = view
 }

view : List Player -> Html
view players = text "asdd"
