
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

dataList<-c("Dow Jones"=1,
            "Annual Strikes in the US"=2,
            "New Home Sales"=3,
            "Price of eggs"=4,
            "Pigs slaughtered"=5,
            "Lynx trapped"=6,
            "Beer Production"=7,
            "Electricity Generation (Aus)"=8,
            "Electriciy Generation (US)"=9,
            "Antidiabetic Drug Sales"=10)


shinyUI(fluidPage(
  
  # Application title
  titlePanel("Exploring Time Series Data"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput("dset","Select Dataset",choices=dataList),
      h3("Differencing Options"),
      checkboxInput("log","Use Log(x)",FALSE),
      sliderInput("seqd",
                  "Number of sequential lags:",
                  min = 0,
                  max = 3,
                  value = 1),
      sliderInput("seasd",
                  "Number of seasonal lags:",
                  min = 0,
                  max = 3,
                  value = 0),
      hr(),
      h3("ARIMA Forecasts"),
      checkboxInput("auto","Auto ARIMA",TRUE),
      checkboxInput("aseas","Seasonal",TRUE),
      numericInput("p","p","0",min=0),
      numericInput("d","d","0",min=0),
      numericInput("q","q","0",min=0),
      numericInput("P","P","0",min=0),
      numericInput("D","D","0",min=0),
      numericInput("Q","Q","0",min=0)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Differencing",
  #       textOutput("echo"),
          plotOutput("rawPlot"),
          plotOutput("diffPlot")
        ),
      tabPanel("Autocorrelation",
         plotOutput("acfPlot")),
      tabPanel("ARIMA Forecasts",
           plotOutput("arimaPlot"))
      )
    )
  )
)
)