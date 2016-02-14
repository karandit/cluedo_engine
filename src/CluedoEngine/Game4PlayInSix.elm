module CluedoEngine.Game4PlayInSix (gameDescriptor) where

import CluedoEngine.Types exposing (..)

gameDescriptor : GameDescriptor
gameDescriptor = {
  title = "Play in 6",
  isDisabled = \players -> List.length players < 6
 }
