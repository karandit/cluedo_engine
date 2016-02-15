module RestDojo.Games.Cluedo.GameDontCheat (gameDescriptor) where

import RestDojo.Types exposing (..)

gameDescriptor : a -> GameDescriptor a
gameDescriptor factory = {
  title = "Don't cheat",
  isDisabled = \players -> List.isEmpty players,
  initModel = \palyers -> factory
 }
