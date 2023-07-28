# PYTHON IMPORTS
from time import *
from datetime import *
from random import randint

import pandas as pd

# SELENIUM IMPORTS
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.keys import Keys

def scrape_save_pagerange(startpage = 0, endpage = 6000, saveafter = 100):
    for i in range(startpage, endpage, saveafter):
        start = i + 1
        end = i + saveafter
        lb_df = pd.DataFrame(scrape_leaderboard_pages(start, end + 1))
        lb_df.to_csv(f"./data/leaderboard/leaderboard_{start}_{end}.csv", index=False)

def scrape_leaderboard_pages(start = 1, end = 20):
    data = []

    options = Options()
    options.add_experimental_option("detach", True)
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')

    driver = webdriver.Chrome(service = Service(ChromeDriverManager().install()),
                          options = options)

    driver.get("https://www.trueachievements.com/leaderboard/gamer/gamerscore")
    driver.maximize_window()

    # Assuming `driver` is already defined
    goto_btn = driver.find_element("css selector", ".goto a")
    goto_btn.click()

    goto_input = driver.find_element("css selector", '.gotopage input')
    goto_input.send_keys(start)
    goto_input.send_keys(Keys.RETURN)

    # replace 11 with the number of pages you want to scrape
    for i in range(start, end):  
        sleep(randint(1,3))
        table = driver.find_element("xpath", "//table[@class='maintable leaderboard']")
        rows = table.find_elements("xpath", ".//tr[position() > 1]")
        # Iterate over the rows in the table and extract the data
        for row in rows:
            pos_stats = row.find_elements("xpath", ".//td[@class='pos']")
            name_stats = row.find_elements("xpath", ".//td[@class='left']")
            score_stats = row.find_elements("xpath", ".//td[@class='score']")
            link = name_stats[0].find_element("xpath", ".//a").get_attribute("href")
    
            row_data = {
                "Position": pos_stats[0].text,
                "GamerTag": name_stats[0].text,
                "Score": score_stats[0].text,
                "Link": link
            }   
            data.append(row_data)
        print(f"PAGE {i}: COMPLETE")
        link = driver.find_element("xpath", f"//a[@onclick=\"Postback('oSiteLeaderboardP','{i+1}');return false;\"]")
        link.click()
    # Close the browser
    driver.quit()
    # Create a DataFrame from the scraped data
    return(data)

