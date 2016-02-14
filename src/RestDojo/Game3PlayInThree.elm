module RestDojo.Game3PlayInThree (gameDescriptor) where

import RestDojo.Types exposing (..)

gameDescriptor : GameDescriptor
gameDescriptor = {
  title = "Play in 3",
  isDisabled = \players -> List.length players < 3
 }
