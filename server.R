# server code for exploration of time series data
# DHC Oct. 25, 2014

# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(forecast)
library(fpp)
library(xts)

# list of datasets - note this needs to match the stuff in ui.R
dataSets<-list(ds=list(dj,strikes,hsales,eggs,pigs,lynx,beer,elec,usmelec,a10),
               dnames=list("dj","strikes","hsales","eggs","pigs","lynx","beer","elec","usmelec","a10"),
               xlab=c("Day","Year","Year","Year","Year","Year","Year","Year","Year","Year"),
               ylab=c("DJI","Strike Count","Thousands of Houses","US Dollars","Number Slaughtered","Number Trapped","Megaliters","Billion kWHr","Billion kWHr","Total Prescriptions"),
               title=c("Dow Jones Index","Number of strikes in the US",
                       "Monthly sales of new one-family houses sold in the USA",
                       "Price of dozen eggs in US","Monthly total number of pigs slaughtered in Victoria, Australia",
                       "Annual numbers of lynx trappings for 1821–1934 in Canada","Monthly Australian beer production",
                       "Australian monthly electricity production","US monthly electricity production",
                       "Monthly anti-diabetic drug sales in Australia"))


shinyServer(function(input, output, session) {
  
  laggedData<-reactive({
    idx<-as.integer(input$dset)
    tData<-dataSets$ds[[idx]]
    
    if(input$log==TRUE){
      tData<-log(tData)
    }
    if(input$seasd>0){
      tData<-diff(tData,12,input$seasd)
    }
    if(input$seqd>0){
      tData<-diff(tData,1,input$seqd)
    }
  })
  
  laggedLabel<-reactive({
    yLab<-""
    if(input$log==TRUE){
      yLab<-paste0(yLab,"Logged ")
    }
    if(input$seasd>0){
      yLab<-paste0(yLab,input$seasd," Seasonal Lags ")
    }
    if(input$seqd>0){
      yLab<-paste0(yLab,input$seqd," Sequential Lags")
    }
    yLab
  })
  
  output$echo <- renderText({
    as.integer(input$auto)
  })
  
  output$rawPlot <- renderPlot({
    # plot the time series data in raw form
    idx<-as.integer(input$dset)
    oData<-dataSets$ds[[idx]]
    plot(oData,xlab=dataSets$xlab[[idx]],ylab=dataSets$ylab[[idx]],main=dataSets$title[[idx]])
    
  })
  
  output$diffPlot <- renderPlot({
    # plot the time series data after differencing and logging
    idx<-as.integer(input$dset)
    tData<-laggedData()
    yLab<-laggedLabel()
    plot(tData,xlab=dataSets$xlab[[idx]],ylab=yLab,main=c("Differenced ",dataSets$title[[idx]]))
    
  })
  
  output$aboutData<-renderDataTable({
    as.data.frame(as.xts(dataSets$ds[[as.integer(input$dset)]]))
  })

  output$tsPlot1<-renderPlot({
    # tsdisplay of original data
    idx<-as.integer(input$dset)
    oData<-dataSets$ds[[idx]]
    tsdisplay(oData,ylab=dataSets$ylab[[idx]],main=dataSets$title[[idx]])
  })
  
  output$tsPlot2<-renderPlot({
    # tsdisplay of differenced data
    idx<-as.integer(input$dset)
    tData<-laggedData()
    yLab<-laggedLabel()
    tsdisplay(tData,ylab=yLab,main=c("Differenced ",dataSets$title[[idx]]))
  })
  
  output$acfPlot <- renderPlot({
    # plot the Auto Correlation function for the original and differenced data
    idx<-as.integer(input$dset)
    oData<-dataSets$ds[[idx]]
    tData<-laggedData()
    par(mfrow=c(1,2))
    Acf(oData,main=dataSets$title[[idx]])
    Acf(tData,main=c("Differenced ",dataSets$title[[idx]]))
  })
  
  arimaFit<-reactive({
    idx<-as.integer(input$dset)
    if(input$a_diff == TRUE){
      oData<-laggedData()
    }else{
      oData<-dataSets$ds[[idx]]
    }
    
    if(input$auto==TRUE){
      fit <- auto.arima(oData, seasonal=input$aseas)
    } else {
      fit<-  Arima(oData, order = c(input$p, input$d, input$q), seasonal = c(input$P, input$D, input$Q))
    }   
    fit
  })
  
  output$arimaPlot <- renderPlot({
    idx<-as.integer(input$dset)
    fit<-arimaFit() 
    incl=as.integer(input$incl)
    if(incl==0){
      plot(forecast(fit, h=input$h_int),ylab=dataSets$ylab[[idx]])
    }else{
      plot(forecast(fit, h=input$h_int),include=incl,ylab=dataSets$ylab[[idx]])
    }
  })
  
  output$residualPlot<-renderPlot({
    fit<-arimaFit()
    tsdisplay(residuals(fit),main="Residuals from Arima Forecast")
  })
})
