% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DensityView.R
\docType{methods}
\name{DensityView}
\alias{DensityView}
\title{Density plot for gene beta scores in Control and Treatment}
\usage{
DensityView(beta, samples = NULL, main = NULL, xlab = "Beta Score",
  filename = NULL, width = 5, height = 4, ...)
}
\arguments{
\item{beta}{Data frame, including \code{samples} as columns.}

\item{samples}{Character, specifying sample names in \code{beta}.}

\item{main}{As in 'plot'.}

\item{xlab}{As in 'plot'.}

\item{filename}{Figure file name to create on disk. Default filename="NULL", which means
don't save the figure on disk.}

\item{width}{As in ggsave.}

\item{height}{As in ggsave.}

\item{...}{Other available parameters in ggsave.}
}
\value{
An object created by \code{ggplot}, which can be assigned and further customized.
}
\description{
Plot the density of gene beta scores in two samples.
}
\examples{
data(MLE_Data)
# Read beta score from gene summary table in MAGeCK MLE results
dd = ReadBeta(MLE_Data, organism="hsa")
DensityView(dd, samples=c("D7_R1", "D7_R2", "PLX7_R1", "PLX7_R2"))
#or
DensityView(dd[, c("D7_R1", "D7_R2", "PLX7_R1", "PLX7_R2")])

}
\seealso{
\code{\link{ViolinView}}
}
\author{
Wubing Zhang
}
