module CluedoEngine.Game5PlaySimultan (game) where

import CluedoEngine.Model exposing (..)

game : Game
game = {
  title = "Play simultaneously",
  isDisabled = \model -> List.length model.players < 6
 }
