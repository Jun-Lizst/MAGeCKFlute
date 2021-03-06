% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CellCycleView.R
\docType{methods}
\name{CellCycleView}
\alias{CellCycleView}
\alias{CellCycle,MAGeCKFlute-method}
\title{Estimate cell cycle time for all samples compared to control sample and view.}
\usage{
CellCycleView(beta, ctrlname, treatname, main = NULL, filename = NULL,
  width = 5, height = 4, ...)
}
\arguments{
\item{beta}{Data frame, which has columns of \code{ctrlname} and other samples.}

\item{ctrlname}{A character, specifying the names of control samples.}

\item{treatname}{A character, specifying the name of treatment samples.}

\item{main}{As in 'plot'.}

\item{filename}{Figure file name to create on disk. Default filename="NULL", which means
no output.}

\item{width}{As in ggsave.}

\item{height}{As in ggsave.}

\item{...}{Other available parameters in ggsave.}
}
\value{
An object created by \code{ggplot}, which can be assigned and further customized.
}
\description{
Estimate cell cycle time in different samples by linear fitting of beta scores, and plot fitting lines,
in which x-axis is control beta score and y-axis is beta score of all samples.
}
\examples{
data(MLE_Data)
# Read beta score from gene summary table in MAGeCK MLE results
dd = ReadBeta(MLE_Data, organism="hsa")
CellCycleView(dd, ctrlname = c("D7_R1", "D7_R2"), treatname = c("PLX7_R1", "PLX7_R2"))

}
\author{
Wubing Zhang
}
