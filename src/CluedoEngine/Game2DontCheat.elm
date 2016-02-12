module CluedoEngine.Game2DontCheat (game) where

import CluedoEngine.Model exposing (..)

game : Game
game = {
  title = "Don't cheat",
  isDisabled = \model -> List.isEmpty model.players
 }
