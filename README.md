# FATIH_ARSLANCAN_CASE — Robot Framework Automation Project

This repository demonstrates a mixed **API + UI** test automation setup with **Robot Framework**.  
- **API tests** use `RequestsLibrary`.  
- **UI tests** use `SeleniumLibrary`.  
- A lightweight text logger writes emoji-enhanced lines to a rotating log file per run.

There is also a load-testing note for an **n11 search** scenario (see “Load Testing” below).



> **Load Testing:** A `LoadTest/` folder (not shown here) contains a **JMeter** `.jmx` for the **n11 search functionality**, plus the related **CSV** data file(s) and **HTML** reports.

---

## Setup

# 1) (Recommended) Create a virtual environment
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS/Linux
source .venv/bin/activate

# 2) Install dependencies
pip install -r requirements.txt

## Running Tests

Run from the repo root.

All tests
robot -d results --timestampoutputs Tests

Only API tests
robot -d results --timestampoutputs Tests/API

Only UI tests
robot -d results --timestampoutputs Tests/FE

Tag filtering examples
# API tags include: GET, POST, endpoint_pet, endpoint_findByStatus, negative, positive, smoke, bug
robot -d results -i GET Tests/API
robot -d results -i endpoint_pet Tests/API
robot -d results -i negative Tests/API

Parallel (optional)
pabot --outputdir results --processes 4 Tests


Central Variables

Shared variables live in Resources/Properties.resource:

API_BASE — PetStore Swagger base URL (e.g. https://petstore.swagger.io/v2)

REQUEST_TIMEOUT — HTTP request timeout

BASE_INSIDER_URL — Insider website root

BASE_INSIDER_CAREER_QA_URL — Insider Careers QA page URL



## Load Testing (JMeter)

A LoadTest/ folder (not included here) contains:

*.jmx for n11 search functionality

CSV data files

Exported HTML reports

You can open the JMX in Apache JMeter and run the load scenario; results can be viewed through the provided HTML report or JMeter UI.
