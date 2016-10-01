module RestDojo.Games.Cluedo.API exposing (startGame)

import RestDojo.Types exposing (..)

name: Player -> String
name player = 
  player.url ++ "/name"

startGame: GameId -> Player -> String
startGame gameId player =
  player.url ++ "/" ++ (toString gameId) ++ "/startGame"
