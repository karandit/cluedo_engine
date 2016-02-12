module Game1IntroduceYourself (game) where

import Model exposing (..)

game : Game
game = {
  title = "Introduce yourself",
  isDisabled = \model -> List.isEmpty model.players
 }
