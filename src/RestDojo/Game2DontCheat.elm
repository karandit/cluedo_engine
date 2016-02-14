module RestDojo.Game2DontCheat (gameDescriptor) where

import RestDojo.Types exposing (..)

gameDescriptor : GameDescriptor
gameDescriptor = {
  title = "Don't cheat",
  isDisabled = \players -> List.isEmpty players
 }
