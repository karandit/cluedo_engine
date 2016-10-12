module RestDojo.Index exposing (..)

import Html exposing (Html, text, a, div, img, nav, ol, li, em)
import Html.Attributes exposing (class, style, href, src, width, height)
import Html.App

import RestDojo.Types exposing (..)

-- MAIN ----------------------------------------------------------------------------------------------------------------
main : Program Never
main =
      Html.App.program {
        init = initModel,
        update = update,
        view = view,
        subscriptions = \_ -> Sub.none}

-- MODEL ---------------------------------------------------------------------------------------------------------------
type alias Model = {
  players: List Player
}

initModel : (Model, Cmd Msg)
initModel = {
  players = [
    {id = 0, color = "#7E5AE2", url = "http://localhost:3001"}
    , {id = 1, color = "#E25A77", url = "http://localhost:3002"}
    , {id = 2, color = "#E25ABC", url = "http://localhost:3003"}
    ]
 } ! []

-- UPDATE --------------------------------------------------------------------------------------------------------------
type Msg =
  NotYet

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
      model ! []


-- VIEW ----------------------------------------------------------------------------------------------------------------
view : Model -> Html Msg
view model =


    div [style [ ("backgroundColor", "#262c37")]] [
      viewBreadcrumbs
      , div [] (List.map viewPlayer model.players)
    ]

viewBreadcrumbs : Html Msg
viewBreadcrumbs =
  nav []
      [ ol [ class "cd-breadcrumb" ]
          [ li []
              [ a [ href "#0" ]
                  [ text "Home" ]
              ]
          , li []
              [ a [ href "#0" ]
                  [ text "Gallery" ]
              ]
          , li []
              [ a [ href "#0" ]
                  [ text "Web" ]
              ]
          , li [ class "current" ]
              [ em []
                  [ text "Project" ]
              ]
          ]
      ]

viewPlayer : Player -> Html Msg
viewPlayer player =
  let
      roundStyle = style [
        ("backgroundColor", "#ffffff"), ("border-radius", "50%"), ("border", "3px solid " ++ player.color)]
  in
    div [] [
      img [src <| "https://robohash.org/" ++ player.url, roundStyle, width 80, height 80] []
      ]
