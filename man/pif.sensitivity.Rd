% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pif_sensitivity.R
\name{pif.sensitivity}
\alias{pif.sensitivity}
\title{Potential Impact Fraction Sensitivity Analysis plot}
\usage{
pif.sensitivity(X, thetahat, rr, cft = NA, method = "empirical",
  weights = rep(1/nrow(as.matrix(X)), nrow(as.matrix(X))), nsim = 50,
  mremove = min(nrow(as.matrix(X))/2, 100), adjust = 1, n = 512,
  ktype = "gaussian", bw = "SJ", ylab = "PIF",
  xlab = "Number of randomly deleted observations for X",
  legendtitle = "Sensitivity Analysis",
  title = "Potential Impact Fraction (PIF) Sensitivity Analysis",
  colors = c("red", "deepskyblue", "gray75", "gray25"),
  check_exposure = TRUE, check_rr = TRUE, check_integrals = TRUE,
  is_paf = FALSE)
}
\arguments{
\item{X}{Random sample (\code{data.frame}) which includes exposure 
and covariates or sample \code{mean} if \code{"approximate"} method is 
selected.}

\item{thetahat}{Asymptotically consistent or Fisher consistent estimator
(\code{vector}) of \code{theta} for the
 Relative Risk function.}

\item{rr}{\code{function} for Relative Risk which uses parameter 
\code{theta}. The order of the parameters should be \code{rr(X, theta)}.


\strong{**Optional**}}

\item{cft}{\code{function} \code{cft(X)} for counterfactual. Leave empty for 
the Population Attributable Fraction \code{\link{paf}} where 
counterfactual is that of a theoretical minimum risk exposure 
\code{X0} such that \code{rr(X0,theta) = 1}.}

\item{method}{Either \code{"empirical"} (default), \code{"kernel"} or 
\code{"approximate"}. For details on estimation methods see 
\code{\link{pif}}.}

\item{weights}{Normalized survey \code{weights} for the sample \code{X}.}

\item{nsim}{Integer with number of samples to include (for each removal)
in order to conduct sensitivity analysis. See details for additional information.}

\item{mremove}{Limit number of measurements of \code{X} to remove when
resampling. See details for additional information.}

\item{adjust}{Adjust bandwith parameter (for \code{"kernel"} 
method) from \code{\link[stats]{density}}.}

\item{n}{Number of equally spaced points at which the density (for 
\code{"kernel"} method) is to be estimated (see 
\code{\link[stats]{density}}).}

\item{ktype}{\code{kernel} type:  \code{"gaussian"}, 
\code{"epanechnikov"}, \code{"rectangular"}, \code{"triangular"}, 
\code{"biweight"}, \code{"cosine"}, \code{"optcosine"} (for \code{"kernel"}
method). Additional information on kernels in \code{\link[stats]{density}}.}

\item{bw}{Smoothing bandwith parameter (for 
\code{"kernel"} method) from \code{\link[stats]{density}}. Default 
\code{"SJ"}.}

\item{ylab}{\code{string} label for the Y-axis of the plot.}

\item{xlab}{\code{string} label for the X-axis of the plot.}

\item{legendtitle}{\code{string} title for the legend of plot.}

\item{title}{\code{string} title of plot.}

\item{colors}{\code{string} vector with colours for plots.}

\item{check_exposure}{\code{boolean}  Check that exposure \code{X} is 
positive and numeric.}

\item{check_rr}{\code{boolean} Check that Relative Risk function 
\code{rr} equals \code{1} when evaluated at \code{0}.}

\item{check_integrals}{\code{boolean}  Check that counterfactual \code{cft} 
and relative risk's \code{rr} expected values are well defined for this 
scenario.}

\item{is_paf}{Boolean forcing evaluation of \code{\link{paf}}. This forces
the \code{\link{pif}} function ignore the inputed counterfactual and set it to the
theoretical minimum risk value of \code{1}.}
}
\value{
plotpif      \code{\link[ggplot2]{ggplot}} object plotting a
  sensitivity analysis of \code{\link{pif}}.
}
\description{
Function that plots a sensitivity analysis for the Potential 
  Impact Fraction \code{\link{pif}} by checking how estimates vary when reducing 
  the exposure's sample \code{X}.
}
\details{
\code{pif.sensitivity} conducts a sensitivity analysis of the 
  \code{\link{pif}} estimate by removing \code{mremove} elements \code{nsim}
  times and re-estimating \code{\link{pif}} with the reduced sample.
}
\examples{
\dontrun{
#Example 1
#------------------------------------------------------------------
set.seed(3284)
X  <- data.frame(Exposure = rnorm(250,3)) #Sample
rr <- function(X,theta){exp(X*theta)}     #Relative risk
theta <- 0.1                              #Estimate of theta

pif.sensitivity(X, thetahat = theta, rr = rr)


#Save file
#require(ggplot2)
#ggsave("My Potential Impact Fraction Sensitivity Analysis.pdf")

#Example 2
#--------------------------------------------------------------
set.seed(3284)
X     <- data.frame(Exposure = rbeta(1000, 1, 0.2))
theta <- c(0.12, 1)
rr    <- function(X, theta){X*theta[1] + theta[2]}
cft   <- function(X){X/2}


#Using empirical method
pif.sensitivity(X, thetahat = theta, rr = rr, cft = cft,
                mremove = 100, nsim = 50, 
                title = "My Sensitivity Analysis for example 1")
                
#Same example with kernel
pif.sensitivity(X, theta, rr = rr, cft = cft,
                 mremove = 100, nsim = 50, method = "kernel", 
                 title = "Sensitivity Analysis for example 1 using kernel")
                 

#Example 3: Plot counterfactual with categorical risks
#------------------------------------------------------------------
set.seed(18427)
X        <- data.frame(Exposure = 
               sample(c("Normal","Overweight","Obese"), 1000, 
                      replace = TRUE, prob = c(0.4, 0.1, 0.5)))
thetahat <- c(1, 1.7, 2)

#Categorical relative risk function
rr <- function(X, theta){

   #Create return vector with default risk of 1
   r_risk <- rep(1, length(X))
   
   #Assign categorical relative risk
   r_risk[which(X == "Normal")]      <- thetahat[1]
   r_risk[which(X == "Overweight")]  <- thetahat[2]
   r_risk[which(X == "Obese")]       <- thetahat[3]
   
   return(r_risk)
}


#Counterfactual of halving the percent of obesity and overweight cases
#to normality
cft <- function(X){

   #Find the overweight and obese individuals
   which_obese <- which(X == "Obese")
   which_over  <- which(X == "Overweight")
   
   #Reduce per.over \% of overweight and per.obese \% of obese
   X[sample(which_obese, floor(length(which_obese)*0.5)),1] <- "Normal"
   X[sample(which_over,  floor(length(which_over)*0.5)),1]  <- "Normal"
   
   return(X)
}


pifplot <- pif.sensitivity(X, thetahat = thetahat, rr = rr, cft = cft, 
                           title = "Sensitivity analysis of PIF for excess-weight",
                           colors = rainbow(4), 
                           legendtitle = "Values", 
                           check_exposure = FALSE, check_rr = FALSE)              
pifplot              

#You can edit pifplot as it is a ggplot object
#require(ggplot2)
#pifplot + theme_classic()
}

}
\seealso{
See \code{\link{pif}} for Potential Impact Fraction estimation, 
  \code{\link{pif.heatmap}} for sensitivity analysis of counterfactual, 
  \code{\link{pif.plot}} for a plot of Potential Impact Fraction as a
  function of the relative risk's parameter \code{theta}.
}
\author{
Rodrigo Zepeda-Tello \email{rzepeda17@gmail.com}

Dalia Camacho-García-Formentí \email{daliaf172@gmail.com}
}
