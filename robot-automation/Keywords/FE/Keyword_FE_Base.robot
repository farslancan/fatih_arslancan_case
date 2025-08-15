*** Settings ***
Documentation    Documentation for Common Keywords used in UI
Resource            Keyword_Driver.robot
Resource            ../../Object_Repository/Obj_Library_InsiderHome.resource
Resource            ../../Resources/Properties.resource


*** Keywords ***
Open Insider UI
    [Documentation]    Keyword to Open Insider UI in maximized size browser window.
    [Arguments]    ${url}=${BASE_INSIDER_URL}
    Open Local Browser    url=${url}

Wait Until Scroll Element Into View Succeeds
    [Documentation]    Keyword to wait until scroll element into view succeeds
    ...    \n ``locator``    - locator of the WebElement
    ...    \n ``wait_time`` - set maximum wait time
    [Arguments]    ${locator}    ${retry}=${element_timeout}    ${retry_interval}=0.5s
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}
    ...    Scroll Element Into View    ${locator}

Wait Until Click Element Succeeds
    [Documentation]    Keyword to wait until click element succeeds
    ...    \n ``locator``    - locator of the WebElement
    ...    \n ``wait_time`` - set maximum wait time
    [Arguments]    ${locator}    ${press_key}=${EMPTY}    ${retry}=${element_timeout}    ${retry_interval}=0.5s
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}
    ...    Click Element Center & Edges    ${locator}    ${press_key}

Click Element Center & Edges
    [Documentation]    Keyword to click center, left, and right edges of element
    ...    \n ``locator`` - locator of the WebElement
    ...    \n ``press_key`` - key to be held down while clicking the element
    [Arguments]    ${locator}    ${press_key}=${EMPTY}
    Wait Until Page Contains Element    ${locator}
    ${status}=    Run Keyword And Return Status
    ...    Click Element    ${locator}    ${press_key}
    IF    not ${status}
        ${width}    ${height}=    Get Element Size    ${locator}
        ${right_offset}=    Evaluate    math.floor(${width}/2)
        ${left_offset}=    Evaluate    -${right_offset}
        ${status}=    Run Keyword And Return Status
        ...    Click Element At Coordinates    ${locator}    ${left_offset}    0
        IF    not ${status}
            Click Element At Coordinates    ${locator}    ${right_offset}    0
        END
    END

Wait And Click Element
    [Documentation]    Keyword to wait for element to be visible before clicking the element
    ...    \n ``locator``    locator of the WebElement
    ...    \n ``press_key`` key to be held down while clicking the element
    [Arguments]    ${locator}    ${press_key}=${EMPTY}
    Wait Until Page Contains Element    ${locator}    ${Element_Timeout}
    Wait Until Scroll Element Into View Succeeds    ${locator}
    Wait Until Element Is Visible    ${locator}    ${Element_Timeout}
    Wait Until Element Is Enabled    ${locator}    ${Element_Timeout}
    Wait Until Click Element Succeeds    ${locator}    ${press_key}

Click Until Popup Element Visible
    [Documentation]    Repeatedly click over `hover_locator` until `target_locator` becomes visible.
    [Arguments]    ${hover_locator}    ${target_locator}    ${timeout}=${ELEMENT_TIMEOUT}    ${interval}=300ms
    Wait Until Keyword Succeeds    ${timeout}    ${interval}    Run Keywords
    ...    Wait And Click Element    ${hover_locator}
    ...    AND    Element Should Be Visible    ${target_locator}

Wait Until Press Keys Succeeds
    [Documentation]    Keyword to wait until press keys succeeds
    ...    \n ``locator``    - locator of the WebElement
    ...    \n ``value``    - value to be inputted in WebElement locator
    ...    \n ``wait_time`` - set maximum wait time
    [Arguments]    ${locator}    ${value}    ${retry}=${element_timeout}    ${retry_interval}=0.5s
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}
    ...    Press Keys    ${locator}    ${value}

Wait Until Input Text Succeeds
    [Documentation]    Keyword to wait until input text succeeds
    ...    \n ``locator``    - locator of the WebElement
    ...    \n ``value``    - value to be inputted in WebElement locator
    ...    \n ``wait_time`` - set maximum wait time
    [Arguments]    ${locator}    ${value}    ${retry}=${element_timeout}    ${retry_interval}=0.5s
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}
    ...    Input Text    ${locator}    ${value}

Wait And Input Text
    [Documentation]    Keyword to input text after waiting till object appears and input text
    ...    \n ``locator``    locator of the WebElement
    ...    \n ``text``    text value to be inserted in WebElement
    ...    \n ``wait_in_seconds`` default wait of 30s
    ...    \n ``press_key`` key to be pressed after text is inputted
    ...    \n ``clear_text`` clears existing text prior to inputting text if set to ${True} (DEFAULT: ${False})
    [Arguments]    ${locator}    ${text}    ${press_key}=TAB    ${clear_text}=${False}
    Wait Until Page Contains Element    ${locator}    ${Element_Timeout}
    Wait Until Scroll Element Into View Succeeds    ${locator}
    IF    ${clear_text}
        Wait Until Press Keys Succeeds    ${locator}    CTRL+a+DELETE
    END
    Wait Until Input Text Succeeds    ${locator}    ${text}
    IF    "${press_key}" != "${EMPTY}"
        Wait Until Press Keys Succeeds    None    ${press_key}
        IF    "${press_key}" != "TAB"
            Wait Until Press Keys Succeeds    None    TAB
        END
    END

Get Text And Set Variable
    [Documentation]    Keyword to get text and set variable
    ...    \n ``locator``    - locator of the WebElement
    [Arguments]    ${locator}
    ${get_text_value}=    Get Text    ${locator}
    Set Global Variable    ${TEXT_VALUE}    ${get_text_value}

Wait Until Get Text Succeeds
    [Documentation]    Keyword to wait until get text succeeds
    ...    \n ``locator``    - locator of the WebElement
    ...    \n ``wait_time`` - set maximum wait time
    [Arguments]    ${locator}    ${retry}=${element_timeout}    ${retry_interval}=0.5s
    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}
    ...    Get Text And Set Variable    ${locator}
    RETURN    ${TEXT_VALUE}