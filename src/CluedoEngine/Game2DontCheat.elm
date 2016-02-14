module CluedoEngine.Game2DontCheat (gameDescriptor) where

import CluedoEngine.Types exposing (..)

gameDescriptor : GameDescriptor
gameDescriptor = {
  title = "Don't cheat",
  isDisabled = \players -> List.isEmpty players
 }
