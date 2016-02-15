module RestDojo.Games.GameIntroduceYourself (gameDescriptor, Model, initModel, Action, update, view) where

import Html exposing (Html, text, div, span, button)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick)

import RestDojo.Types exposing (..)

--PUBLIC ---------------------------------------------------------------------------------------------------------------
gameDescriptor : (Model -> a) -> GameDescriptor a
gameDescriptor wrapper = {
  title = "Introduce yourself",
  isDisabled = List.isEmpty,
  initModel = \players -> wrapper (initModel players)
 }

--MODEL-----------------------------------------------------------------------------------------------------------------
type State = None | Waiting | Success String | Error String

type alias Model = {
  started: Bool,
  playerStates: List (Player, State)
 }

initModel : List Player -> Model
initModel players = {
  started = False,
  playerStates = List.map (\p -> (p, None)) players
 }

--UPDATE----------------------------------------------------------------------------------------------------------------
type Action =
  PushStart

update : Action -> Model -> Model
update action model =
  case action of
    PushStart -> {model | started = True
                        , playerStates = List.map (\(p, _) -> (p, Waiting)) model.playerStates}

--VIEW------------------------------------------------------------------------------------------------------------------
view : Signal.Address Action -> Model -> Html
view address model =
  div [] [
    button [onClick address PushStart, disabled model.started] [text "Start"],
    div [] (List.map viewPlayerState model.playerStates)
  ]

viewPlayerState : (Player, State) -> Html
viewPlayerState (player, state) =
  div [] [text player.url, text "    :    ", text (toString state)]
