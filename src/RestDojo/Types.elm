module RestDojo.Types exposing (..)

-- MODEL ---------------------------------------------------------------------------------------------------------------
type alias Player = {
  id : Int,
  url : String
}

type alias GameDescriptor mdl = {
  title : String,
  isDisabled : List Player -> Bool,
  initModel : List Player -> mdl
}
