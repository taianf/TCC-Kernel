library(tidyverse)
library(scales)
library(viridis)
library(ggpubr)
library(lemon)
library(Cairo)

## Public
with.tempdir <- function(dst, f) {
    tmp <- tempfile()
    dir.create(tmp)
    f(tmp)
    system(paste("rm", "-rfd", dst))
    system(paste("mv", "-fT", tmp, dst))
}

benchmark.path <- function(benchmark.name) {
    file.path("..", str_c(benchmark.name, ".benchmark"))
}

## Public
benchmark.read.tidy <- function(bname, csdir=file.path("data", bname)) {
    bpath <- benchmark.path(bname)
    readRDS(file.path(bpath, "tidy-results.rds")) %>%
        mutate(benchmark = bname)
}

## Public
checkpoint.range <- function (bname, from, to) {
    bpath <- benchmark.path(bname)
    readRDS(file.path(bpath, "checkpoint-ranges", str_c(from, "-", to, ".rds"))) %>%
        mutate(benchmark = bname)
}


## Util

name.range.contains.any.events <- function (name.range, events) {
    map_lgl(name.range, function (nr) any(events %in% nr$name))
}

## Public
name.range.contains.events <- function (name.range, events) {
    map_lgl(name.range, function (nr) all(events %in% nr$name))
}

## Public
filter.irqs <- function (diff) {
    diff %>% filter(!name.range.contains.any.events(name.range, c("aic5_handle", "handle_irq64")))
}

## Public.
write.key.value.pairs <- function(kvname, data) {
    write_delim(data, str_c(kvname, ".kv"),
                delim = "=",
                col_names = FALSE)
}


## Plotting

plot.path <- function(dir, data.name, plot.type, format="pdf") {
    str_c(file.path(dir, data.name), plot.type, format, sep=".")
}

## Public
plot.save <- function(output.dir, data.name, plot.type, format="pdf",
                      width=297, height=210, units="mm", ...) {
    ## Use cairo_pdf since it supports unicode characters.
    device = ifelse(format == "pdf", cairo_pdf, format)
    ggsave(plot.path(output.dir, data.name, plot.type, format=format),
           device=device,
           width=width,
           height=height,
           units=units,
           ...)
}

## Public.
## diff must have color and linetype fields.
ggplot.ns.discover <- function(output.dir, data.name, labeled.diff, ...) {
    plotable.diff <- labeled.diff %>%
        filter(!is.na(position.from)) %>%
        unnest(values.delta)

    ## Release Memory
    labeled.diff <- NULL

    ## At ~250K rows the following breaks down with 16GB ram.
    ##
    ## ggplot(plotable.diff, aes(x=run, y=ns, color=color, shape=linetype)) +
    ##     geom_point(alpha=0.5) +
    ##     theme(legend.position="bottom",
    ##           legend.direction="vertical",
    ##           legend.justification="left")
    ## plot.save(output.dir, data.name, "scatter", format="png")

    ggplot(plotable.diff, aes(x=ns, linetype=linetype)) +
        stat_ecdf(geom="step", pad=TRUE)
    plot.save(output.dir, data.name, "ecdf.linetype", ...)

    ggplot(plotable.diff, aes(x=ns, color=color)) +
        stat_ecdf(geom="step", pad=TRUE) +
        scale_x_log10()
    plot.save(output.dir, data.name, "ecdf.color.log10", ...)

    ggplot(plotable.diff, aes(x=ns, color=color, linetype=linetype)) +
        geom_freqpoly(binwidth=100, alpha=0.9) +
        scale_y_log10() +
        theme(legend.position="bottom",
              legend.direction="vertical",
              legend.justification="left")
    plot.save(output.dir, data.name, "freqpoly", ...)
}


