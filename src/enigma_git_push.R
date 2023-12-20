# enigma_git_push<-function(commit_message){
#   library(git2r)
#   library(lubridate)
#   git2r::commit(all=TRUE, message=paste(commit_message,now()))
#   
#   system("/usr/bin/git push origin HEAD:refs/heads/main")
# }


#' Commit and push .ics calendar file
#'
#' @param ics.path
#'
#' @return
git_commit_push <- function(f.path, c.message=paste("calendar update",Sys.Date())) {
  git2r::add(path = f.path)
  # Suppressing error if nothing to commit
  tryCatch(git2r::commit(message = c.message), error = function(e) {})
  git2r::push(
    name = "origin",
    refspec = "refs/heads/main",
    credentials = git2r::cred_ssh_key(),
    set_upstream = FALSE
  )
}
