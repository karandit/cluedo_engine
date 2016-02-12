module CluedoEngine.Model (..) where

-- MODEL ---------------------------------------------------------------------------------------------------------------
type Screen = MainScreen | GameScreen

type alias Model = {
  nextId : Int,
  playerUrl: String,
  players: List Player,
  mode: Screen
}

type alias Player = {
  id : Int,
  url : String
}

type alias Game = {
  title: String,
  isDisabled: Model -> Bool
}

initModel : Model
initModel = {
  nextId = 2,
  playerUrl = "",
  players = [
    Player 0 "http://localhost:3001"
    , Player 1 "http://localhost:3002"
  ],
  mode = MainScreen
 }
