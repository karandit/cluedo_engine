module CluedoEngine.Game5PlaySimultan (gameDescriptor) where

import CluedoEngine.Types exposing (..)

gameDescriptor : GameDescriptor
gameDescriptor = {
  title = "Play simultaneously",
  isDisabled = \players -> List.length players < 6
 }