## Qualitative Vibrant Color Scheme, via
## https://personal.sron.nl/~pault/#qualitativescheme
color.qualitative.blue <- "#0077BB"
color.qualitative.cyan <- "#33BBEE"
color.qualitative.teal <- "#009988"
color.qualitative.red <- "#CC3311"
color.qualitative.red <- "red"
color.qualitative <- c(color.qualitative.blue, color.qualitative.cyan,
                       color.qualitative.teal, "#EE7733", color.qualitative.red,
                       "#EE3377", "#BBBBBB")
scale.fill.qualitative <-
    scale_fill_manual(values = color.qualitative, guide = FALSE)
scale.color.qualitative <-
    scale_color_manual(values = color.qualitative, guide = FALSE)

color.qualitative.softirq <- rep(color.qualitative.blue, 10)
color.qualitative.tasklet <- rep(color.qualitative.cyan, 10)
color.qualitative.workqueue <- rep(color.qualitative.teal, 10)
color.qualitative.bottom_handler <- c("Softirq" = color.qualitative.blue,
                                      "Tasklet" = color.qualitative.cyan,
                                      "Workqueue" = color.qualitative.teal)
## Bottom Handler
scale.fill.qualitative.sbesc_sigint.bottom_handler <-
    scale_fill_manual(values = color.qualitative.bottom_handler, guide = FALSE)
scale.color.qualitative.sbesc_sigint.bottom_handler <-
    scale_color_manual(values = color.qualitative.bottom_handler, guide = FALSE)
## Softirq
scale.fill.qualitative.sbesc_sigint.softirq <-
    scale_fill_manual(values = color.qualitative.softirq, guide = FALSE)
scale.color.qualitative.sbesc_sigint.softirq <-
    scale_color_manual(values = color.qualitative.softirq, guide = FALSE)
## Tasklet
scale.fill.qualitative.sbesc_sigint.tasklet <-
    scale_fill_manual(values = color.qualitative.tasklet, guide = FALSE)
scale.color.qualitative.sbesc_sigint.tasklet <-
    scale_color_manual(values = color.qualitative.tasklet, guide = FALSE)
## Workqueue
scale.fill.qualitative.sbesc_sigint.workqueue <-
    scale_fill_manual(values = color.qualitative.workqueue, guide = FALSE)
scale.color.qualitative.sbesc_sigint.workqueue <-
    scale_color_manual(values = color.qualitative.workqueue, guide = FALSE)

