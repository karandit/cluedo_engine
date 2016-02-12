module Game2DontCheat (game) where

import Model exposing (..)

game : Game
game = {
  title = "Don't cheat",
  isDisabled = \model -> List.isEmpty model.players
 }
