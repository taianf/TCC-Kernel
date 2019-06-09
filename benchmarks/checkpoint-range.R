library(tidyverse)
library(scales)
library(viridis)
library(ggpubr)
library(lemon)
library(Cairo)

checkpoint.range.COLNAMES <-
    c("run", "position.from", "position.to", "name.from", "name.to",
      "name.range", "name.range.str", "values.delta")

## Columns: run, position.from, position.to, name.from, name.to, name.range,
## name.range.str, values.delta
do.chunk.checkpoint.range <- function (data, from, to) {
    from.to <- data %>% filter(name == from) %>%
        full_join(data %>% filter(name == to), by="run",
                  suffix=c(".from", ".to"))

    range.is.minimal <- function(from, to, range) {
        if (is.null(range)) {
            return(FALSE)
        }
        len=nrow(range)
        if (len <= 2) {
            return(TRUE)
        }
        between <- range[2:(len-1),]$name
        is.not.between <- !any(c(from, to) %in% between)
        return(is.not.between)
    }

    name.range <- from.to %>%
        full_join(data, by="run") %>%
        filter(position.from <= position, position <= position.to) %>%
        group_by(run, position.from, position.to) %>%
        nest(name, .key="name.range")

    from.to %>%
        ## Insert NA's for runs where this range was not found.
        complete(run=1:max(data$run), name.from=from, name.to=to) %>%
        ## values.delta
        mutate(values.delta=map2(values.to, values.from, `-`)) %>%
        select(-values.from, -values.to) %>%
        ## Add name.range column.
        left_join(name.range, by=c("run", "position.from", "position.to")) %>%
        ## Remove items where from/to occurs in range.
        filter(pmap_lgl(list(.$name.from, .$name.to, .$name.range), range.is.minimal)) %>%
        ## Create name.range.str
        mutate(name.range.str=map(name.range,
                                  function(t) reduce(t$name, str_c, sep=", "))) %>%
        unnest(name.range.str)
}

## Write everything we can represent into a CSV.
checkpoint.range.write.csv <- function (cr, path) {
    cr.csv <- cr %>%
        unnest(values.delta) %>%
        select(-name.range)
    write_csv(cr.csv, path)
}

main <- function(output.base, tidy.results.rds) {
    from.to <- strsplit(basename(output.base), "-")[[1]]
    from <- from.to[1]
    to <- from.to[2]
    
    all <- readRDS(tidy.results.rds)
    cr <- do.chunk.checkpoint.range(all, from, to)
    
    saveRDS(cr, file=str_c(output.base, ".rds"))
    checkpoint.range.write.csv(cr, str_c(output.base, ".csv"))
}

command.args <- commandArgs(trailingOnly = TRUE)
if (length(command.args) == 2) {
    output.base <- command.args[[1]]
    tidy.results.rds <- command.args[[2]]
    main(output.base, tidy.results.rds)
} else {
    print("Error: Please supply output.base and tidy.results.rds")
    quit(status = 1)
}
