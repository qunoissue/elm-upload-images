module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Atom
import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, button, div, img, text)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder)
import Layout
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
    { images : List String
    , error : Maybe LoadErr
    , status : Status
    }


type Status
    = Default
    | Dragover


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model [] Nothing Default, Cmd.none )



-- UPDATE


type Msg
    = ImageRequested
    | ImageSelected (List File)
    | ImageLoaded (Result LoadErr (List String))
    | ChangeStatus Status


type LoadErr
    = ErrToUrlFailed
    | ErrInvalidFile


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ImageRequested ->
            ( model
            , Select.files expectedTypes (\f fs -> ImageSelected (f :: fs))
            )

        ImageSelected files ->
            ( model
            , Task.attempt ImageLoaded <|
                Task.sequence <|
                    List.map
                        (\f ->
                            guardType f
                                |> Task.andThen File.toUrl
                        )
                        files
            )

        ImageLoaded result ->
            case result of
                Ok content ->
                    ( { model
                        | images = content ++ model.images
                        , error = Nothing
                        , status = Default
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model
                        | error = Just error
                        , status = Default
                      }
                    , Cmd.none
                    )

        ChangeStatus status ->
            ( { model
                | status = status
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
    div
        [ Layout.fullHeight
        , Layout.fullWidth
        , Events.preventDefaultOn "dragover" <| Decode.succeed ( ChangeStatus Dragover, True )
        , Events.preventDefaultOn "drop" <| Decode.succeed ( ChangeStatus Default, True )
        , Events.on "dragleave" <| Decode.succeed (ChangeStatus Default)
        ]
        [ div
            [ Layout.wrap
            , Attributes.attribute "aria-dragged" <|
                if model.status == Dragover then
                    "true"

                else
                    "false"
            ]
            [ div []
                [ Atom.title "Upload Images"
                , div
                    [ Layout.wrap ]
                    [ div
                        [ Layout.row ]
                        [ Atom.simpleButton
                            "Upload"
                            ImageRequested
                        , Atom.error <|
                            case model.error of
                                Nothing ->
                                    ""

                                Just ErrInvalidFile ->
                                    "Invalid file"

                                Just ErrToUrlFailed ->
                                    "Failed to convert file to URL"
                        ]
                    ]
                , div [ Layout.wrap ] <|
                    List.map
                        Atom.imgBox
                        model.images
                ]
            ]
        , if model.status == Dragover then
            div
                [ Layout.fullHeight
                , Layout.fullWidth
                , Atom.class "draggedArea"
                ]
                [ Atom.dropArea <|
                    Decode.map
                        ImageSelected
                        filesDecoder
                ]

          else
            div [] []
        ]


filesDecoder : Decoder (List File)
filesDecoder =
    Decode.field "dataTransfer" (Decode.field "files" (Decode.list File.decoder))



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
