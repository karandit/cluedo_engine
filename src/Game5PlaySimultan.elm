module Game5PlaySimultan (game) where

import Model exposing (..)

game : Game
game = {
  title = "Play simultaneously",
  isDisabled = \model -> List.length model.players < 6
 }
