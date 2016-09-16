module RestDojo.Types exposing (..)

-- MODEL ---------------------------------------------------------------------------------------------------------------
type alias Player = {
  id : Int,
  url : String
}

type alias GameDescriptor a = {
  title : String,
  isDisabled : List Player -> Bool,
  initModel : List Player -> a
}
