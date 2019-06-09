library(tibble)
library(tidyr)
library(readr)
library(purrr)
library(dplyr)

NS.PER.PMCCNTR <- 1000/528

field.read.csv <- function(csv.results, field.name) {

    field.path <- file.path(csv.results, field.name)
    max.checkpoints <- max(count.fields(field.path, sep=",",
                                        quote="\"", comment=""))
    ft <- col_double()
    if (field.name == "name") {
        ft <- col_character()
    }
    cts <- replicate(max.checkpoints, ft)
    read_csv(
        field.path,
        col_names = FALSE,
        col_types = cts,
        na = ""
    )
}

raw.row.index <- function(run, row.tib, field.name) {
    vs <- as_tibble(t(row.tib))
    colnames(vs) <- field.name
    vs$position <- 1:nrow(vs)
    vs$run <- rep(run, nrow(vs))
    vs
}

raw.index <- function(raw, field.name) {
    ## TODO: More elegant / faster implementation. We simply want a row with
    ## every value in the table coupled with its position.
    raw$run <- 1:nrow(raw)
    raw.nested <- raw %>% nest(-run)
    indexed <- map2(raw$run, raw.nested$data,
                    function(run, row.tib) raw.row.index(run, row.tib, field.name))
    bind_rows(indexed)
}

chunk.read.tidy <- function(csv.results) {
    field.names <- list.files(csv.results)
    if ("pmccntr" %in% field.names && !("ns" %in% field.names)) {
        ## Calculate ns from pmccntr.
        pmccntr.raw <- field.read.csv(csv.results, "pmccntr")
        ns.raw <- pmccntr.raw*NS.PER.PMCCNTR
        
        other.names <- field.names[field.names != "pmccntr"]
        other.raws <- lapply(other.names,
                             function(field.name) field.read.csv(csv.results, field.name))

        field.names <- c(other.names, "pmccntr", "ns")
        raws <- c(other.raws, list(pmccntr.raw, ns.raw))
    } else {
        raws <- lapply(field.names,
                       function(field.name) field.read.csv(csv.results, field.name))
    }
    map2(raws, field.names, raw.index) %>%
        reduce(full_join, by = c("run", "position")) %>%
        nest(field.names, -name, .key="values")
}

tcr.write.csv <- function(tcr, path) {
    tcr.csv <- tcr %>%
        unnest(values)
    write_csv(tcr.csv, path)
}

main <- function(output.rds, csv.results) {
    tcr <- chunk.read.tidy(csv.results)
    saveRDS(tcr, file=output.rds)
    tcr.write.csv(tcr, paste(tools::file_path_sans_ext(output.rds), ".csv", sep=""))
}

command.args <- commandArgs(trailingOnly = TRUE)
if (length(command.args) == 2) {
    output.rds <- command.args[[1]]
    csv.results <- command.args[[2]]
    main(output.rds, csv.results)
} else {
    print("Error: Please supply output.rds and csv_results.")
    quit(status = 1)
}
