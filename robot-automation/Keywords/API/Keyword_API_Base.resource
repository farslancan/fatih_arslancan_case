*** Settings ***
Documentation    Keyword resource file for keywords related to APIs

Library          RequestsLibrary    WITH NAME    HTTP
Library          Collections
Resource         ../../Resources/Properties.resource


*** Keywords ***
Create API Session
    [Documentation]    Creates a named HTTP session to be reused by API keywords.
    ...                Arguments:
    ...                  - base_url: API base URL (e.g. https://petstore.swagger.io/v2)
    ...                  - timeout: request timeout in seconds
    ...                  - alias: session alias (default: ${SESSION})
    [Arguments]    ${base_url}    ${timeout}=${REQUEST_TIMEOUT}    ${alias}=${SESSION}
    HTTP.Create Session    ${alias}    ${base_url}    timeout=${timeout}
    Set Suite Variable     ${SESSION}   ${alias}

API GET
    [Documentation]    Sends GET to `${path}` with optional query `params`. Returns raw response.
    [Arguments]    ${path}    &{params}
    ${resp}=    HTTP.GET On Session    ${SESSION}    ${path}    params=${params}    expected_status=any
    [Return]    ${resp}

API POST JSON
    [Documentation]    Sends POST to `${path}` with JSON `body` and optional `headers`. Returns raw response.
    ...                `expected_status=any` disables implicit status assertion for negative tests.
    [Arguments]    ${path}    ${body}    ${headers}=${None}
    ${resp}=    HTTP.POST On Session    ${SESSION}    ${path}    json=${body}    headers=${headers}    expected_status=any
    [Return]    ${resp}

API POST RAW
    [Documentation]    Sends POST to `${path}` with raw `data` and optional `headers`. Returns raw response.
    [Arguments]    ${path}    ${data}    ${headers}=${None}
    ${resp}=    HTTP.POST On Session    ${SESSION}    ${path}    data=${data}    headers=${headers}    expected_status=any
    [Return]    ${resp}

API PUT JSON
    [Documentation]    Sends PUT to `${path}` with JSON `body` and optional `headers`. Returns raw response.
    [Arguments]    ${path}    ${body}    ${headers}=${None}
    ${resp}=    HTTP.PUT On Session     ${SESSION}    ${path}    json=${body}    headers=${headers}    expected_status=any
    [Return]    ${resp}

API PUT RAW
    [Documentation]    Sends PUT to `${path}` with raw `data` and optional `headers`. Returns raw response.
    [Arguments]    ${path}    ${data}    ${headers}=${None}
    ${resp}=    HTTP.PUT On Session     ${SESSION}    ${path}    data=${data}    headers=${headers}    expected_status=any
    [Return]    ${resp}

API DELETE
    [Documentation]    Sends DELETE to `${path}` with optional `headers` and query `params`. Returns raw response.
    [Arguments]    ${path}    ${headers}=${None}    &{params}
    ${resp}=    HTTP.DELETE On Session    ${SESSION}    ${path}    params=${params}    headers=${headers}    expected_status=any
    [Return]    ${resp}