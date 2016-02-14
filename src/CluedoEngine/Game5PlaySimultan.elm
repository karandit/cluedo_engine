module CluedoEngine.Game5PlaySimultan (gameDescriptor) where

import CluedoEngine.Model exposing (..)

gameDescriptor : GameDescriptor
gameDescriptor = {
  title = "Play simultaneously",
  isDisabled = \players -> List.length players < 6
 }