## Public.
## Diff must have benchmark, chunk, run, facet
plot.sbesc_sigint <- function(output.dir, data.name, diff, width = 144,
                              height.base = 6, height.facet = 22, max.x.us = 45,
                              max.y = 50000, viridis.begin = 0.0,
                              viridis.end = 0.95, 
                              x.lab = "Delay [µs]",
                              discrete.labs = c("IRQ", "OOB"), binwidth.us = 1,
                              scale.fill = scale.fill.qualitative,
                              scale.color = scale.color.qualitative,
                              alpha = 0.5) {

    max.x.ns <- max.x.us*1000
    limits.y <- c(0,max.y+max.y)
    breaks.log1p <- c(1,10,100,1000,10000,50000)

    get.type <- function (vd, nr) {
        if (is.null(vd) || is.null(nr)) {
            "Discrete"
        } else if ("IRQ" %in% discrete.labs && (any(nr$name == "aic5_handle") ||
                                                any(nr$name == "handle_irq64"))) {
            "Discrete"
        } else if (vd$ns > max.x.ns) {
            "Discrete"
        } else {
            "Continuous"
        }
    }

    get.discrete.reason <- function (vd, nr) {
        if (is.null(vd) || is.null(nr)) {
            "OOB"
        } else if ("IRQ" %in% discrete.labs && (any(nr$name == "aic5_handle") ||
                                                any(nr$name == "handle_irq64"))) {
            "IRQ"
        } else if (vd$ns > max.x.ns) {
            "OOB"
        } else {
            NA
        }
    }

    ## Categorize data.
    all.diff <- diff %>%
        mutate(type = map2_chr(values.delta, name.range, get.type)) %>%
        mutate(discrete.reason = map2_chr(values.delta, name.range, get.discrete.reason))
    cont.diff <- all.diff %>%
        filter(type == "Continuous")
    discr.diff <- all.diff %>%
        filter(type == "Discrete")

    ## Common plot properties.
    scale.y <- scale_y_continuous(trans = "log1p",
                                  limits = limits.y,
                                  expand = c(0,0),
                                  breaks = breaks.log1p,
                                  labels = function(x) format(x, scientific = TRUE, digits = 1))
    facet.grid <- facet_rep_grid(facet ~ .)

    line.size.mm <- 0.25
    text.size <- 9
    axis.ticks.length.mm <- 0.65
    panel.margin.y <- 0.85
    panel.margin.x <- 0.85
    theme.common <- theme(plot.margin = grid::unit(c(0, 0, 0, 0.15), "mm"),
                          text = element_text(size = text.size,
                                              margin = margin(0, 0, 0, 0, "mm")),
                          rect = element_rect(size = line.size.mm),
                          line = element_line(size = line.size.mm),
                          title = element_text(size = text.size,
                                               margin = margin(0, 0, 0, 0, "mm")),
                          ## We don't include axis.ticks.length.mm here, since
                          ## the spacing between the axis line and the other
                          ## plot is more dominant.
                          panel.spacing = grid::unit(panel.margin.y, "mm"),
                          axis.ticks.length = grid::unit(axis.ticks.length.mm, "mm"),
                          panel.grid.minor.y = element_blank())

    unique.facets <- unique(all.diff$facet)
    
    ## Continuous
    cont.comp <- cont.diff %>%
        unnest(values.delta) %>%
        mutate(us = ns/1000) %>%
        complete(facet = unique.facets)
    cont.quantiles <- cont.comp %>%
        group_by(facet) %>%
        ## NAs introduced by facet completion.
        summarize(lower = quantile(us, probs = 0.05, na.rm = TRUE),
                  upper = quantile(us, probs = 0.95, na.rm = TRUE))
    cont <- ggplot(cont.comp, aes(x = us)) +
        geom_histogram(aes(fill = facet,
                           color = facet),
                       alpha = alpha,
                       boundary = 0,
                       binwidth = binwidth.us,
                       size = line.size.mm) +
        geom_vline(data  =  cont.quantiles, aes(xintercept  =  lower),
                   color = color.qualitative.red, linetype = "longdash",
                   size = line.size.mm) +
        geom_vline(data  =  cont.quantiles, aes(xintercept  =  upper),
                   color = color.qualitative.red, linetype = "longdash",
                   size = line.size.mm) +
        scale.y +
        scale_x_continuous(limits = c(0,max.x.us),
                           expand = c(0,0)) +
        labs(x = x.lab,
             y = "Occurrences") +
        theme.common +
        theme(strip.text.y = element_blank(),
              strip.background = element_blank(),
              axis.line = element_line()) +
        scale.fill +
        scale.color +
        facet.grid

    ## Discrete
    discr.count <- discr.diff %>%
        count(facet, type, discrete.reason) %>%
        complete(facet = unique.facets,
                 discrete.reason = discrete.labs, fill = list(n = 0))

    discr <- ggplot(discr.count, aes(x = discrete.reason, y = n)) +
        geom_bar(aes(fill = facet,
                     color = facet),
                 alpha = alpha,
                 stat = "identity",
                 width = 0.325,
                 size = line.size.mm) +
        scale.y +
        scale_x_discrete(drop = FALSE) +
        labs(x = NULL,
             y = NULL) +
        theme.common +
        theme(plot.margin = unit(c(0, 0, 0, panel.margin.x), "mm"),
              axis.title.y = element_blank(),
              axis.line.y = element_blank(),
              axis.text.y = element_blank(),
              axis.ticks.y = element_blank(),
              axis.line.x = element_line(size = line.size.mm),
              strip.text.y  =  element_text(size = text.size,
                                            angle = 90,
                                            margin = margin(0, 1, 0, 1, "mm")),
              strip.placement = "outside",
              strip.switch.pad.grid = grid::unit(axis.ticks.length.mm+panel.margin.x, "mm")) +
        scale.fill +
        scale.color +
        facet.grid

    ## Combine
    ggarrange(cont, discr,
              ncol = 2, nrow = 1, align = "h",
              widths = c(72, 16), # 88mm is total width.
              common.legend = TRUE)

    plot.save(output.dir, data.name, "facetgrid",
              width = width,
              height = height.base+length(unique.facets)*height.facet)
}

