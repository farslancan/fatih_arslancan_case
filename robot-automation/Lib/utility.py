import os
import re
import csv
import json
import time
import math
import uuid
import base64
import random
import string
import zipfile
import platform
import secrets
import paramiko
import pandas as pd

from glob import glob  # ✅ only the function
from datetime import datetime, timedelta, timezone
from calendar import monthrange

from robot.api import logger
from robot.api.deco import keyword

from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.firefox import GeckoDriverManager
from webdriver_manager.microsoft import EdgeChromiumDriverManager




@keyword('Get Driver Path')
def get_driver_path_with_browser(browser_name):
    if browser_name.lower() == 'chrome':
        driver_path = ChromeDriverManager().install()
    elif browser_name.lower() == 'firefox':
        driver_path = GeckoDriverManager().install()
    elif browser_name.lower() == 'edge':
        driver_path = EdgeChromiumDriverManager().install()
    return driver_path