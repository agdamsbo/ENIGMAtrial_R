## Cognitive Index app deployment

require(rsconnect)

keys<-suppressWarnings(read.csv("/Users/au301842/shinyapp_token.csv",colClasses = "character"))

rsconnect::setAccountInfo(name='cognitiveindex', 
                          token=keys$key[1], secret=keys$key[2])

deployApp()
