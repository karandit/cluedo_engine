module RestDojo.Games.Cluedo.GamePlaySimultan (gameDescriptor) where

import RestDojo.Types exposing (..)

gameDescriptor : a -> GameDescriptor a
gameDescriptor factory = {
  title = "Play simultaneously",
  isDisabled = \players -> List.length players < 6,
  initModel = \players -> factory
 }
