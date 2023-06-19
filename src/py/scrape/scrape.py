# GOAL: Scrape true achievements profiles
import os
from time import *
from datetime import *

import pandas as pd
import numpy as np
from random import randint

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager

from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import StaleElementReferenceException, TimeoutException, NoSuchElementException

##### GAMER SCRAPE METHODS #####
def scrape_gamer_achievements(gamertag_url):
    options = Options()
    options.add_experimental_option("detach", True)
    options.add_argument("--headless")  # Run the browser in headless mode
    options.add_argument("--disable-gpu")  # Disable GPU acceleration
    options.add_argument("--start-minimized")  # Start the browser in a minimized state
    options.page_load_strategy = 'normal' # Set page load strategy to "eager"

    driver = webdriver.Chrome(service = Service(ChromeDriverManager().install()), options = options)
    driver.implicitly_wait(1)   # Set implicit wait time to 1 seconds

    driver.get(f'{gamertag_url}/achievements')
    wait = WebDriverWait(driver, 3)  # Set a maximum explicit wait time of 3 seconds

    try:
        last_page_link = wait.until(EC.visibility_of_element_located((By.XPATH, "//li[@class='l']/a[last()]")))
        last_page = int(last_page_link.text)
        print(f"INITIALIZE (ACHIEVEMENT): {gamertag_url}, Total pages: {last_page}")
    except (NoSuchElementException, TimeoutException) as e:
        last_page = 1
        print(f"INITIALIZE (ACHIEVEMENTS): {gamertag_url}, Total pages: {last_page} (Only one page)")

    data = []
    unique_achievements = set()

    for page_num in range(1, last_page + 1):
        sleep(randint(1, 2))
        while True:
            try:
                rows = wait.until(EC.visibility_of_all_elements_located((By.XPATH, "//table[@id='oAchievementList']//tr[position() > 1]")))
                if len(rows) > 0:
                    break  # Exit the loop if elements are found
            except (StaleElementReferenceException) as e:
                print(f"Error occurred: {str(e)}")
                page_num -= 1
                driver.refresh()
                print("Page reloaded.")
        
        for row in rows:
            try:
                achievement_game_url = row.find_element(By.XPATH, ".//td[@class='gamethumb hwrs']/a").get_attribute("href")
                achievement_namedesc = row.find_element(By.XPATH, ".//td[@class='wideachievement']")
                achievement_url = achievement_namedesc.find_elements(By.XPATH, ".//a")[0].get_attribute("href")
                achievement_name = achievement_namedesc.find_elements(By.XPATH, ".//a")[0].text
                achievement_desc = achievement_namedesc.find_element(By.XPATH, ".//span").text
                achievement_score = achievement_namedesc.find_element(By.XPATH, ".//following-sibling::td[2]//span").text
                achievement_earned = row.find_element(By.XPATH, ".//td[@class='date']").text
                ta_score = achievement_namedesc.find_element(By.XPATH, ".//following-sibling::td[1]").text
                ta_ratio = achievement_namedesc.find_element(By.XPATH, ".//following-sibling::td[3]").text

                row_data = {
                    "achievement_game_url": achievement_game_url,
                    "achievement_url": achievement_url,
                    "achievement_name": achievement_name,
                    "achievement_desc": achievement_desc,
                    "achievement_earned": achievement_earned,
                    "achievement_score": achievement_score,
                    "ta_score": ta_score,
                    "ta_ratio": ta_ratio
                }
                # Check for duplicates before adding the achievement
                achievement_key = (achievement_name, achievement_desc, achievement_score, achievement_earned)
                if achievement_key in unique_achievements:
                    continue  # Skip the duplicate achievement
                else:
                    unique_achievements.add(achievement_key)
                data.append(row_data)
            except (StaleElementReferenceException, Exception) as e:
                print(f"Error occurred: {str(e)}")
                page_num -= 1
                break  # Exit the loop and move to the next page
        
        if page_num < last_page:
            link_xpath = f"//a[@onclick=\"AJAXList.Buttons('oAchievementListP','{page_num + 1}');return false;\"]"
            try:
                link = wait.until(EC.visibility_of_element_located((By.XPATH, link_xpath)))
                link.click()
                wait.until(EC.staleness_of(link))
                print(f"PAGE: {page_num} of {gamertag_url} (ACHIEVEMENTS) COMPLETE")
            except TimeoutException:
                print("Timeout exception occurred while navigating to the next page.")
                page_num -= 1  # Decrement page_num to retry the current page
            except Exception as e:
                print(f"Error occurred while navigating to the next page: {str(e)}")
                page_num -= 1  # Decrement page_num to retry the current page
        else:
            print(f"PAGE: {page_num} of {gamertag_url} (ACHIEVEMENTS) COMPLETE")
            print(f"Scraping for {gamertag_url} is complete.")
    driver.close()  # Close the current tab
    return data

