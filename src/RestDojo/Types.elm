module RestDojo.Types exposing (..)

-- MODEL ---------------------------------------------------------------------------------------------------------------
type alias GameId = Int

type alias Player = {
  id : Int,
  url : String
}

type alias TileDescriptor mdl = {
  title : String,
  isDisabled : List Player -> Bool,
  initGame : List Player -> mdl
}
