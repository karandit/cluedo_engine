module RestDojo.Games.Cluedo.API exposing (Location(..), Suspect(..), Weapon(..), Bot, BotId, State(..), startGame)

import Http exposing (Error, Body, getString, post, empty)
import Task exposing (Task)
import Json.Decode as Json exposing (..)
import Json.Encode as JsonEnc exposing (..)

import RestDojo.Types exposing (..)

-- types ---------------------------------------------------------------------------------------------------------------
type Location =
  Kitchen
  | BallRoom
  | Conservatory
  | DiningRoom
  | BilliardRoom
  | Library
  | Lounge
  | Hall
  | Study

type Suspect =
  MsScarlett
  | ProfPlum
  | MrsPeacock
  | RevGreen
  | ColMustard
  | MrsWhite

type Weapon =
  Candlestick
  | Dagger
  | LeadPipe
  | Revolver
  | Rope
  | Spanner

type State = None
      | WaitingToJoin
      | Joined
      | JoinFailed String

type alias BotId = Int

type alias Bot = {
    id : BotId
    , url : String
    , description : String
    , state : State
    , weapons : List Weapon
    , suspects : List Suspect
    , locations : List Location
  }


-- API end-points ------------------------------------------------------------------------------------------------------
name : String -> Task Error String
name botUrl =
  Http.getString <| botUrl ++ "/name"

startGame : GameId -> String -> Task Error String
startGame gameId botUrl =
  let
    url = botUrl ++ "/" ++ (toString gameId) ++ "/startGame"
  in
    Http.post botDecoder url startGamepayload

startGamepayload : Body
startGamepayload = --{location: Location, suspect: Suspect, weapon: Weapon} =
  let
    weapons = [Revolver, Rope]
    suspects = [RevGreen, MrsWhite]
    locations = [Kitchen, BallRoom, Hall]
    playerId = 1
    countOfPlayers = 3

    payload = JsonEnc.encode 2 <| JsonEnc.object
      [
      ("playerId", JsonEnc.int playerId)
      , ("countOfPlayers", JsonEnc.int countOfPlayers)
      , ("weapons", JsonEnc.list (List.map (\loc -> JsonEnc.string <| toString <| loc) weapons) )
      , ("locations",  JsonEnc.list (List.map (\loc -> JsonEnc.string <| toString <| loc) locations) )
      , ("suspects",  JsonEnc.list (List.map (\loc -> JsonEnc.string <| toString <| loc) suspects) )
      ]
  in
    Http.string payload

-- Json decoders -------------------------------------------------------------------------------------------------------
botDecoder : Decoder String
botDecoder =
   ("version" := Json.string)
