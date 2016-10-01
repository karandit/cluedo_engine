module RestDojo.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, value, disabled, src, width, height)
import Html.Events exposing (onClick, on, targetValue)
import Html.App

import Json.Decode as Json

import RestDojo.Types exposing (..)
import RestDojo.Games.GameIntroduceYourself as Game1
import RestDojo.Games.Cluedo.GameDontCheat as Game2

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Program Never
main =
      Html.App.program {
        init = initModel,
        update = update,
        view = view,
        subscriptions = \_ -> Sub.none}

-- MODEL ---------------------------------------------------------------------------------------------------------------
type Game =
  IntroGame Game1.Model
  | DontCheatGame Game2.Model

type GameMsg =
  IntroGameMsg Game1.Msg
  | DontCheatGameMsg Game2.Msg

type alias Tile = TileDescriptor Game

allTiles : List Tile
allTiles = [
  Game1.tileDescriptor IntroGame
  , Game2.tileDescriptor DontCheatGame
 ]

type Screen  =
  MainScreen
  | GameScreen String Game

type alias Model = {
  nextId : Int,
  playerUrl: String,
  players: List Player,
  screen: Screen
}

initModel : (Model, Cmd Msg)
initModel = {
  nextId = 3,
  playerUrl = "",
  players = [Player 0 "http://localhost:3001", Player 1 "http://localhost:3002", Player 2 "http://localhost:3003"],
  screen = MainScreen
 } ! []

-- UPDATE --------------------------------------------------------------------------------------------------------------
type Msg =
  EditNewPlayerUrl String
  | AddPlayer
  | RemovePlayer Int
  | SelectTile Tile
  | BackToMain
  | PlayGame GameMsg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    EditNewPlayerUrl url                  -> {model | playerUrl = url} ! []
    AddPlayer                             -> {model | players =  (Player model.nextId model.playerUrl) :: model.players
                                                    , playerUrl = ""
                                                    , nextId = model.nextId + 1} ! []
    RemovePlayer id                       -> {model | players = List.filter (\p -> p.id /= id) model.players} ! []
    BackToMain                            -> {model | screen = MainScreen } ! []
    SelectTile tile                       -> {model | screen = GameScreen tile.title (tile.initGame model.players)} ! []
    PlayGame gameMsg                      ->
            case model.screen of
              MainScreen -> model ! [] -- TODO it couldn't happen, cause MainScreen can't get PlayGame msg
              GameScreen title game ->
                    let
                      (newGame, newCmd) = updateGame gameMsg game
                    in
                      {model | screen = GameScreen title newGame} ! [newCmd]

updateGame : GameMsg -> Game -> (Game, Cmd Msg)
updateGame msg game =
  case (msg, game) of
      (IntroGameMsg gameMsg, IntroGame gameModel)         ->
                            let
                              (newGameModel, newGameCmd) = Game1.update gameMsg gameModel
                              newGame = IntroGame newGameModel
                              newCmd = Cmd.map (\newGameMsg -> PlayGame (IntroGameMsg newGameMsg)) newGameCmd
                            in
                              (newGame, newCmd)
      (DontCheatGameMsg gameMsg, DontCheatGame gameModel) ->
                            let
                              (newGameModel, newGameCmd) = Game2.update gameMsg gameModel
                              newGame = DontCheatGame newGameModel
                              newCmd = Cmd.map (\newGameMsg -> PlayGame (DontCheatGameMsg newGameMsg)) newGameCmd
                            in
                              (newGame, newCmd)
      (_, _) -> Debug.crash "TODO"

-- VIEW ----------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =
  case model.screen of
    MainScreen -> viewMainScreen model
    GameScreen title game -> viewGameScreen title game

viewMainScreen : Model -> Html Msg
viewMainScreen model =
    div [] [
        div [] (List.map viewPlayer model.players),
        input [placeholder "URL", value model.playerUrl, on "input" (Json.map EditNewPlayerUrl targetValue)] [],
        button [onClick AddPlayer] [text "Add"],
        hr [] [],
        div [] (List.map (viewTile model) allTiles)
    ]

viewPlayer : Player -> Html Msg
viewPlayer player =
  div [] [
    img [src <| "https://robohash.org/" ++ player.url, width 80, height 80] []
    , text player.url
    , button [onClick (RemovePlayer player.id)] [text "Remove"]
    ]

viewTile : Model -> Tile -> Html Msg
viewTile model tile =
    button [onClick (SelectTile tile), disabled (tile.isDisabled model.players)] [text tile.title]

viewGameScreen : String -> Game -> Html Msg
viewGameScreen title game =
  div [] [
    button [onClick BackToMain] [text "Back"],
    span [] [text title],
    hr [] [],
    Html.App.map PlayGame (viewGame game)
  ]

viewGame : Game -> Html GameMsg
viewGame game =
  case game of
    IntroGame model      -> Game1.view model |> Html.App.map IntroGameMsg
    DontCheatGame model  -> Game2.view model |> Html.App.map DontCheatGameMsg
