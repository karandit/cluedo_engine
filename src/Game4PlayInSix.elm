module Game4PlayInSix (game) where

import Model exposing (..)

game : Game
game = {
  title = "Play in 6",
  isDisabled = \model -> List.length model.players < 6
 }
