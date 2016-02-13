module CluedoEngine.Game5PlaySimultan (game) where

import Html exposing (Html, text)

import CluedoEngine.Model exposing (..)

game : Game
game = {
  title = "Play simultaneously",
  isDisabled = \players -> List.length players < 6,
  view = \players -> text "asdd"
 }