plot.variance <- function(output.dir, diffs) {
    
}

## Public.
checkpoint.range.ns.median <- function(cr) {
    cr.up <- cr %>%
        unnest(values.delta)
    quantile(cr.up$ns, probs = 0.5)
}

checkpoint.range.ns.quantile95 <- function(cr) {
    cr.up <- cr %>%
        unnest(values.delta)
    quantile(cr.up$ns, probs = 0.95)
}

checkpoint.range.ns.quantile05 <- function(cr) {
    cr.up <- cr %>%
        unnest(values.delta)
    quantile(cr.up$ns, probs = 0.05)
}

checkpoint.range.ns.max <- function(cr) {
    cr.up <- cr %>%
        unnest(values.delta)
    max(cr.up$ns)
}

checkpoint.range.ns.min <- function(cr) {
    cr.up <- cr %>%
        unnest(values.delta)
    min(cr.up$ns)
}

save.ns.stat <- function(output.dir, cr.a, name.a, cr.b, name.b, cr.c,
                         name.c, statname, f) {
    write.key.value.pairs(file.path(output.dir, statname),
                          data.frame(key = c(name.a,
                                             name.b,
                                             name.c), value = c(f(cr.a),
                                                                f(cr.b),
                                                                f(cr.c))))
}

save.ns.stats.3 <- function(output.dir, cr.a, name.a, cr.b, name.b, cr.c, name.c) {
    save.ns.stat(output.dir, cr.a, name.a, cr.b, name.b, cr.c, name.c, "min-ns",
                 checkpoint.range.ns.min);
    save.ns.stat(output.dir, cr.a, name.a, cr.b, name.b, cr.c, name.c, "max-ns",
                 checkpoint.range.ns.max);
    save.ns.stat(output.dir, cr.a, name.a, cr.b, name.b, cr.c, name.c,
                 "median-ns", checkpoint.range.ns.median);
    save.ns.stat(output.dir, cr.a, name.a, cr.b, name.b, cr.c, name.c,
                 "quantile95-ns", checkpoint.range.ns.quantile95);
    save.ns.stat(output.dir, cr.a, name.a, cr.b, name.b, cr.c, name.c,
                 "quantile05-ns", checkpoint.range.ns.quantile05);
}

save.ns.stats.3.noirq <- function(output.dir, cr.a, name.a, cr.b, name.b, cr.c, name.c) {
    save.ns.stat(output.dir, cr.a, name.a, cr.b, name.b, cr.c, name.c, "noirq-min-ns",
                 checkpoint.range.ns.min);
    save.ns.stat(output.dir, cr.a, name.a, cr.b, name.b, cr.c, name.c, "noirq-max-ns",
                 checkpoint.range.ns.max);
    save.ns.stat(output.dir, cr.a, name.a, cr.b, name.b, cr.c, name.c,
                 "noirq-median-ns", checkpoint.range.ns.median);
    save.ns.stat(output.dir, cr.a, name.a, cr.b, name.b, cr.c, name.c,
                 "noirq-quantile95-ns", checkpoint.range.ns.quantile95);
    save.ns.stat(output.dir, cr.a, name.a, cr.b, name.b, cr.c, name.c,
                 "noirq-quantile05-ns", checkpoint.range.ns.quantile05);
}
    