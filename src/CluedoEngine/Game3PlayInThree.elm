module CluedoEngine.Game3PlayInThree (game) where

import CluedoEngine.Model exposing (..)

game : Game
game = {
  title = "Play in 3",
  isDisabled = \model -> List.length model.players < 3
 }
