module RestDojo.Games.Cluedo.GamePlayInSix (gameDescriptor) where

import RestDojo.Types exposing (..)

gameDescriptor : GameDescriptor
gameDescriptor = {
  title = "Play in 6",
  isDisabled = \players -> List.length players < 6
 }
