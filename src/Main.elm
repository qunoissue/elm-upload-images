module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, button, div, img, text)
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
    , error : Maybe LoadErr
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Nothing Nothing, Cmd.none )



-- UPDATE


type Msg
    = ImageRequested
    | ImageSelected File
    | ImageLoaded (Result LoadErr String)


type LoadErr
    = ErrToUrlFailed
    | ErrInvalidFile


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ImageRequested ->
            ( model
            , Select.file expectedTypes ImageSelected
            )

        ImageSelected file ->
            ( model
            , Task.attempt ImageLoaded
                (guardType file
                    |> Task.andThen File.toUrl
                )
            )

        ImageLoaded result ->
            case result of
                Ok content ->
                    ( { model
                        | image = Just content
                        , error = Nothing
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model
                        | image = Nothing
                        , error = Just error
                      }
                    , Cmd.none
                    )


expectedTypes : List String
expectedTypes =
    [ "image/png", "image/jpg", "image/gif" ]


guardType : File -> Task.Task LoadErr File
guardType file =
    if List.any ((==) <| File.mime file) expectedTypes then
        Task.succeed file

    else
        Task.fail ErrInvalidFile



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick ImageRequested ] [ text "Upload image" ]
        , div
            [ style "color" "red" ]
            [ text <|
                case model.error of
                    Nothing ->
                        ""

                    Just ErrInvalidFile ->
                        "Invalid file"

                    Just ErrToUrlFailed ->
                        "Failed to convert file to URL"
            ]
        , case model.image of
            Nothing ->
                img [] []

            Just content ->
                img
                    [ src content ]
                    []
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
