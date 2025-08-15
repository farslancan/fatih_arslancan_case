*** Settings ***
Documentation    Keyword resource file for keywords related to APIs

Library          RequestsLibrary    WITH NAME    HTTP
Library          Collections
Resource         Keyword_API_Base.resource
Resource            ../../Resources/Properties.resource


*** Keywords ***
Response Should Have Status
    [Documentation]    Asserts that response status code equals `${expected}`.
    [Arguments]    ${resp}    ${expected}
    Should Be Equal As Integers    ${resp.status_code}    ${expected}

Status Should Be Client Error
    [Documentation]    Asserts response status is 4xx (client error).
    [Arguments]    ${resp}
    ${c}=    Set Variable    ${resp.status_code}
    Should Be True    ${c} >= 400 and ${c} < 500    Expected 4xx client error, got ${c}

Json Dict From Response
    [Documentation]    Parses response body as JSON and asserts the root is an object (dict). Returns the dict.
    [Arguments]    ${resp}
    ${ns}=        Create Dictionary    resp=${resp}
    ${data}=      Evaluate    __import__('json').loads(resp.text)    ${EMPTY}    ${ns}
    ${ns2}=       Create Dictionary    data=${data}
    ${is_dict}=   Evaluate    isinstance(data, dict)                 ${EMPTY}    ${ns2}
    Should Be True    ${is_dict}    Response root must be a JSON object (dict)
    [Return]    ${data}

Json List From Response
    [Documentation]    Parses response body as JSON and asserts the root is an array (list). Returns the list.
    [Arguments]    ${resp}
    ${ns}=        Create Dictionary    resp=${resp}
    ${data}=      Evaluate    __import__('json').loads(resp.text)    ${EMPTY}    ${ns}
    ${ns2}=       Create Dictionary    data=${data}
    ${is_list}=   Evaluate    isinstance(data, list)                 ${EMPTY}    ${ns2}
    Should Be True    ${is_list}    Response root must be a JSON array (list)
    [Return]    ${data}

Each Pet Should Have Minimal Fields
    [Documentation]    For each pet dict, asserts mandatory fields exist: `id`, `status`. If `name` present, it must be non-empty.
    [Arguments]    ${pets}
    FOR    ${p}    IN    @{pets}
        Dictionary Should Contain Key    ${p}    id
        Dictionary Should Contain Key    ${p}    status
        ${has_name}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${p}    name
        IF    ${has_name}
            ${nm}=    Get From Dictionary    ${p}    name
            Should Not Be Empty    ${nm}
        END
    END

All Pet Statuses Should Be In
    [Documentation]    Asserts each pet's `status` is one of the provided allowed values.
    [Arguments]    ${pets}    @{allowed}
    FOR    ${p}    IN    @{pets}
        ${st}=    Get From Dictionary    ${p}    status
        List Should Contain Value    ${allowed}    ${st}
    END

Build Pet Body
    [Documentation]    Builds a Pet payload. Use varargs for `photo_urls` and kwargs for optional fields:
    ...                ${cat}=Create Dictionary  id=10  name=Dogs
    ...                ${tag}=Create Dictionary  id=1   name=friendly
    ...                ${tags}=Create List  ${tag}
    ...                ${body}=Build Pet Body  10001  Rex  available  http://e/1.jpg  category=${cat}  tags=${tags}
    [Arguments]    ${id}    ${name}    ${status}=available    @{photo_urls}    &{options}
    ${body}=    Create Dictionary    id=${id}    name=${name}    status=${status}    photoUrls=@{photo_urls}
    ${has_cat}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${options}    category
    IF    ${has_cat}
        ${cat}=    Get From Dictionary    ${options}    category
        Set To Dictionary    ${body}    category=${cat}
    END
    ${has_tags}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${options}    tags
    IF    ${has_tags}
        ${tags}=    Get From Dictionary    ${options}    tags
        Set To Dictionary    ${body}    tags=${tags}
    END
    [Return]    ${body}

Find Pets By Status
    [Documentation]    Thin wrapper for GET `/pet/findByStatus`. Multiple statuses allowed.
    [Arguments]    @{statuses}
    ${csv}=    Catenate    SEPARATOR=,    @{statuses}
    ${params}=    Create Dictionary    status=${csv}
    ${resp}=    API GET    ${PATH_FIND_BY_STATUS}    &{params}
    [Return]    ${resp}

