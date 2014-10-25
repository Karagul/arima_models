
# Shiny user interface definition for Time Series Exploration
# D. Currie Oct 25, 2014 

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
  tags$head(
    # Include our custom CSS
    includeCSS("styles.css")
  ),
  
  # Application title
  titlePanel("Exploring Time Series Data"),
  
  # Sidebar for main controls
  sidebarLayout(
    sidebarPanel(
      selectInput("dset","Select Dataset",choices=dataList),
      helpText("Select a dataset from the list above",
               "Use the controls below to explore the",
               "effects of differencing and logging."),
      h5("Differencing Options"),
      checkboxInput("log","Use Log(x)",FALSE),
      sliderInput("seqd",
                  "Number of sequential lags:",
                  min = 0,
                  max = 3,
                  value = 1),
      helpText("Sequential lags, or first differences take the",
               "difference between one observation and the next."),
      sliderInput("seasd",
                  "Number of seasonal lags:",
                  min = 0,
                  max = 3,
                  value = 0),
      helpText("Seasonal lags, or M differences take the",
               "difference between one year and the next.")
      
    ),
    
    # Main panel for results
    mainPanel(
      tabsetPanel(
        tabPanel("Differencing",
                 #textOutput("echo"),
                 plotOutput("rawPlot"),
                 helpText("Using the controls at the left, select sequential and seasonal differences with logs to obtain a stationary result.  A stationary series will have no predictable patterns in the long term."),
                 plotOutput("diffPlot")
        ),
        tabPanel("Autocorrelation",
                 #         plotOutput("acfPlot"),
                 plotOutput("tsPlot1"),
                 helpText("These plots of the Autocorrelation Function",
                          "are useful for determining the stationarity of a time series.",
                          "The Acf of stationary data will rapidly decrease to zero, while",
                          "non-stationary series will decrease more slowly."),
                 plotOutput("tsPlot2")
        ),
        tabPanel("ARIMA Forecasts",
                 plotOutput("arimaPlot"),
                 plotOutput("residualPlot"),
                 absolutePanel(id = "controls", class = "modal", fixed = FALSE, draggable = TRUE,
                               top = "auto", left = "auto", right = "68%", bottom = "5%",
                               width = "28%", height = "auto",
                               checkboxInput("auto","Auto ARIMA",TRUE),
                               checkboxInput("a_diff","Use differenced data?",FALSE),
                               numericInput("incl","Data points to show","80",min=0),
                               numericInput("h_int","Intervals to forecast","10",min=1,max=100),
                               conditionalPanel(condition="input.auto==0",
                                                numericInput("p","p","0",min=0),
                                                numericInput("d","d","0",min=0),
                                                numericInput("q","q","0",min=0)
                               ),
                               checkboxInput("aseas","Seasonal",TRUE),
                               conditionalPanel(condition="input.aseas==1 && input.auto==0",
                                                numericInput("P","P","0",min=0),
                                                numericInput("D","D","0",min=0),
                                                numericInput("Q","Q","0",min=0)
                               )
                 )
                 
        ),
        tabPanel("About",
                 includeHTML("doc.html")
                 #               dataTableOutput("aboutData")
        )
      )
    )
    
  )
)
)