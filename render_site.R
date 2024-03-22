# R script to create all rcode files

library(tidyverse)
library(xml2)

# set current location
here <- here::here()

# get all html pages
pages <- list.files(here, "[.]Rmd$")

code <- tibble()

for (page in pages) {
  code <- c(code, readtext::readtext(str_c(here, "/", page)))
}

doc_name <- code[grep("doc_id", names(code))]
doc_code <- code[grep("text", names(code))]

code <- tibble(
  name = doc_name,
  code = doc_code
)

code <- code %>% 
  mutate(
    new_name = str_remove(name, ".Rmd"),
    new_name = str_c(new_name, "-r.Rmd"),
    new_code = str_c("````markdown\n", code, "\n````")
  )

map2(code$new_code, code$new_name,
     ~ write_file(.x, .y))

rmarkdown::render_site()

map(code$new_name,
    ~ file.remove(.x))

# create sitemap

html_pages <- list.files(here, "[.]html$") %>%
  tibble(page = .) %>% 
  filter(
    str_detect(page, "-r.html$", negate = TRUE),
    page != "404.html",
    page != "impressum.html"
  ) %>% mutate(
    mtime = as.Date(file.mtime(page))
  )

top <- '<?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

middle <- map2(html_pages$page, html_pages$mtime,
               ~ str_c(
                 " <url><loc>",
                 str_c("https://felix-dietrich.de/", .x),
                 "</loc><lastmod>", .y, "</lastmod></url>"
               ))

middle <- paste(middle, collapse = "")

bottom <- "</urlset>"

sitemap_code <- paste(top, middle, bottom, collapse = "")

sitemap <- xml2::read_xml(sitemap_code)

xml2::write_xml(sitemap, "sitemap.xml")
