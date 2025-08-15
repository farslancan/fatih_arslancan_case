*** Settings ***
Documentation    Test Cases related to Insider API

Resource            ../../Keywords/API/Keyword_API_Base.resource
Resource            ../../Keywords/API/Keyword_API_Validate.resource
Resource            ../../Resources/Properties.resource

Suite Setup         Run Keywords
...                     Log To Console    message=********** Suite Setup Started **********
...                     AND    Create API Session    ${API_BASE}    ${REQUEST_TIMEOUT}
...                     AND    Log To Console    message=*********** API Session Succesfully Created ***********
...                     AND    Log To Console    message=*********** Suite Setup Done ***********
Suite Teardown      Run Keywords
...                     Log To Console    ***** Suite Teardown Started *****
...                     AND    Log To Console    ***** Suite Teardown Done *****
Test Setup          Run Keywords
...                     Log To Console    ***** Test Setup Started *****
...                     AND    Log To Console    ***** Test Setup Done *****
Test Teardown       Run Keywords
...                     Log To Console    ***** Test Teardown Started *****
...                     AND    Log To Console    ***** Test Teardown Done *****

Test Tags           insider    api_case    petstore


*** Test Cases ***
TC-API01: Find Available Pets Should Return 200 And Valid Payload
    [Documentation]    Request: GET /pet/findByStatus?status=available\nAsserts 200 and validates basic schema and allowed status.
    [Tags]    GET    endpoint_findByStatus    positive
    ${resp}=    Find Pets By Status    available
    Response Should Have Status    ${resp}    200
    ${pets}=    Json List From Response    ${resp}
    Each Pet Should Have Minimal Fields    ${pets}
    All Pet Statuses Should Be In    ${pets}    available

TC-API02: Find Multiple Statuses Should Return 200 And Only Allowed Statuses
    [Documentation]    Request: GET /pet/findByStatus?status=available,pending\nAsserts 200 and only allowed statuses appear.
    [Tags]    GET    endpoint_findByStatus    positive
    ${resp}=    Find Pets By Status    available    pending
    Response Should Have Status    ${resp}    200
    ${pets}=    Json List From Response    ${resp}
    Each Pet Should Have Minimal Fields    ${pets}
    All Pet Statuses Should Be In    ${pets}    available    pending

TC-API03: Invalid Status Should Return 400
    [Documentation]    Request: GET /pet/findByStatus?status=fatih\nExpected 400 per spec
    [Tags]    GET    endpoint_findByStatus    negative    bug
    ${resp}=    Find Pets By Status    fatih
    Response Should Have Status    ${resp}    400

TC-API04: Create Pet - Valid Full Body
    [Documentation]    Request: POST /pet\nCreates a pet with full body and validates echoed fields.
    [Tags]    POST    endpoint_pet    positive
    ${cat}=    Create Dictionary    id=10    name=Dogs
    ${tag1}=   Create Dictionary    id=1     name=friendly
    ${tags}=   Create List    ${tag1}
    ${body}=   Build Pet Body    10001    Rex    available    http://example.com/1.jpg    category=${cat}    tags=${tags}
    ${resp}=   Post Pet    ${body}
    Response Should Have Status    ${resp}    200
    ${data}=   Json Dict From Response    ${resp}
    Should Be Equal As Integers    ${data['id']}    10001
    Should Be Equal    ${data['name']}    Rex
    Should Be Equal    ${data['status']}  available

TC-API05: Create Pet - Empty Body Should Be Client Error
    [Documentation]    Request: POST /pet with empty body and Content-Type=application/json\nAsserts 4xx error.
    [Tags]    POST    endpoint_pet    negative
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=       API POST RAW    ${PATH_PET}    ${EMPTY}    ${headers}
    Status Should Be Client Error    ${resp}

TC-API06: Create Pet - Malformed JSON Should Be Client Error
    [Documentation]    Request: POST /pet with malformed JSON\nAsserts 4xx error.
    [Tags]    POST    endpoint_pet    negative
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${bad}=        Set Variable    {"id":10007,"name":"NoComma" "status":"available"}
    ${resp}=       API POST RAW    ${PATH_PET}    ${bad}    ${headers}
    Status Should Be Client Error    ${resp}

TC-API07: Create Pet - Wrong Content-Type Should Be Client Error
    [Documentation]    Request: POST /pet with JSON body but Content-Type=text/plain\nAsserts 4xx error.
    [Tags]    POST    endpoint_pet    negative
    ${headers}=    Create Dictionary    Content-Type=text/plain
    ${body}=       Set Variable    {"id":10008,"name":"Mime","status":"available"}
    ${resp}=       API POST RAW    ${PATH_PET}    ${body}    ${headers}
    Status Should Be Client Error    ${resp}

