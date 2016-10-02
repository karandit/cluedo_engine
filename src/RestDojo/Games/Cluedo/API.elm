module RestDojo.Games.Cluedo.API exposing (Location(..), Suspect(..), Weapon(..), Card(..), Secret, Bot, BotId, State(..), Randomness,
  startGame, gameGenerator)

import Maybe exposing (withDefault)
import Array exposing (Array)
import Http exposing (Error, Body, getString, post, empty)
import Task exposing (Task)
import Json.Decode as Json exposing (..)
import Json.Encode as JsonEnc exposing (..)
import Random exposing (Generator)
import Random.Array as RandomExtra exposing (choose)

import RestDojo.Types exposing (..)

-- types ---------------------------------------------------------------------------------------------------------------
type Location =
  BedRoom
  | Billiards
  | Conservatory
  | Kitchen
  | Library
  | Lounge
  | Stairs
  | Studio
  | TrophyHall

type Suspect =
  ColMustard
  | MrsWhite
  | MsPeacock
  | MsScarlett
  | ProfPlum
  | RevGreen

type Weapon =
  Candlestick
  | IcePick
  | Poison
  | Poker
  | Revolver
  | Shears

type alias Secret = {
  weapon: Weapon
  , location: Location
  , suspect: Suspect
  }

type Card =
  WeaponCard Weapon
  | SuspectCard Suspect
  | LocationCard Location

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

-- Json decoders/encoders ----------------------------------------------------------------------------------------------
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

botDecoder : Decoder String
botDecoder =
   ("version" := Json.string)

-- Random Generator ----------------------------------------------------------------------------------------------------
type alias Randomness = {
    gameId: GameId
    , secret: Secret
  }

gameGenerator: Generator (Randomness, List Card)
gameGenerator =
  let
    suspects = Array.fromList <| [MsScarlett, ProfPlum, MsPeacock, RevGreen, ColMustard, MrsWhite]
    weapons = Array.fromList <| [Candlestick, IcePick, Poison, Poker, Revolver, Shears]
    locations = Array.fromList <| [BedRoom, Billiards, Conservatory, Kitchen, Library, Lounge, Stairs, Studio, TrophyHall]
  in
    Random.map (\(randomness, cards) -> (randomness, Array.toList cards)) <|
    Random.map4 mapToRandomness
      (Random.int 1 Random.maxInt)
      (RandomExtra.choose weapons)
      (RandomExtra.choose suspects)
      (RandomExtra.choose locations)

mapToRandomness: GameId
  -> (Maybe Weapon, Array Weapon)
  -> (Maybe Suspect, Array Suspect)
  -> (Maybe Location, Array Location)
  -> (Randomness, Array Card)
mapToRandomness gameId (maybeWeapon, leftWeapons) (maybeSuspect, leftSuspects) (maybeLocation, leftLocations) =
    let
      randomness = { gameId = gameId
        , secret = {
          weapon = withDefault Revolver maybeWeapon
          , location = withDefault Kitchen maybeLocation
          , suspect = withDefault MrsWhite maybeSuspect
        }
      }
      suspectCards = Array.map SuspectCard leftSuspects
      locationCards = Array.map LocationCard leftLocations
      weaponCards = Array.map WeaponCard leftWeapons
      leftCards = suspectCards `Array.append` locationCards `Array.append` weaponCards
      in
        (randomness, leftCards)
