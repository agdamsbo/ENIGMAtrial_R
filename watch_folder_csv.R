watch_folder_csv <- function (folder) {
  # Function to import .csv file from specified folder
  pt <- ".csv"
  p <- tail(list.files(folder, pattern = pt, full.names = TRUE),n=1)
  # Select last file from folder. Standard file format puts latest last.
  d <- read.csv(p, header = TRUE, sep = ";")
  return(list(d,p))
}
