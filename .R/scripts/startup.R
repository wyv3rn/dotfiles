options(stringsAsFactors=FALSE)
options(scipen=10)
options(editor="vim")
options(menu.graphics=FALSE)
options(prompt="> ")
options(continue="... ")
options(browser="firefox")

q <- function (save="no", ...) {
  quit(save=save, ...)
}

loadSilent <- function(a.package){
  suppressWarnings(suppressPackageStartupMessages(
    library(a.package, character.only=TRUE)))
}

auto.loads <-c("utils", "track", "ggplot2", "plotly")
invisible(sapply(auto.loads, loadSilent))

histfile <- "~/.R/history"
loadhistory(histfile)
track.history.start(file=histfile)
