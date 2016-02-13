module CluedoEngine.Game4PlayInSix (game) where

import Html exposing (Html, text)

import CluedoEngine.Model exposing (..)

game : Game
game = {
  title = "Play in 6",
  isDisabled = \players -> List.length players < 6,
  view = \players -> text "asdd"
 }
