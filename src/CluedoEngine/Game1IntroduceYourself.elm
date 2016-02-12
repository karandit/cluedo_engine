module CluedoEngine.Game1IntroduceYourself (game) where

import CluedoEngine.Model exposing (..)

game : Game
game = {
  title = "Introduce yourself",
  isDisabled = \model -> List.isEmpty model.players
 }