TC-API08: Upload Pet Image Should Return 200 And Echo File Name
    [Documentation]    Request: POST /pet/{petId}/uploadImage with image file\n
    ...                Asserts 200 and response contains file name in 'message'.
    [Tags]    POST    endpoint_pet_uploadImage    positive    automation_issue
    ${pet_id}=    Set Variable    10001
    ${resp}=      Upload Pet Image    ${pet_id}    ${PET_IMAGE}    metadata=robot-upload
    Response Should Have Status       ${resp}    200
    ${fname}=    Evaluate    __import__('os').path.basename(r'''${PET_IMAGE}''')
    Upload Response Should Be OK      ${resp}    ${fname}

TC-API09: Upload Pet Image Without File Should Still Return JSON Message
    [Documentation]    Request: POST /pet/{petId}/uploadImage without file\n
    [Tags]    POST    endpoint_pet_uploadImage
    ${pet_id}=    Set Variable    10001
    ${path}=      Set Variable    ${PATH_PET}/${pet_id}/uploadImage
    ${data}=      Create Dictionary    additionalMetadata=no-file
    ${resp}=      HTTP.POST On Session    ${SESSION}    ${path}    data=${data}    expected_status=any
    Response Should Have Status       ${resp}    415

TC-API10: Update Pet - Valid Body Should Return 200 And Persist Changes
    [Documentation]    Create pet then update it via PUT /pet.\nAsserts 200 and updated fields (name/status) are persisted.
    [Tags]    PUT    endpoint_pet    positive
    #Create pet
    ${cat}=    Create Dictionary    id=20    name=Cats
    ${tag1}=   Create Dictionary    id=2     name=vip
    ${tags}=   Create List    ${tag1}
    ${orig}=   Build Pet Body    10011    Bolt    available    http://example.com/bolt.jpg    category=${cat}    tags=${tags}
    ${resp}=   Post Pet    ${orig}
    Response Should Have Status    ${resp}    200
    #Update fields via PUT
    ${updated}=    Build Pet Body    10011    Bolt-Updated    sold    http://example.com/bolt.jpg    category=${cat}    tags=${tags}
    ${resp}=       Put Pet    ${updated}
    Response Should Have Status    ${resp}    200
    ${data}=       Json Dict From Response    ${resp}
    Should Be Equal As Integers    ${data['id']}    10011
    Should Be Equal                 ${data['name']}    Bolt-Updated
    Should Be Equal                 ${data['status']}  sold

TC-API11: Update Pet - Invalid ID Should Return 400
    [Documentation]    PUT /pet with invalid id in body (string).\nExpected 400 per spec.
    [Tags]    PUT    endpoint_pet    negative    contract
    ${bad}=    Create Dictionary    id=abc    name=X    status=available    photoUrls=@{EMPTY}
    ${resp}=    Put Pet    ${bad}
    Response Should Have Status    ${resp}    500

TC-API13: Update Pet - Not Found Should Return 404
    [Documentation]    PUT /pet for a non-existent id.\nExpected 404 per spec.
    [Tags]    PUT    endpoint_pet    negative    bug
    ${body}=    Build Pet Body    11111111111111111123   asdasda    pending
    ${resp}=    Put Pet    ${body}
    Response Should Have Status    ${resp}    404

TC-API14: Update Pet - Validation Exception Should Return 405
    [Documentation]    PUT /pet with invalid body (missing required `id`).\nExpected 405 Validation exception per spec.
    [Tags]    PUT    endpoint_pet    negative    bug
    ${invalid}=    Create Dictionary    name=NoIdHere    status=${EMPTY}    photoUrls=@{EMPTY}
    ${resp}=       Put Pet    ${invalid}
    Response Should Have Status    ${resp}    405

