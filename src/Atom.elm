module Atom exposing (class, dropArea, error, imgBox, simpleButton, title)

import Html exposing (Attribute, Html, button, div, img, text)
import Html.Attributes as Attributes exposing (src, type_)
import Html.Events as Events
import Json.Decode exposing (Decoder)
import Layout



-- VIEWS


simpleButton : String -> msg -> Html msg
simpleButton str msg =
    button
        [ Layout.basic
        , class "button"
        , type_ "button"
        , Events.onClick msg
        ]
        [ text str
        ]


title : String -> Html msg
title str =
    div
        [ Layout.wrap ]
        [ div
            [ class "title"
            ]
            [ text str
            ]
        ]


error : String -> Html msg
error str =
    div
        [ Layout.wrap
        , Layout.justifyCenter
        ]
        [ div
            [ class "error"
            ]
            [ text str
            ]
        ]


imgBox : String -> Html msg
imgBox str =
    img
        [ class "imgBox"
        , src str
        ]
        []


dropArea : Decoder msg -> Html msg
dropArea decoder =
    div
        [ class "dropArea"
        , Events.on "drop" decoder
        ]
        [ text "Drag&Drop here" ]



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class name =
    Attributes.class <| "index__" ++ name
