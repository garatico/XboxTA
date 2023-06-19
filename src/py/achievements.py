# PYTHON IMPORTS
from time import *
from datetime import *
from random import randint

# SELENIUM IMPORTS
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager


def scrape_individual_achievements(urls = []):
    data = []

    options = Options()
    options.add_experimental_option("detach", True)

    driver = webdriver.Chrome(service = Service(ChromeDriverManager().install()),
                          options = options)
    
    for url in urls:
        sleep(randint(3,5))
        driver.get(url)
        game_info = driver.find_element("xpath", "//div[@class='info']")

        game_title = game_info.find_element("xpath", ".//h2/a").text
        game_link = game_info.find_element("xpath", ".//h2/a").get_attribute("href")

        ach_info = driver.find_element("xpath", "//div[@class='ach-panel']")
        ach_title = ach_info.find_element("xpath", ".//span[@class='title']").text
        ach_desc = ach_info.find_element("xpath", ".//following-sibling::p").text
        ach_score = ach_info.find_element("xpath", ".//following-sibling::p").get_attribute("data-bf")

        row_data = {
            "Title": ach_title,
            "Desc": ach_desc,
            "Score": ach_score,
            "Game_URL":game_link,
            "Game_Name":game_title
        }   
        data.append(row_data)
    driver.quit()
    return(data)



