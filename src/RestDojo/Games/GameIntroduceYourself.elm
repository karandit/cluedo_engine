module RestDojo.Games.GameIntroduceYourself exposing (gameDescriptor, Model, Msg, update, view)

import Html exposing (Html, text, div, span, button)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick)
import Html.App
import Http
import Task

import RestDojo.Types exposing (..)

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Program Never
main =
      Html.App.program {
        init = (
                initModel [
                  Player 1 "http://localhost:3002"
                  , Player 0 "http://localhost:3001"
                  , Player 2 "http://localhost:3003"
                  ]
                , Cmd.none),
        update = update,
        view = view,
        subscriptions = \_ -> Sub.none}

--PUBLIC ---------------------------------------------------------------------------------------------------------------
gameDescriptor : (Model -> a) -> GameDescriptor a
gameDescriptor modelWrapper = {
  title = "Introduce yourself",
  isDisabled = List.isEmpty,
  initModel = \players -> modelWrapper (initModel players)
 }

--MODEL-----------------------------------------------------------------------------------------------------------------
type State = None | Waiting | Success String | Failed String

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
  | FetchNameSucceed Player String
  | FetchNameFail Player Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case Debug.log "IntroduceYourself" msg of
    PushStart ->
      {model
        | started = True
        , playerStates = List.map (\(p, _) -> (p, Waiting)) model.playerStates}
      ! List.map getName model.playerStates

    FetchNameSucceed player newName ->
      (newName |> Success |> updatePlayer model player.id) ! []

    FetchNameFail player reason ->
      (toString reason |> Failed |> updatePlayer model player.id) ! []

updatePlayer : Model -> Int -> State -> Model
updatePlayer model playerId newState =
      {model | playerStates = List.map (\(p, s) -> (p, if (p.id == playerId) then newState else s)) model.playerStates}

getName : (Player, State) -> Cmd Msg
getName (player, _) =
    let
      url = player.url ++ "/name"
    in
      Task.perform (FetchNameFail player) (FetchNameSucceed player) (Http.getString url)

--VIEW------------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =
  div [] [
    button [onClick PushStart, disabled model.started] [text "Start"],
    div [] (List.map viewPlayerState model.playerStates)
  ]

viewPlayerState : (Player, State) -> Html Msg
viewPlayerState (player, state) =
  div [] [text (player.url ++ "    :    " ++ (toString state))]
