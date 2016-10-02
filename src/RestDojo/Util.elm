module RestDojo.Util exposing (zipAsLongest)


zipAsLongest : List a -> List b -> List (a, b)
zipAsLongest shorter longer =
    zipAsLongestP [] shorter shorter longer

zipAsLongestP : List (a, b) -> List a -> List a -> List b -> List (a, b)
zipAsLongestP acc origShorter shorter longer =
  case longer of
    l::ls ->
        case shorter of
          s::ss -> zipAsLongestP ((s, l) :: acc) origShorter ss ls
          []  -> zipAsLongestP acc origShorter origShorter longer
    [] -> acc
