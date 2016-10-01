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

startGame : GameId -> Bot -> Task Error String
startGame gameId bot =
  let
    url = bot.url ++ "/" ++ (toString gameId) ++ "/startGame"
  in
    Http.post botDecoder url (startGamePayload bot)

startGamePayload : Bot -> Body
startGamePayload bot =
  let
    payload = JsonEnc.encode 2 <| JsonEnc.object
      [
      ("playerId", JsonEnc.int bot.id)
      , ("countOfPlayers", JsonEnc.int 12)
      , ("weapons", JsonEnc.list (List.map (\loc -> JsonEnc.string <| toString <| loc) bot.weapons) )
      , ("locations",  JsonEnc.list (List.map (\loc -> JsonEnc.string <| toString <| loc) bot.locations) )
      , ("suspects",  JsonEnc.list (List.map (\loc -> JsonEnc.string <| toString <| loc) bot.suspects) )
      ]
  in
    Http.string payload

-- Json decoders -------------------------------------------------------------------------------------------------------
botDecoder : Decoder String
botDecoder =
   ("version" := Json.string)
