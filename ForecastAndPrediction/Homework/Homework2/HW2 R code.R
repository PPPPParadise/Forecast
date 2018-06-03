library(fpp)

# Data import: click on ???import Dataset??? button 
library(readr)
HW2data<- read_csv("~Beefprice.csv", ";", escape_double = FALSE, trim_ws = TRUE)

# Designate each variable
mydata <- ts(HW2data, start=c(1984,1),end=c(2017,9), frequency=12)
p <- mydata[,3]     			# price
pi <- mydata[,4]        			# pi

# 1. Stationary or integrated? To check it, plot raw and differenced data, draw Acf
par(mfrow=c(2,2))
plot(p, main="(a)")            		# plot p
plot(pi, main="(b)")      		# plot pi
Acf(p, main="(c)")
Acf(pi, main="(d)")       		# Draw Acf for pi, 

# p looks integrated of order 1 since it appears nonstationary but with stationary first difference

# 3. Consider log price 
## 3-(a). Overview with various methods: 
     
     par(mfrow=c(1,1))
     fit1 <- ses(p, h=120) # simple exponential smoothing
     fit2 <- holt(p, h=120, alpha=0.8, beta=0.2) 				# Holt's
     fit3 <- holt(p, h=120, exponential=TRUE, alpha=0.8, beta=0.2) 		# Exponential
     fit4 <- holt(p, h=120, damped=TRUE, alpha=0.8, beta=0.2)      		# additive damped
     fit5 <- holt(p, h=120, exponential=TRUE, damped=TRUE, alpha=0.8, beta=0.2)  # multiplicative damped
     
     plot(fit1, ylab="log price", ylim=c(0,7), flwd=1, plot.conf=FALSE)
     lines(window(p, start=c(2017,10)))
     lines(fit2$mean,col=2)
     lines(fit3$mean,col=3)
     lines(fit4$mean,col=5)
     lines(fit5$mean,col=6)
     legend("topleft", lty=1, pch=1, col=1:6,
            c("data", "SES","Holt's","Exponential",
              "Additive Damped","Multiplicative Damped"))
     
# what you in principle need to do (for all methods) is 
# 1- set a training sample / testing sample split     
# 2- fit best methods for the training sample
# 3- obtain one to three months ahead forecasts over the testing sample
# 4- assess the forecast performance over the testing sample
# 5- select the preferred method
     
# here is an example     
    E <- 250
    P <- 15
    H <- 3
    error <- matrix(nrow = P-H, ncol = H)
     
    for(i in 1:P-H)
    {
      for(hor in 1:H)
      {
        fitholt<-holt(p[1:(E+i-1)],h=hor,alpha = NULL, beta = NULL)
        error[i,hor] <- p[E+i+hor] - forecast(fitholt,h=hor)$mean[hor]
      }
    }
    MSFE <- colMeans(na.omit(error*error))
    MSFE
    
    
# below I only show how to estimate, the correct use of testing/training sample is as
# in the example above     

## 3-(b). fit an AR model to pi over the training sample
     plot(pi)      			# it looks like stationary
     Acf(pi)
     Pacf(pi)      			# it looks like AR(1)
     Arima(pi, c(1,0,0))
     Arima(pi, c(2,0,0))
     Arima(pi, c(3,0,0))
     Arima(pi, c(1,0,1))   		# return lowest BIC value
     Arima(pi, c(2,0,1))   		# return lowest AIC value
     auto.arima(pi, ic = "aicc", max.P = 0, max.Q = 0)       		# find best arima model -> c(1,0,0)
     # P, Q refer to seasonal orders
     
     # forecast pi using Arima(1,0,0)
     fit1 <- Arima(pi, c(1,0,0))
     Acf(residuals(fit1))
     fcast1 <- forecast(fit1, h=3)
     plot(fcast1)
     
# 4. Assess using arima(1,0,0)
     
     pi2<-window(pi,start=c(1984,2), end=c(2006,9))
     fit2 <- Arima(pi2, c(1,0,0))
     fcast2 <- forecast(fit2, h=120)
     accuracy(fcast2, pi)       			# test set & training set
     
     plot(fcast2)
     lines(pi)
     
     # produce pi forecasts for the end of 2017
     fit3 <- Arima(pi, c(1,0,0))
     fcast3 <- forecast(fit3, h=3)       		# forecasts of pi for the end of 2017
     fcast3
     
     
     
     
  