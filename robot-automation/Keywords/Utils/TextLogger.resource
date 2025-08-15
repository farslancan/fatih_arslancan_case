*** Settings ***
Library    DateTime
Library    OperatingSystem
Library    BuiltIn

*** Variables ***
${LOG_DIR}          logs                   
${LOG_DATE_FMT}     %Y%m%d                 
${LOG_TIME_FMT}     %Y-%m-%d %H:%M:%S      

*** Keywords ***
Init Text Logger
    [Arguments]        ${log_dir}=${LOG_DIR}    ${file_prefix}=log
    ${date}=           Get Current Date    result_format=${LOG_DATE_FMT}
    Create Directory   ${log_dir}
    ${LOG_FILE}=       Set Variable    ${log_dir}/${file_prefix}_${date}.log
    Set Suite Variable    ${TEXT_LOG_FILE}    ${LOG_FILE}
    ${now}=            Get Current Date    result_format=${LOG_TIME_FMT}
    Append To File     ${TEXT_LOG_FILE}    ===== Run started ${now} =====\n

Log At Level
    [Arguments]    ${level}    ${message}
    ${now}=        Get Current Date    result_format=${LOG_TIME_FMT}
    ${icon}=       Set Variable    ${EMPTY}
    IF    '${level}'=='INFO'
        ${icon}=   Set Variable    ✅
    ELSE IF    '${level}'=='WARN'
        ${icon}=   Set Variable    ⚠️
    ELSE IF    '${level}'=='ERROR'
        ${icon}=   Set Variable    ❌
    ELSE IF    '${level}'=='DEBUG'
        ${icon}=   Set Variable    🔄
    END
    ${line}=       Set Variable    ${now} [${level}] ${icon} ${message}\n
    Append To File    ${TEXT_LOG_FILE}    ${line}
    Log            ${icon} ${message}    ${level}

Log Info
    [Arguments]    ${message}
    Log At Level    INFO    ${message}

Log Warn
    [Arguments]    ${message}
    Log At Level    WARN    ${message}

Log Error
    [Arguments]    ${message}
    Log At Level    ERROR   ${message}

Log Debug
    [Arguments]    ${message}
    Log At Level    DEBUG   ${message}

Close Text Logger
    ${now}=        Get Current Date    result_format=${LOG_TIME_FMT}
    Append To File    ${TEXT_LOG_FILE}    ===== Run finished ${now} =====\n

Log Pass
    [Arguments]    ${message}
    Log Info    ${message}    # ✅

Log Fail
    [Arguments]    ${message}
    Log Error   ${message}    # ❌

Log Retry
    [Arguments]    ${message}
    Log Debug   ${message}    # 🔄

Log Test Result
    ${name}=      Set Variable    ${TEST NAME}
    ${status}=    Set Variable    ${TEST STATUS}
    ${message}=   Set Variable    ${TEST MESSAGE}

    IF    '${status}'=='PASS'
        Log Info    Test PASSED: ${name}
    ELSE
        ${msg_safe}=    Set Variable    ${message}
        Run Keyword If    '${msg_safe}'==''    Set Variable    ${msg_safe}    (no message)
        Log Error   Test FAILED: ${name} | ${msg_safe}
    END