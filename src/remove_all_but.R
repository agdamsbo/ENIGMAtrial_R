remove_all_but <- function(...) {
  names <- as.character(rlang::ensyms(...))
  rm(list=setdiff(ls(pos=1), names), pos=1)
}
