module Model (..) where

-- MODEL ---------------------------------------------------------------------------------------------------------------
type alias Model = {
  nextId : Int,
  playerUrl: String,
  players : List Player
}

type alias Player = {
  id : Int,
  url : String
}

initModel : Model
initModel = {
  nextId = 2,
  playerUrl = "",
  players = [
    Player 0 "http://localhost:3001"
    , Player 1 "http://localhost:3002"
  ]
 }
