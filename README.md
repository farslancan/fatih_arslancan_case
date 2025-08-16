Robot Framework Automation Project

This repository demonstrates a combined API and UI test automation setup using Robot Framework.

API Testing: Implemented with RequestsLibrary.

UI Testing: Implemented with SeleniumLibrary.

Logging: A lightweight logger writes detailed execution logs to a rotating file per run.

Load Testing: An additional JMeter-based scenario is provided for performance validation.
************************************************************************************

Project Structure
.
├── Tests/               # Test suites
│   ├── API/             # API test cases
│   └── FE/              # UI test cases
├── Resources/           # Shared resources and variables
│   └── Properties.resource
├── results/             # Test execution reports
├── requirements.txt     # Project dependencies
└── LoadTest/            # JMeter load testing assets (excluded from repo)
************************************************************************************

Setup
1. Create a virtual environment: python -m venv .venv
2. 2. Install dependencies: pip install -r requirements.txt

************************************************************************************

Running Tests
Run all tests
robot -d results --timestampoutputs Tests

Run only API tests
robot -d results --timestampoutputs Tests/API

Run only UI tests
robot -d results --timestampoutputs Tests/FE

Run by tag
# Examples:
robot -d results -i GET Tests/API
robot -d results -i endpoint_pet Tests/API
robot -d results -i negative Tests/API

Run in parallel (optional)
pabot --outputdir results --processes 4 Tests

************************************************************************************

Shared variables are defined in Resources/Properties.resource:

API_BASE — Base URL for PetStore Swagger (e.g., https://petstore.swagger.io/v2)

REQUEST_TIMEOUT — HTTP request timeout value

BASE_INSIDER_URL — Root URL for Insider website

BASE_INSIDER_CAREER_QA_URL — Careers QA page URL

************************************************************************************
Load Testing (JMeter)

A LoadTest/ folder (not included in the repository) contains:

JMeter .jmx file for n11 search functionality

CSV data files

Exported HTML reports

The .jmx file can be opened in Apache JMeter to execute the load scenario.
Results may be analyzed through the provided HTML report or directly within the JMeter UI.








