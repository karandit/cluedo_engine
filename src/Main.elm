module Main where

import Html             exposing (..)

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Html
main = view initModel

-- MODEL ---------------------------------------------------------------------------------------------------------------
type alias Model = {
  nextId : Int,
  players : List Player
}

type alias Player = {
  id : Int,
  url : String
}

initModel : Model
initModel = {
  nextId = 0,
  players = []
 }

-- VIEW ----------------------------------------------------------------------------------------------------------------
view : Model -> Html
view model =
    div [] [
        div [] (List.map (\player -> div [] [text player.url, button [] [text "Remove"]]) model.players),
        input [] [],
        button [] [text "Add"],
        div [] [
          button [] [text "Introduce yourself"],
          button [] [text "Don't cheat"],
          button [] [text "Play in 3"],
          button [] [text "Play in 6"],
          button [] [text "Play simultaneously"]
        ]
    ]
