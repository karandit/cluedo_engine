module CluedoEngine.Model (..) where

import Html exposing (Html)

-- MODEL ---------------------------------------------------------------------------------------------------------------
type Screen = MainScreen | GameScreen Game

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
  isDisabled: List Player -> Bool,
  view: List Player -> Html
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
