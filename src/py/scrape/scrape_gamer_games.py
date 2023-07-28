from time import *
from datetime import *

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
