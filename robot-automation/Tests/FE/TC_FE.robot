*** Settings ***
Documentation    Test Cases related to Insider UI

Resource    ../../Keywords/FE/Keyword_Driver.robot
Resource    ../../Keywords/FE/Keyword_Career.robot
Resource    ../../Keywords/FE/Keyword_FE_Base.robot
Resource    ../../Object_Repository/Obj_Library_InsiderHome.resource
Resource    ../../Resources/Properties.resource
Resource    ../../Keywords/Utils/TextLogger.resource

Suite Setup         Run Keywords
...                     Init Text Logger    
...                     AND    Log Info    Suite setup started
...                     AND    Register Keyword To Run On Failure    None
...                     AND    Init Text Logger
...                     AND    Log Info    Suite setup Done
Suite Teardown      Run Keywords
...                     Init Text Logger
...                     AND    Log Info    Suite Teardown started    
...                     AND    Close Text Logger
...                     AND    Close All Browsers
...                     AND    Init Text Logger
...                     AND    Log Info    Suite Teardown Done    
Test Setup          Run Keywords
...                     Init Text Logger    
...                     AND    Log Info    Test setup started
...                     AND    Open Insider UI
Test Teardown       Run Keywords
...                     Init Text Logger    
...                     AND    Log Info    Test Teardown started
...                     AND    Run Keyword If Test Failed    Screenshot
...                     AND    Init Text Logger    
...                     AND    Log Info    Test Teardown started

Test Tags           insider    ui_case


*** Test Cases ***
TC-FE01: Insider Careers - Search QA Jobs
    [Documentation]    Test Case for Insider Careers UI validation
    #1: check Insider home page is opened
    Wait Until Page Contains Element    ${BTN_HOME_NAVBAR}
    #2: click company/career button and check
    # its locations, teams, and life at insider blocks are open or not
    Click Until Popup Element Visible
    ...    xpath=${BTN_COMPANY_NAVBAR}
    ...    xpath=${COMPANY_POPUP}
    Wait And Click Element    ${BTN_CAREERS_COMPANY_POPUP}
    Wait Until Page Contains Element    ${BTN_FIND_JOB}
    Verify Careers Sections Visible
    #3: careers/qa
    Apply Careers Filters And Ensure Jobs Present    
    ...    location=Istanbul, Turkiye    
    ...    department=Quality Assurance
    #4: validate all jobs’ position, department, location 
    Assert Job Cards Match Filters    
    ...    Quality Assurance
    ...    Quality Assurance
    ...    Istanbul, Turkiye
    #5: check view role redirects to the lever form
    Click to View Role And Verify Lever    1    ${lever_prefix}

