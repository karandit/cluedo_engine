module RestDojo.Types (..) where

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
