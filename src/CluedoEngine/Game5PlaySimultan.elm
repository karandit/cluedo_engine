module CluedoEngine.Game5PlaySimultan (game) where

import CluedoEngine.Model exposing (..)

game : Game
game = {
  title = "Play simultaneously",
  isDisabled = \players -> List.length players < 6
 }
