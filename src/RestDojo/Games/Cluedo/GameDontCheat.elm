module RestDojo.Games.Cluedo.GameDontCheat (gameDescriptor) where

import RestDojo.Types exposing (..)

gameDescriptor : GameDescriptor
gameDescriptor = {
  title = "Don't cheat",
  isDisabled = \players -> List.isEmpty players
 }
