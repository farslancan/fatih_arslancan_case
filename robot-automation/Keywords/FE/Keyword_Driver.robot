*** Settings ***
Documentation       Documentation for Driver Keywords used in UI
Library             ../../Lib/utility.py
Library             RPA.Browser.Selenium
Resource            ../../Resources/Properties.resource

*** Keywords ***
Open Local Browser
    [Documentation]    Common Keyword to Initiate Local Browser
    [Arguments]    ${url}    ${local_browser}=${BROWSER_TYPE}
    ${options}=    Get Browser Options
    ...    browser=${local_browser}
    ${driver_path}=    Get Driver Path    browser_name=${local_browser}
    Open Browser
    ...    url=${url}
    ...    browser=${local_browser}
    ...    options=${options}
    ...    executable_path=${driver_path}
    Maximize Browser Window

Get Browser Options
    [Documentation]    Keyword to set browser options
    [Arguments]    ${browser}
    IF    "${browser}" == "Edge"
        ${options}=    Evaluate
        ...    sys.modules['selenium.webdriver'].EdgeOptions()
        ...    sys, selenium.webdriver
    ELSE
        ${options}=    Evaluate
        ...    sys.modules['selenium.webdriver'].ChromeOptions()
        ...    sys, selenium.webdriver
    END
    ${prefs}=    Create Dictionary
    ...    download.directory_upgrade=${True}
    ...    download.prompt_for_download=${False}
    ...    plugins.always_open_pdf_externally=${True}
    ...    safebrowsing.enabled=${False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${options}    set_capability    acceptInsecureCerts    ${TRUE}
    RETURN    ${options}