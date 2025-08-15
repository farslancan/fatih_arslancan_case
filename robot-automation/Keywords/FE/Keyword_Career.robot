*** Settings ***
Documentation    Documentation for Career Keywords used in UI
Resource            Keyword_FE_Base.robot
Resource            ../../Object_Repository/Obj_Library_InsiderHome.resource
Resource            ../../Resources/Properties.resource

*** Variables ***
${BASE_INSIDER_CAREER_QA_URL}       https://useinsider.com/careers/quality-assurance/

*** Keywords ***
Verify Careers Sections Visible
    [Documentation]    Verifies that Careers page sections are visible
    # Life at Insider
    Scroll Element Into View    ${HDR_LIFE_AT_INSIDER}
    Wait Until Element Is Visible    ${HDR_LIFE_AT_INSIDER}

    # Our Locations (slider root + at least one slide)
    Scroll Element Into View    ${LOC_LOCATIONS_SLIDER}
    Wait Until Element Is Visible    ${LOC_LOCATIONS_SLIDES_GLIDE}
    ${slide_count}=    Get Element Count    ${LOC_LOCATIONS_SLIDES_GLIDE}
    Should Be True    ${slide_count} > 0    No slides found in Locations slider

    # Teams heading visible; 'See all teams' link may be hidden by design but should exist in DOM
    Scroll Element Into View    ${HDR_TEAMS}
    Wait Until Element Is Visible    ${HDR_TEAMS}
    Page Should Contain Element    ${BTN_SEE_ALL_TEAMS}

Apply Careers Filters And Ensure Jobs Present
    [Documentation]    Opens Careers (QA) page, applies Department & Location filters (Select2),
    ...                then asserts that the job list is present (count > 0).
    [Arguments]    ${location}    ${department}
    Go To    ${BASE_INSIDER_CAREER_QA_URL}
    Wait And Click Element    ${BTN_SEE_ALL_QA_JOBS}
    Sleep    5s
    Wait Until Page Contains Element    ${FILTER_BY_LOCATION}
    Wait Until Page Contains Element    ${FILTER_BY_DEPARTMENT}
    Wait And Click Element    ${CLEAR_DEPARTMENT_FIELD}
    Wait And Click Element     //li[normalize-space()='${department}']    ${ELEMENT_TIMEOUT}
    Wait And Click Element    ${FILTER_BY_LOCATION}
    Wait And Click Element     //li[normalize-space()='${location}']
    # validate presence of job list
    Wait Until Element Is Visible    ${JOB_LIST_CONTAINER}
    ${job_count}=    Get Element Count    ${JOB_CARD_ITEMS}
    Should Be True    ${job_count} > 0    No job found after filtering


Assert Job Cards Match Filters
    [Documentation]    Verifies that *all* job cards match filters:
    [Arguments]    ${exp_pos}    ${exp_dep}    ${city}
    # Wait list visible and count cards
    Wait Until Element Is Visible    ${JOB_LIST_CONTAINER}    10s
    ${cards}=    Get Element Count    xpath=${QA_JOB_CARDS}
    Should Be True    ${cards} > 0    No job cards found after filtering
    Sleep    5s

    FOR    ${i}    IN RANGE    1    ${cards}+1
        
        ${CARD_N}=    Set Variable    xpath=(${QA_JOB_CARDS})[${i}]
        ${position}=       Wait Until Get Text Succeeds    ${CARD_N}${JOB_TITLE_IN_CARD}
        ${department}=       Wait Until Get Text Succeeds    ${CARD_N}${JOB_DEPT_IN_CARD}
        ${location}=       Wait Until Get Text Succeeds    ${CARD_N}${JOB_LOCATION_IN_CARD}
        Wait Until Page Contains Element    ${BTN_VIEW_ROLE_1}
        Should Contain    ${position}    ${exp_pos}

        Should Be Equal    ${department}    ${exp_dep}

        Should Be Equal    ${location}    ${city}
    END

Click to View Role And Verify Lever
    [Documentation]    Clicks "View Role" on the given job card (default: 1st), switches to new tab,
    ...                verifies URL contains jobs.lever.co/useinsider/ and that "Apply for this job"
    ...                button is present.
    [Arguments]    ${card_index}    ${lever_prefix}
    Wait And Click Element    (${QA_JOB_CARDS})[${card_index}]${JOB_TITLE_IN_CARD}
    # Build locator for the Nth card's button
    ${btn_locator}=    Set Variable    xpath=(${QA_JOB_CARDS})[${card_index}]//a[normalize-space()='View Role']
    Scroll Element Into View    ${btn_locator}
    Wait Until Page Contains Element    ${btn_locator}    ${Element_Timeout}
    Wait Until Element Is Enabled    ${btn_locator}    ${Element_Timeout}
    Wait Until Click Element Succeeds    ${btn_locator}
    Click Element    ${btn_locator}
    # Verify  on Lever and apply button exists
    Wait Until Location Contains    ${lever_prefix}    ${Element_Timeout}  
    Wait Until Page Contains Element    ${BTN_APPLY_FOR_THIS_JOB}