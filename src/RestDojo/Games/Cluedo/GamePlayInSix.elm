module RestDojo.Games.Cluedo.GamePlayInSix (gameDescriptor) where

import RestDojo.Types exposing (..)

gameDescriptor : a -> GameDescriptor a
gameDescriptor factory = {
  title = "Play in 6",
  isDisabled = \players -> List.length players < 6,
  initModel = \players -> factory
 }
