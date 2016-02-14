module RestDojo.Types (..) where

-- MODEL ---------------------------------------------------------------------------------------------------------------
type alias Player = {
  id : Int,
  url : String
}

type alias GameDescriptor = {
  title: String,
  isDisabled: List Player -> Bool
}
