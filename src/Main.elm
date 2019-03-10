module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, button, img, text)
import Html.Attributes exposing (src, style)
import Html.Events exposing (onClick)
import Task



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { image : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Nothing, Cmd.none )



-- UPDATE


type Msg
    = ImageRequested
    | ImageSelected File
    | ImageLoaded (Result LoadErr String)


type LoadErr
    = ErrToUrlFailed


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ImageRequested ->
            ( model
            , Select.file [ "image/png", "image/jpg", "image/gif" ] ImageSelected
            )

        ImageSelected file ->
            ( model
            , Task.attempt ImageLoaded <| File.toUrl file
            )

        ImageLoaded result ->
            case result of
                Ok content ->
                    ( { model | image = Just content }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | image = Nothing }
                    , Cmd.none
                    )



-- VIEW


view : Model -> Html Msg
view model =
    case model.image of
        Nothing ->
            button [ onClick ImageRequested ] [ text "Upload image" ]

        Just content ->
            img
                [ src content ]
                []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