def scrape_gamer_games(gamertag_url):
    options = Options()
    options.add_experimental_option("detach", True)
    options.add_argument("--headless")  # Run the browser in headless mode
    options.add_argument("--disable-gpu")  # Disable GPU acceleration
    options.add_argument("--start-minimized")  # Start the browser in a minimized state
    options.page_load_strategy = 'normal' # Set page load strategy to "eager"

    driver = webdriver.Chrome(service = Service(ChromeDriverManager().install()), options = options)
    driver.implicitly_wait(2)   # Set implicit wait time to 2 seconds

    driver.get(f'{gamertag_url}/gamecollection')
    wait = WebDriverWait(driver, 2)  # Set a maximum explicit wait time of 2 seconds

    try:
        last_page_link = wait.until(EC.visibility_of_element_located((By.XPATH, "//li[@class='l']/a[last()]")))
        last_page = int(last_page_link.text)
        print(f"INITIALIZE (GAMES): {gamertag_url}, Total pages: {last_page}")
    except (NoSuchElementException, TimeoutException) as e:
        last_page = 1
        print(f"INITIALIZE (GAMES): {gamertag_url}, Total pages: {last_page} (Only one page)")

    data = []

    for page_num in range(1, last_page + 1):
        sleep(randint(1, 3))

        while True:
            try:
                rows = wait.until(EC.visibility_of_all_elements_located((By.XPATH, "//table[@class='maintable']//tr[position() > 1]")))
                if len(rows) > 0:
                    break  # Exit the loop if elements are found
            except (StaleElementReferenceException) as e:
                print(f"Error occurred: {str(e)}")
                driver.refresh()
                print("Page reloaded.")

        for row in rows:
            try:
                if row.get_attribute("class") == "total":
                    continue  # Skip rows with class "total"
                game_title_element = row.find_element(By.XPATH, ".//td[@class='smallgame']/a")
                game_title = game_title_element.text
                game_url = game_title_element.get_attribute("href")
                game_platform_element = row.find_element(By.XPATH, ".//td[starts-with(@id, 'tdPlatform_')]/img")
                game_platform = game_platform_element.get_attribute("title")
                ownership_element = row.find_element(By.XPATH, ".//td[starts-with(@id, 'tdOwnershipStatus_')]")
                ta_score_element = row.find_element(By.XPATH, ".//td[starts-with(@id, 'tdPlatform_')]/following-sibling::td[@class='score'][1]")
                ta_score = ta_score_element.text
                gs_score_element = row.find_element(By.XPATH, ".//td[starts-with(@id, 'tdPlatform_')]/following-sibling::td[@class='score'][2]")
                gs_score = gs_score_element.text
                achievements_score_element = row.find_element(By.XPATH, ".//td[starts-with(@id, 'tdPlatform_')]/following-sibling::td[@class='score'][3]")
                achievements_score = str(achievements_score_element.text)
                ownership = ownership_element.text
                play_status_element = row.find_element(By.XPATH, ".//td[starts-with(@id, 'tdPlayStatus_')]")
                play_status = play_status_element.text
                contests_element = row.find_element(By.XPATH, ".//td[starts-with(@id, 'tdNotForContests_')]")
                contests = contests_element.text

                time_played_element = row.find_element(By.XPATH, ".//td[@class='date'][1]")
                time_played = time_played_element.text
                started_element = row.find_element(By.XPATH, ".//td[@class='date'][2]")
                started = started_element.text
                completed_element = row.find_element(By.XPATH, ".//td[@class='date'][3]")
                completed = completed_element.text
                last_win_element = row.find_element(By.XPATH, ".//td[@class='date'][4]")
                last_win = last_win_element.text

                row_data = {
                    "game_title": game_title,
                    "game_url": game_url,
                    "game_platform": game_platform,
                    "ta_score": ta_score,
                    "gs_score": gs_score,
                    "achievements_score": achievements_score,
                    "ownership": ownership,
                    "play_status": play_status,
                    "contests": contests,
                    "time_played": time_played,
                    "started": started,
                    "completed": completed,
                    "last_win": last_win
                }
                data.append(row_data)
            except (StaleElementReferenceException, Exception) as e:
                print(f"Error occurred: {str(e)}")
                page_num -= 1  # Decrement page_num to retry the current page
                break  # Exit the loop and move to the next page
        if page_num < last_page:
            link_xpath = f"//a[@onclick=\"AJAXList.Buttons('oGameCollectionP','{page_num + 1}');return false;\"]"
            try:
                link = wait.until(EC.visibility_of_element_located((By.XPATH, link_xpath)))
                link.click()
                wait.until(EC.staleness_of(link))
                print(f"PAGE: {page_num} of {gamertag_url} (GAMES) COMPLETE")
            except TimeoutException:
                print("Timeout exception occurred while navigating to the next page.")
                page_num -= 1  # Decrement page_num to retry the current page
            except Exception as e:
                print(f"Error occurred while navigating to the next page: {str(e)}")
                page_num -= 1  # Decrement page_num to retry the current page
        else:
            print(f"PAGE: {page_num} of {gamertag_url} (GAMES) COMPLETE")
            print(f"Scraping for {gamertag_url} is complete.")
    driver.close()
    return data

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

