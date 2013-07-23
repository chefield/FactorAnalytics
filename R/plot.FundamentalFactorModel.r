# plot.FundamentalFactorModel.r
# Yi-An Chen
# 7/16/2012



#' plot FundamentalFactorModel object.
#' 
#' Generic function of plot method for fitFundamentalFactorModel.
#' 
#' 
#' @param fit.fund fit object created by fitFundamentalFactorModel.
#' @param which.plot integer indicating which plot to create: "none" will
#' create a menu to choose. Defualt is none. 
#' 1 = "Factor returns",
#' 2 = "Residual plots",
#' 3 = "Variance of Residuals",
#' 4 = "Factor Model Correlation",
#' 5 = "Factor Contributions to SD",
#' 6 = "Factor Contributions to ES",
#' 7 = "Factor Contributions to VaR"
#' @param max.show Maximum assets to plot. Default is 4.
#' #' @param plot.single Plot a single asset of lm class. Defualt is FALSE.
#' @param asset.name Name of the asset to be plotted.
#' @param which.plot.single integer indicating which plot to create: "none"
#' will create a menu to choose. Defualt is none. 
#' 1 = time series plot of actual and fitted values,
#' 2 = time series plot of residuals with standard error bands,
#' 3 = time series plot of squared residuals,
#' 4 = time series plot of absolute residuals,
#' 5 = SACF and PACF of residuals,
#' 6 = SACF and PACF of squared residuals,
#' 7 = SACF and PACF of absolute residuals,
#' 8 = histogram of residuals with normal curve overlayed,
#' 9 = normal qq-plot of residuals.
#' @param legend  Logical. TRUE will plot legend on barplot. Defualt is \code{TRUE}. 
#' @param ...  other variables for barplot method.
#' @author Eric Zivot and Yi-An Chen.
#' @examples
#' 
#' \dontrun{
#' # BARRA type factor model
#' # there are 447 assets  
#' data(stock)
#' # BARRA type factor model
#' data(stock)
#' # there are 447 assets  
#' exposure.names <- c("BOOK2MARKET", "LOG.MARKETCAP") 
#' fit.fund <- fitFundamentalFactorModel(data=data,exposure.names=exposure.names,
#'                                        datevar = "DATE", returnsvar = "RETURN",
#'                                        assetvar = "TICKER", wls = TRUE, 
#'                                        regression = "classic", 
#'                                        covariance = "classic", full.resid.cov = TRUE, 
#'                                        robust.scale = TRUE)
#' 
#' plot(fit.fund)
#' }
#' 
plot.FundamentalFactorModel <- 
function(fit.fund,which.plot=c("none","1L","2L","3L","4L"),max.show=4,
         plot.single=FALSE, asset.name,
         which.plot.single=c("none","1L","2L","3L","4L","5L","6L",
                             "7L","8L","9L"),legend.txt=TRUE,...) 
  {
require(ellipse)
require(PerformanceAnalytics)  
 
if (plot.single == TRUE) {
  
  idx <- fit.fund$data[,fit.fund$assetvar]  == asset.name  
  asset.ret <- fit.fund$data[idx,fit.fund$returnsvar]
  dates <- fit.fund$data[idx,fit.fund$datevar] 
  actual.z <- zoo(asset.ret,as.Date(dates))
  residuals.z <- zoo(fit.fund$residuals[,asset.name],as.Date(dates))
  fitted.z <- actual.z - residuals.z
  t <- length(dates)
  k <- length(fit.fund$exposure.names)
  
  which.plot.single<-menu(c("time series plot of actual and fitted values",
                            "time series plot of residuals with standard error bands",
                            "time series plot of squared residuals",
                            "time series plot of absolute residuals",
                            "SACF and PACF of residuals",
                            "SACF and PACF of squared residuals",
                            "SACF and PACF of absolute residuals",
                            "histogram of residuals with normal curve overlayed",
                            "normal qq-plot of residuals"),
                          title="\nMake a plot selection (or 0 to exit):\n")
  switch(which.plot.single,
         "1L" =  {
           #       "time series plot of actual and fitted values",
         
           plot(actual.z[,asset.name], main=asset.name, ylab="Monthly performance", lwd=2, col="black")
           lines(fitted.z[,asset.name], lwd=2, col="blue")
           abline(h=0)
           legend(x="bottomleft", legend=c("Actual", "Fitted"), lwd=2, col=c("black","blue"))
         },
         "2L"={    
           #       "time series plot of residuals with standard error bands"
           plot(residuals.z[,asset.name], main=asset.name, ylab="Monthly performance", lwd=2, col="black")
           abline(h=0)
           sigma = (sum(residuals.z[,asset.name]^2)*(t-k)^-1)^(1/2)
           abline(h=2*sigma, lwd=2, lty="dotted", col="red")
           abline(h=-2*sigma, lwd=2, lty="dotted", col="red")
           legend(x="bottomleft", legend=c("Residual", "+/ 2*SE"), lwd=2,
                  lty=c("solid","dotted"), col=c("black","red"))     
           
         },   
         "3L"={
           #       "time series plot of squared residuals"
           plot(residuals.z[,asset.name]^2, main=asset.name, ylab="Squared residual", lwd=2, col="black")
           abline(h=0)
           legend(x="topleft", legend="Squared Residuals", lwd=2, col="black")   
         },                
         "4L" = {
           ## time series plot of absolute residuals
           plot(abs(residuals.z[,asset.name]), main=asset.name, ylab="Absolute residual", lwd=2, col="black")
           abline(h=0)
           legend(x="topleft", legend="Absolute Residuals", lwd=2, col="black")
         },
         "5L" = {
           ## SACF and PACF of residuals
           chart.ACFplus(residuals.z[,asset.name], main=paste("Residuals: ", asset.name, sep=""))
         },
         "6L" = {
           ## SACF and PACF of squared residuals
           chart.ACFplus(residuals.z[,asset.name]^2, main=paste("Residuals^2: ", asset.name, sep=""))
         },
         "7L" = {
           ## SACF and PACF of absolute residuals
           chart.ACFplus(abs(residuals.z[,asset.name]), main=paste("|Residuals|: ", asset.name, sep=""))
         },
         "8L" = {
           ## histogram of residuals with normal curve overlayed
           chart.Histogram(residuals.z[,asset.name], methods="add.normal", main=paste("Residuals: ", asset.name, sep=""))
         },
         "9L" = {
           ##  normal qq-plot of residuals
           chart.QQPlot(residuals.z[,asset.name], envelope=0.95, main=paste("Residuals: ", asset.name, sep=""))
         },          
         invisible()  )
  
} else {


    which.plot<-which.plot[1]
    
    if(which.plot=='none') 
      which.plot<-menu(c("Factor returns",
                         "Residual plots",
                         "Variance of Residuals",
                         "Factor Model Correlation",
                         "Factor Contributions to SD",
                         "Factor Contributions to ES",
                         "Factor Contributions to VaR"),
                       title="Factor Analytics Plot \nMake a plot selection (or 0 to exit):\n") 
    
    n <- length(fit.fund$asset.names)
    if (n >= max.show) {
      cat(paste("numbers of assets are greater than",max.show,", show only first",
                max.show,"assets",sep=" "))
      n <- max.show 
    }
    switch(which.plot,
           
           "1L" = {
            factor.names <- colnames(fit.fund$factors)
#             nn <- length(factor.names)
            par(mfrow=c(n,1))
            options(show.error.messages=FALSE) 
            for (i in factor.names[1:n]) {
            plot(fit.fund$factors[,i],main=paste(i," Factor Returns",sep="") )
            }
            par(mfrow=c(1,1))
           }, 
          "2L" ={
            par(mfrow=c(n,1))
            names <- colnames(fit.fund$residuals[,1:n])
            for (i in names) {
            plot(fit.fund$residuals[,i],main=paste(i," Residuals", sep=""))
            }
            par(mfrow=c(1,1))
           },
           "3L" = {
             barplot(fit.fund$resid.variance[c(1:n)],...)  
           },    
           
           "4L" = {
             cor.fm = cov2cor(fit.fund$returns.cov$cov)
             rownames(cor.fm) = colnames(cor.fm)
             ord <- order(cor.fm[1,])
             ordered.cor.fm <- cor.fm[ord, ord]
             plotcorr(ordered.cor.fm[c(1:n),c(1:n)], col=cm.colors(11)[5*ordered.cor.fm + 6])
           },
           "5L" = {
             cov.factors = var(fit.fund$factors)
             names = fit.fund$asset.names
             factor.sd.decomp.list = list()
             for (i in names) {
               factor.sd.decomp.list[[i]] =
                 factorModelSdDecomposition(fit.fund$beta[i,],
                                            cov.factors, fit.fund$resid.variance[i])
             }
             # function to efit.stattract contribution to sd from list
             getCSD = function(x) {
               x$cr.fm
             }
             # extract contributions to SD from list
             cr.sd = sapply(factor.sd.decomp.list, getCSD)
             rownames(cr.sd) = c(colnames(fit.fund$factors), "residual")
             # create stacked barchart
             barplot(cr.sd[,(1:max.show)], main="Factor Contributions to SD",
                     legend.text=legend.txt, args.legend=list(x="topleft"),
                     col=c(1:50),...)
           } ,
           "6L" = {
           factor.es.decomp.list = list()
           names = fit.fund$asset.names
           for (i in names) {
             # check for missing values in fund data
#             idx = which(!is.na(fit.fund$data[,i]))
             idx <- fit.fund$data[,fit.fund$assetvar]  == i  
             asset.ret <- fit.fund$data[idx,fit.fund$returnsvar]
             tmpData = cbind(asset.ret, fit.fund$factors,
                             fit.fund$residuals[,i]/sqrt(fit.fund$resid.variance[i]) )
             colnames(tmpData)[c(1,length(tmpData[1,]))] = c(i, "residual")
             factor.es.decomp.list[[i]] = 
               factorModelEsDecomposition(tmpData, 
                                          fit.fund$beta[i,],
                                          fit.fund$resid.variance[i], tail.prob=0.05)
           }
          
           # stacked bar charts of percent contributions to ES 
           getCETL = function(x) {
             x$cES
           }
           # report as positive number
           cr.etl = sapply(factor.es.decomp.list, getCETL)
           rownames(cr.etl) = c(colnames(fit.fund$factors), "residual")
           barplot(cr.etl[,(1:max.show)], main="Factor Contributions to ES",
                   legend.text=legend.txt, args.legend=list(x="topleft"),
                   col=c(1:50),...)
           },
           "7L" =  {
             factor.VaR.decomp.list = list()
             names = fit.fund$asset.names
             for (i in names) {
               # check for missing values in fund data
               #             idx = which(!is.na(fit.fund$data[,i]))
               idx <- fit.fund$data[,fit.fund$assetvar]  == i  
               asset.ret <- fit.fund$data[idx,fit.fund$returnsvar]
               tmpData = cbind(asset.ret, fit.fund$factors,
                               fit.fund$residuals[,i]/sqrt(fit.fund$resid.variance[i]) )
               colnames(tmpData)[c(1,length(tmpData[1,]))] = c(i, "residual")
               factor.VaR.decomp.list[[i]] = 
                 factorModelVaRDecomposition(tmpData, 
                                            fit.fund$beta[i,],
                                            fit.fund$resid.variance[i], tail.prob=0.05)
             }
             
             
             # stacked bar charts of percent contributions to VaR
             getCVaR = function(x) {
               x$cVaR.fm
             }
             # report as positive number
             cr.var = sapply(factor.VaR.decomp.list, getCVaR)
             rownames(cr.var) = c(colnames(fit.fund$factors), "residual")
             barplot(cr.var[,(1:max.show)], main="Factor Contributions to VaR",
                     legend.text=legend.txt, args.legend=list(x="topleft"),
                     col=c(1:50),...)
           },
           invisible()       
    )         
} 

  
  
} 
  
