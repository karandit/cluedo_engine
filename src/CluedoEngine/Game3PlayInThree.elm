module CluedoEngine.Game3PlayInThree (gameDescriptor) where

import CluedoEngine.Model exposing (..)

gameDescriptor : GameDescriptor
gameDescriptor = {
  title = "Play in 3",
  isDisabled = \players -> List.length players < 3
 }
