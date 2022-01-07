#!/usr/bin/env python
# coding: utf-8

# # Imports

# In[1]:


import pandas as pd
from datetime import date, datetime, timedelta
import requests
from bs4 import BeautifulSoup as BS


# # Create yesterday and today variables

# In[2]:


yesterday = date.today()-timedelta(days=1)
today = date.today()


# # Scrape current rankings

# In[3]:


url = 'https://keeptradecut.com/dynasty-rankings?page=0&filters=QB|WR|RB|TE|RDP&format=2#'
response = requests.get(url)
rankingsSoup = BS(response.content)

# Readable construction of dynasty-rankings dataframe

# values lists
rank_list = []
player_list = []
playerhref_list = []
positionrank_list = []
teamabv_list = []
agemessy_list = []
age_list = []
overalltier_list = []
value_list = []

# Relevant divs
playerlines = rankingsSoup.find_all('div', 'onePlayer')

for playerline in playerlines:
    
    # Grab current line's relevant player data
    rank = int(playerline.find('div', {'class':'rank-number'}).find('p').text)
    player = playerline.find('a').text
    playerhref = 'https://keeptradecut.com'+playerline.find('a')['href']
    positionrank = playerline.find('p', {'class':'position'}).text
    teamabv = playerline.find('span', {'class' : 'player-team'}).text
    agemessy = playerline.find('span', {'class' : None}).text
    overalltier = playerline.find('div', 'player-info').find('p').text
    value = int(playerline.find('div', {'class':'value'}).find('p').text)
    
    # Append current line's data to value lists
    rank_list.append(rank)
    player_list.append(player)
    playerhref_list.append(playerhref)
    positionrank_list.append(positionrank)
    teamabv_list.append(teamabv)
    age_list.append(agemessy)
    overalltier_list.append(overalltier)
    value_list.append(value)
    
# dict for df construction
rankings_dict = {
    'rank':rank_list,
    'player':player_list,
    'playerhref':playerhref_list,
    'positionrank':positionrank_list,
    'teamabv':teamabv_list,
    'age':age_list,
    'overalltier':overalltier_list,
    'value':value_list
}

# Convert to DataFrame
current_dynasty_ranks = pd.DataFrame(rankings_dict)


# # Add date column labelling today

# In[4]:


current_dynasty_ranks['date'] = today + timedelta(days = 1)


# # Create historical values df, append new dynasty ranks and historical values to respective CSVs

# In[5]:


current_values = current_dynasty_ranks[['player', 'date', 'value']]

current_dynasty_ranks.to_csv(f'../../data/ktc_historical_dynasty_ranks.csv', mode = 'a', index = False, header = False)
current_values.to_csv(f'../../data/ktc_historical_dynasty_values.csv', mode = 'a', index = False, header = False)

