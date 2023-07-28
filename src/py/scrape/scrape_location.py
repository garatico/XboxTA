# GOAL: Scrape true achievements profiles
import os
from time import *
from datetime import *

import pandas as pd
import numpy as np
from random import randint

from src.py.scrape.scrape_gamer_achievements import *

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager

from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import StaleElementReferenceException, TimeoutException, NoSuchElementException


def scrape_gamer_location(gamertag_url):
    options = Options()
    options.add_experimental_option("detach", True)
    options.add_argument("--headless")  # Run the browser in headless mode
    options.add_argument("--disable-gpu")  # Disable GPU acceleration
    options.page_load_strategy = 'normal' # Set page load strategy to "eager"

    driver = webdriver.Chrome(service = Service(ChromeDriverManager().install()), options = options)
    driver.implicitly_wait(5)   # Set implicit wait time to 10 seconds
    
    driver.get(f'{gamertag_url}')
    driver.minimize_window()
    wait = WebDriverWait(driver, 10)  # Set a maximum wait time of 15 seconds

    try:
        # Find the img element and get the src, alt, and title attributes
        img_element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "span.title > a.header-icon > img")))
        img_src = img_element.get_attribute("src")
        img_alt = img_element.get_attribute("alt")
        img_title = img_element.get_attribute("title")
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        img_src = "None"
        img_alt = "None"
        img_title = "None"

    # Check if achievements and games files exist for the profile
    gamertag = gamertag_url.split("/")[-1]
    achievements_file = f"./data/gamer/achievements/{gamertag}_achievements.csv"
    games_file = f"./data/gamer/games/{gamertag}_games.csv"

    if os.path.exists(achievements_file) and os.path.exists(games_file):
        # Get the latest timestamps from the manifest
        manifest_file = "./data/manifest/gamer_manifest.csv"
        manifest_df = pd.read_csv(manifest_file)

        if gamertag in manifest_df['GamerTag'].values:
            # Update the manifest with the metrics data
            manifest_df.loc[manifest_df['GamerTag'] == gamertag, 'Location Last Scraped'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            manifest_df.loc[manifest_df['GamerTag'] == gamertag, 'LocationSrc'] = img_src
            manifest_df.loc[manifest_df['GamerTag'] == gamertag, 'LocationAlt'] = img_alt
            manifest_df.loc[manifest_df['GamerTag'] == gamertag, 'LocationTitle'] = img_title

            # Save the updated manifest
            manifest_df.to_csv(manifest_file, index=False)


def scrape_all_gamer_locations():
    manifest_file = "./data/manifest/gamer_manifest.csv"
    manifest_df = pd.read_csv(manifest_file)

    for index, row in manifest_df.iterrows():
        gamertag_url = row['Link']
        scrape_gamer_location(gamertag_url)

    print("Location update complete.")

