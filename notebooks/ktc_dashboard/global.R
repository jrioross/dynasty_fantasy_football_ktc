library(tidyverse)
library(shiny)
library(fresh)
library(shinyjs)
library(leaflet)
library(leaflet.extras)
library(sf)
library(DT)
library(shinyDataFilter)
library(plotly)
library(patchwork)
library(shinycssloaders)


ktcPalette <- c("ktcBlue" = "#4DB3E9",
                "ktcMenuBlue" = "#136C9D",
                "ktcSelectionBlue" = "#0B5680",
                "ktcLightGrey" = "#626971",
                "ktcDarkGrey" = "#4A535C",
                "ktcLightRed" = "#EE8590",
                "ktcDarkRed" = "#E85262")

dynasty <- readRDS('../../data/dynasty_full.RDS')
fantasy <- readRDS('../../data/weekly_fantasy.RDS')

