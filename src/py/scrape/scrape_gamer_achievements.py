from time import *
from datetime import *
from random import randint

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import StaleElementReferenceException, TimeoutException, NoSuchElementException

def scrape_gamer_achievements(gamertag_url):
    options = webdriver.ChromeOptions()
    options.add_experimental_option("detach", True)
    options.add_argument("--headless")  # Run the browser in headless mode
    options.add_argument("--disable-gpu")  # Disable GPU acceleration
    options.add_argument("--start-maximized")  # Start the browser in a minimized state

    driver = webdriver.Chrome(options = options)
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


