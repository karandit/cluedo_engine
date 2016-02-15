module RestDojo.Games.Cluedo.GamePlayInThree (gameDescriptor) where

import RestDojo.Types exposing (..)

gameDescriptor : a -> GameDescriptor a
gameDescriptor factory = {
  title = "Play in 3",
  isDisabled = \players -> List.length players < 3,
  initModel = \players -> factory
 }
