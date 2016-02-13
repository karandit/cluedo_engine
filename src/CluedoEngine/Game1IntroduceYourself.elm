module CluedoEngine.Game1IntroduceYourself (game) where

import Html exposing (Html, text, div, span)

import CluedoEngine.Model exposing (..)

game : Game
game = {
  title = "Introduce yourself",
  isDisabled = \players -> List.isEmpty players,
  view = view
 }

view : List Player -> Html
view players =
  div [] (List.map viewPlayer players)

viewPlayer : Player -> Html
viewPlayer player =
  div [] [text player.url]