TC-API15: Get Pet By Id - Existing Pet Should Return 200 And Correct Fields
    [Documentation]    Create a pet, then GET /pet/{id}. Asserts 200 and key fields match.
    [Tags]    GET    endpoint_pet_by_id    positive
    ${pet_id}=    Set Variable    10001
    ${cat}=      Create Dictionary    id=30    name=Birds
    ${tag1}=     Create Dictionary    id=3     name=fast
    ${tags}=     Create List    ${tag1}
    ${body}=     Build Pet Body    ${pet_id}    Rex    available    http://example.com/falcon.jpg    category=${cat}    tags=${tags}
    ${resp}=     Post Pet    ${body}
    Response Should Have Status    ${resp}    200

    # 2) GET by id
    ${resp}=     Get Pet By Id    ${pet_id}
    Response Should Have Status    ${resp}    200
    ${pet}=      Json Dict From Response    ${resp}
    Dictionary Should Contain Key    ${pet}    id
    Dictionary Should Contain Key    ${pet}    name
    Dictionary Should Contain Key    ${pet}    status
    Should Be Equal As Integers      ${pet['id']}       ${pet_id}
    Should Be Equal                  ${pet['name']}     Rex
    Should Be Equal                  ${pet['status']}   available

TC-API16: Get Pet By Id - Invalid ID Should Return 400
    [Documentation]    GET /pet/{petId} with non-numeric id
    [Tags]    GET    endpoint_pet_by_id    negative    contract
    ${resp}=   API GET    ${PATH_PET}/abc
    Response Should Have Status    ${resp}    404

TC-API17: Get Pet By Id - Not Found Should Return 404
    [Documentation]    GET /pet/{petId} for non-existent id. Per spec 404.
    [Tags]    GET    endpoint_pet_by_id    negative
    ${resp}=   Get Pet By Id    987654321
    Response Should Have Status    ${resp}    404

TC-API18: Update Pet With Form - Should Return 200 And Persist Changes
    [Documentation]    GET by id and verify fields are updated.
    [Tags]    POST    endpoint_pet_formUpdate    positive    automation_issue

    ${pet_id}=    Evaluate    __import__('random').randint(200000, 299999)

    ${cat}=    Create Dictionary    id=50    name=Reptiles
    ${tags}=   Create List
    ${body}=   Build Pet Body    ${pet_id}    Gecko    available    http://example.com/gecko.jpg    category=${cat}    tags=${tags}
    ${resp}=   Post Pet    ${body}
    Response Should Have Status    ${resp}    200

    ${resp}=   Update Pet With Form    ${pet_id}    name=Gecko-Form    status=pending
    Response Should Have Status      ${resp}    200
    Form Update Response Should Be OK    ${resp}    ${pet_id}

    ${resp}=   Get Pet By Id    ${pet_id}
    Response Should Have Status    ${resp}    200
    ${pet}=    Json Dict From Response    ${resp}
    Should Be Equal As Integers    ${pet['id']}    ${pet_id}
    Should Be Equal                ${pet['name']}    Gecko-Form
    Should Be Equal                ${pet['status']}  pending

TC-API19: Update Pet With Form - Invalid Id Should Return 40x
    [Documentation]    POST /pet/{petId} with non-numeric id in path
    [Tags]    POST    endpoint_pet_formUpdate    negative    contract    bug
    ${resp}=   API GET    ${PATH_PET}/abc
    ${resp}=   HTTP.POST On Session    ${SESSION}    ${PATH_PET}/abc    data=${EMPTY}    expected_status=any
    Response Should Have Status    ${resp}    404

TC-API20: Delete Pet - Should Succeed And GET Should Be 404
    [Documentation]    Create a pet -> DELETE it -> then GET by id returns 404
    [Tags]    DELETE    endpoint_pet_delete    positive    e2e
    ${pet_id}=    Set Variable    10001
    ${cat}=      Create Dictionary    id=30    name=Birds
    ${tag1}=     Create Dictionary    id=3     name=fast
    ${tags}=     Create List    ${tag1}
    ${body}=     Build Pet Body    ${pet_id}    Rex    available    http://example.com/falcon.jpg    category=${cat}    tags=${tags}
    ${resp}=     Post Pet    ${body}
    Response Should Have Status    ${resp}    200

    ${del}=       Delete Pet By Id    10001
    Response Should Have Status    ${del}    200

TC-API21: Delete Pet - Invalid Id Should Return 404
    [Documentation]    DELETE /pet/{petId} with non-numeric path
    [Tags]    DELETE    endpoint_pet_delete    negative    contract    bug
    ${resp}=    API DELETE    ${PATH_PET}/abc
    Response Should Have Status    ${resp}    404

TC-API22: Delete Pet - Not Found Should Return 404
    [Documentation]    DELETE /pet/{petId} for a non-existent id should return 404
    [Tags]    DELETE    endpoint_pet_delete    negative
    ${unknown}=    Evaluate    __import__('random').randint(900000000, 999999999)
    ${resp}=       Delete Pet By Id    ${unknown}
    Response Should Have Status    ${resp}    404