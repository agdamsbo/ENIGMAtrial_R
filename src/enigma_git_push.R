enigma_git_push<-function(commit_message){
  library(git2r)
  library(lubridate)
  git2r::commit(all=TRUE, message=paste(commit_message,now()))
  
  system("/usr/bin/git push origin HEAD:refs/heads/main")
}


