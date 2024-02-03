#!/usr/bin/Rscript

get_devs = function(file, min_duration = 0) {
	df = read.csv(file) %>%		
		mutate(date = as.Date(visit_start, format = '%Y-%m-%dT%H:%M:%S')) %>%	
		filter(duration >= !!min_duration) %>%
		group_by(date) %>%
		summarize(devs = n_distinct(ad_id))
}

main = function(devs_file) {
	population.model.path = Sys.getenv("LOCALIA_POPULATION_MODEL")
	fit.pop = readRDS(population.model.path)
	dates = data.frame(date = seq.Date(as.Date('2019-01-01'), as.Date('2022-10-01'), by='day'))
	devs = get_devs(devs_file)
	df = dates %>%
		left_join(devs) %>%
		mutate(devs = replace_na(as.double(devs),0.1))
	df$predicted = ceiling(exp(predict(fit.pop, newdata = df)))
	df %>% mutate(devs = case_when(devs < 1 ~ 0, TRUE ~ devs)) %>% write.csv(file="",row.names = FALSE)
}

usage = function() {
	message("usage: get_polygon_occupancies.r FILE

This program returns daily visitation/occupancy based a visits file

Parmaeters:
FILE    Visits file for the area of interest")
}

args = commandArgs(trailing=TRUE)
if(length(args) != 1) { usage(); q() }

suppressMessages({
require(dplyr)
require(tidyr)
})
main(args[1])
