module RestDojo.Game5PlaySimultan (gameDescriptor) where

import RestDojo.Types exposing (..)

gameDescriptor : GameDescriptor
gameDescriptor = {
  title = "Play simultaneously",
  isDisabled = \players -> List.length players < 6
 }
