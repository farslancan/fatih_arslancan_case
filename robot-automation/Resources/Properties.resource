*** Settings ***
Documentation    Global/shared variables for UI + API tests.

*** Variables ***
# --- UI ---
${ELEMENT_TIMEOUT}                 60s
${BROWSER_TYPE}                    Chrome
${BASE_INSIDER_URL}                https://useinsider.com/
${BASE_INSIDER_CAREER_QA_URL}      https://useinsider.com/careers/quality-assurance/
${LEVER_PREFIX}                    jobs.lever.co/useinsider/

# --- API ---
${API_BASE}                        https://petstore.swagger.io/v2
${REQUEST_TIMEOUT}                 15
${SESSION}                         api
${PATH_PET}                        /pet
${PATH_FIND_BY_STATUS}             /pet/findByStatus
${ASSETS_DIR}                      ${CURDIR}${/}Resources${/}Assets
${PET_IMAGE}                       ${ASSETS_DIR}${/}pet.jpg