Post Pet
    [Documentation]    Thin wrapper for POST `/pet` with JSON body.
    [Arguments]    ${body}
    ${resp}=    API POST JSON    ${PATH_PET}    ${body}
    [Return]    ${resp}

Upload Pet Image
    [Documentation]    POST /pet/{petId}/uploadImage (multipart/form-data).
    ...                - ${pet_id}: Path param
    ...                - ${file_path}
    ...                - ${metadata}
    [Arguments]    ${pet_id}    ${file_path}    ${metadata}=${None}
    ${path}=    Set Variable    ${PATH_PET}/${pet_id}/uploadImage
    ${data}=    Create Dictionary
    Run Keyword If    '${metadata}' != '${None}'    Set To Dictionary    ${data}    additionalMetadata=${metadata}
    ${files}=   Evaluate    {'file': open(r'''${file_path}''','rb')}
    ${resp}=    HTTP.POST On Session    ${SESSION}    ${path}    files=${files}    data=${data}    expected_status=any
    [Return]    ${resp}

Upload Response Should Be OK
    [Documentation]    Upload response JSON {code:int,type:str,message:str}
    [Arguments]    ${resp}    ${expected_filename}=${None}
    ${obj}=    Json Dict From Response    ${resp}
    Dictionary Should Contain Key    ${obj}    code
    Dictionary Should Contain Key    ${obj}    type
    Dictionary Should Contain Key    ${obj}    message
    Should Be Equal As Integers    ${obj['code']}    200
    Run Keyword If    '${expected_filename}' != '${None}'    Should Contain    ${obj['message']}    ${expected_filename}

Put Pet
    [Documentation]    Thin wrapper for PUT `${PATH_PET}` with JSON body (update existing pet).
    [Arguments]    ${body}
    ${resp}=    API PUT JSON    ${PATH_PET}    ${body}
    [Return]    ${resp}

Get Pet By Id
    [Documentation]    GET `${PATH_PET}/{id}` and return raw response.
    [Arguments]    ${id}
    ${path}=    Set Variable    ${PATH_PET}/${id}
    ${resp}=    API GET    ${path}
    [Return]    ${resp}

Status Should Be In
    [Documentation]    Asserts response.status_code is in one of the provided codes.
    [Arguments]    ${resp}    @{codes}
    ${c}=    Set Variable    ${resp.status_code}
    List Should Contain Value    ${codes}    ${c}

Update Pet With Form
    [Documentation]    POST ${PATH_PET}/{petId} with form-data fields `name` and/or `status`.
    [Arguments]    ${pet_id}    ${name}=${None}    ${status}=${None}
    ${path}=    Set Variable    ${PATH_PET}/${pet_id}
    ${data}=    Create Dictionary

    IF    $name is not None and $name != ''
        Set To Dictionary    ${data}    name=${name}
    END
    IF    $status is not None and $status != ''
        Set To Dictionary    ${data}    status=${status}
    END

    ${resp}=    HTTP.POST On Session    ${SESSION}    ${path}    data=${data}    expected_status=any
    [Return]    ${resp}

Form Update Response Should Be OK
    [Documentation]    Validates Petstore form update response (JSON: {code:int,type:str,message:str}).
    [Arguments]    ${resp}    ${pet_id}
    ${obj}=    Json Dict From Response    ${resp}
    Dictionary Should Contain Key    ${obj}    code
    Dictionary Should Contain Key    ${obj}    type
    Dictionary Should Contain Key    ${obj}    message
    Should Be Equal As Integers      ${obj['code']}    200
    Should Contain                   ${obj['message']}    ${pet_id}

Delete Pet By Id
    [Documentation]    Thin wrapper for DELETE `/pet/{petId}`; optional `api_key` header.
    [Arguments]    ${pet_id}    ${api_key}=${None}
    ${path}=    Set Variable    ${PATH_PET}/${pet_id}
    ${headers}=    Create Dictionary
    IF    $api_key is not None and $api_key != ''
        Set To Dictionary    ${headers}    api_key=${api_key}
    END
    ${resp}=    API DELETE    ${path}    ${headers}
    [Return]    ${resp}

Delete Response Should Be OK
    [Documentation]    For success deletes petstore usually returns JSON `{code:200, type, message}` with `message` containing id.
    [Arguments]    ${resp}    ${pet_id}
    ${obj}=    Json Dict From Response    ${resp}
    Dictionary Should Contain Key    ${obj}    code
    Should Be Equal As Integers      ${obj['code']}    200
    Should Contain                   ${obj['message']}    ${pet_id}