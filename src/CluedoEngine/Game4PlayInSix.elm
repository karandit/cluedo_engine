module CluedoEngine.Game4PlayInSix (game) where

import CluedoEngine.Model exposing (..)

game : Game
game = {
  title = "Play in 6",
  isDisabled = \model -> List.length model.players < 6
 }