##### GAMER SCRAPE MULTIPLE #####
def scrape_multiple_gamers_data(gamers, data_type):
    data = []

    for index, gamer in gamers.iterrows():
        url = gamer['Link']
        gamertag = gamer['GamerTag']
        sleep(randint(5, 10))
        # Scrape data based on the specified type
        print(f"GAMER: {gamertag} INITIALIZE ({data_type.upper()})")
        if data_type == "achievements":
            profile_data = scrape_gamer_achievements(url)
        elif data_type == "games":
            profile_data = scrape_gamer_games(url)
        else:
            print(f"Invalid data type: {data_type}")
            continue

        if profile_data:
            profile_df = pd.DataFrame(profile_data)
            profile_df.to_csv(f'./data/gamer/{data_type}/{gamertag}_{data_type}.csv', index=False)
        else:
            print(f"No {data_type} data found for {gamertag}")
    return data
def scrape_random_gamers_data(sample_size=1, data_type="achievements"):
    lb_df = pd.read_csv('./data/leaderboard/leaderboard.csv')
    # Shuffle the rows of the leaderboard dataframe
    sample_df = lb_df.sample(n=sample_size)

    if data_type == "achievements":
        scrape_multiple_gamers_data(sample_df, data_type="achievements")
    elif data_type == "games":
        scrape_multiple_gamers_data(sample_df, data_type="games")
    else:
        print(f"Invalid data type: {data_type}")
def scrape_all_gamer_locations():
    manifest_file = "./data/manifest/gamer_manifest.csv"
    manifest_df = pd.read_csv(manifest_file)

    for index, row in manifest_df.iterrows():
        gamertag_url = row['Link']
        scrape_gamer_location(gamertag_url)

    print("Location update complete.")







