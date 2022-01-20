# Armchair Scouting: Using KeepTradeCut to Track Dynasty Fantasy Football Player Values

## Table of Contents

- [Motivation](#Motivation)
- [Technologies](#Technologies)
- [Data Questions](#Data-Questions)
- [Problems & Hurdles](#Problems-&-Hurdles)
  * [Getting the Data](#Getting-the-Data)
    + [Players and IDs](#Playes-and-IDs)
    + [Calling Timeout](#Calling-Timeout)
  * [Normalizing the Data](#Normalizing-the-Data)
    + [NanNanNaNa, Hey, Hey, Good-bye: Calculating z-scores](#nannannana-hey-hey-good-bye-calculating-z-scores)
    + [Quantity & Quality: The Percent-Volume Problem](#quantity--quality-the-percent-volume-problem)
    + [The Less-Is-More Problem](#The-Less-Is-More-Problem)
    + [Overall (and Overmost) Value](#Overall-and-Overmost-Value)
- [Link to the Dashboard](#Link-to-the-Dashboard)

## Motivation
 <details>
   <summary>Here's why I studied this</summary>

   I’ve kept up with sports for most of my life. As a kid, I used to wake up an hour earlier than I needed to so I could watch a full hour of Sportscenter. I wanted to hear Stuart Scott say things like, “As cool as the other side of the pillow,” and I wanted a fresh stack of stats to share with friends on the playground at school. As I got older, I found that fantasy sports, on top of being an excellent way to keep up with family and friends, offer a special outlet for sports fans, who tend to consume more statistics than the average person: fantasy sports allow sports fans to apply their sports knowledge to *decisions*. The questions of how we make decisions and how we determine value are at the pulse of fantasy sports’ intrigue.

  Fantasy football is the most popular fantasy sport. Most fantasy managers play in *redraft* leagues, where each manager drafts a new team of players every year. Those players acquire fantasy points for accomplishing various in-game feats in their real-life games each week (yards gained by catching or running or throwing, touchdowns caught or run or thrown, field goals kicked, or any number of other options). A manager’s team competes head-to-head against some other manager’s team each week, and the team that scores the most total points wins that week’s matchup. Just as in the NFL, you try to make the playoffs, and then you try to win every match in the playoffs to be that season’s champion.

  *Dynasty* leagues add an additional wrinkle to the structure described above. Instead of getting a new team every year, a manager’s team carries over year to year, and the manager only drafts incoming rookies to add to their team—much like real NFL teams do. This adds a dimension of time and player development to fantasy that redraft leagues simply don’t have. This dimension of time allows managers to think more robustly about player development and oscillations in player value. The market for players is more dynamic, especially because a manager must make decisions about present vs. future values of players and draft picks.

  Given all of that, the savvy dynasty manager benefits from knowing a player’s perceived value at any given point. One of the best tools for gauging this perceived value is the website [KeepTradeCut](https://keeptradecut.com/), which has a contribute-to-consume model where their data of perceived player values is available at the price of answering a question about how you, a user and presumed dynasty player, would rank three players (where the factors of ranking are represented as “Keep” (1st), “Trade” (2nd), “Cut” (3rd)). That information goes into their database of relative ranking among players. The overall highest-ranked player has a score of 9999, and the lowest-ranked player(s) has a score of 0. KeepTradeCut collects this data (separately) for both professional (called *dynasty*) and college (called *devy*) players.

  I want to use KeepTradeCut’s database together with NFL statistics—which I can convert into fantasy data—to help the dynasty fantasy manager not only track players’ perceived value, but contextualize player value given some common measures. At minimum, this would be a dashboard tool that helps the dynasty manager make decisions about which players to acquire and which players to trade away based upon their attributes and value trends.


 </details>

## Data Sources

  - [KeepTradeCut](https://keeptradecut.com/)
  - [nflverse](https://github.com/nflverse)
    * [nflfastR](https://github.com/nflverse/nflfastR)
    * [nfldata](https://github.com/nflverse/nfldata)

## Data Questions

  - Which of the following factors, if any, tend to correlate with an NFL player's [KeepTradeCut](https://keeptradecut.com/) dynasty fantasy football value?
    * College drafted from
    * Overall draft position in the year drafted
    * Position played
    * Height
    * Weight
  - Do the above correlations vary by position?
  - How are dynasty values distributed by position?
  - How does a given player's dynasty value compare to his position over time?
  - How do any two players' dynasty value and fantasy performance compare?
  - Can we see a relationship between a player's dynasty value and fantasy performance over time?

## Technologies

  - Python
    * [Jupyter Notebooks](https://jupyter.org/)
    * [pandas](https://pandas.pydata.org/)
    * [requests](https://docs.python-requests.org/en/latest/)
    * [selenium](https://github.com/SeleniumHQ/selenium/tree/trunk/py)
  - R
    * [RStudio](https://www.rstudio.com/)
    * [tidyverse](https://www.tidyverse.org/)
    * [gganimate](https://gganimate.com/)
    * [plotly](https://plotly.com/r/)
    * [Shiny](https://shiny.rstudio.com/)

## The Process (in which We Trust)

  <details>
    <summary>Scrape & Store</summary>


  </details>

  <details>
    <summary>Automate</summary>


  </details>

  <details>
    <summary>Clean, Prepare, and Re-Store</summary>


  </details>

  <details>
    <summary>Graph</summary>


  </details>

  <details>
    <summary>Build the Shiny App</summary>


  </details>

## Link to the App
Put [the app](www.example.com) to work.
