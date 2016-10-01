module RestDojo.Games.Cluedo.API exposing (startGame)

import Http exposing (Error, getString, post, empty)
import Task exposing (Task)
import Json.Decode as Json exposing (..)

import RestDojo.Types exposing (..)

-- API end-points ------------------------------------------------------------------------------------------------------
name: String -> Task Error String
name botUrl =
  Http.getString <| botUrl ++ "/name"

startGame: GameId -> String -> Task Error String
startGame gameId botUrl =
  let
    url = botUrl ++ "/" ++ (toString gameId) ++ "/startGame"
  in
    Http.post botDecoder url Http.empty


-- Json decoders -------------------------------------------------------------------------------------------------------
botDecoder : Decoder String
botDecoder =
   ("version" := Json.string)