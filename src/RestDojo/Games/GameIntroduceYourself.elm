module RestDojo.Games.GameIntroduceYourself exposing (gameDescriptor, Model, Msg, update, view)

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
type Msg =
  PushStart

update : Msg -> Model -> Model
update msg model =
  case msg of
    PushStart -> {model | started = True
                        , playerStates = List.map (\(p, _) -> (p, Waiting)) model.playerStates}

--VIEW------------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =
  div [] [
    button [onClick PushStart, disabled model.started] [text "Start"],
    div [] (List.map viewPlayerState model.playerStates)
  ]

viewPlayerState : (Player, State) -> Html Msg
viewPlayerState (player, state) =
  div [] [text player.url, text "    :    ", text (toString state)]
