######--- Header ---------------------------------------------------------######

#--- Information --------------------------------------------------------------#
# Before running this script, run a docker container with ports declared to
# Windows. In this case, a standalone selenium version of the chrome
# browser is utilized. The standalone versions integrate remote drivers,
# so we can access the browser in the docker container via R.
# Run in Windows CMD:
# docker run -d -p 127.0.0.1:4444:4444 -p 127.0.0.1:5900:5900 selenium/standalone-chrome-debug
# Port 4444 allows access to the browser in the container
# Port 5900 allows debugging access to view the browser with a VNC viewer
# Default password for Selenium VNC connection: secret

#--- Packages & Version Control -----------------------------------------------#
# Save workspace disabled
# Windows 11, RStudio: 2023.03.1-446
# R.Version() # 4.3.0 (2023-04-21 ucrt)
require(RSelenium) # 1.7.9

####--- Settings -----------------------------------------------------------####
#--- Local encoding -----------------------------------------------------------#
defwarn <- getOption("warn")
options(warn = -1)
Sys.setlocale("LC_ALL", "de_DE.UTF-8") # Linux, MAC
Sys.setlocale("LC_ALL", 'German') # Windows
options(warn = defwarn)
rm(defwarn)

######--- Body -----------------------------------------------------------######
# connect to selenium 
rD <- remoteDriver(remoteServerAddr = "localhost",
                   port = 4444L,
                   browserName = "chrome")
# open browser
rD$open()
# go to website: gesetze-im-internet.de/aktuell.html
rD$navigate("https://www.gesetze-im-internet.de/aktuell.html")

# Find all lists of laws available
all <- rD$findElements(using = "class", value = "alphabet")
links <- sapply(all, function(x) x$getElementAttribute("href"), simplify = T)
# Now we have a link to each list of laws by the first starting letter or number

# For every list, let's scrape the Data on the abbreviation and it's description
get.child <- function (x){
  x$findChildElement(using = "xpath", 'a[1]/abbr')
}

# do this sequentially, since we are actually scraping a website using a browser
for(i in 1:length(links)){
  # open link
  rD$navigate(links[[i]])
  
  # find entries
  temp <- assign(paste0("list_", i), 
                 rD$findElements(using = "xpath", '/html/body/div[4]/div/div[1]/div/p')
  )
  
  # find element containing title and abbreviation
  temp2 <- sapply(temp,
                  function (x) x$findChildElement(using = "xpath", 'a[1]/abbr')
                  )
  
  # get abbreviation (only one element, so pick first entry)
  assign(paste0("abbr_",i),
         sapply(temp2,
                function (x) x$getElementText()[[1]],
                simplify = T)
  )
  
  # get description (only one element, so pick first entry)
  assign(paste0("title_",i),
         sapply(temp2,
                function (x) x$getElementAttribute("title")[[1]],
                simplify = T)
  )
  
  # We also append the link to each law supplied as a PDF 
  # (only one element, so pick first entry)
  assign(paste0("pdflink_",i),
         sapply(temp,
         function(x) x$findChildElement(using = "xpath", 'a[2]')$getElementAttribute("href")[[1]],
         simplify = T)
  )
  
  # save in a matrix
  assign(paste0("data_", i), cbind(get(paste0("abbr_",i)),
                                   get(paste0("title_",i)),
                                   get(paste0("pdflink_",i)),
                                   rep(Sys.Date(), length(get(paste0("abbr_",i))))))
  # remove some fails
  rm(list = ls(pattern = "^(abbr_|title_|pdflink_|temp)"))
}

# now we can combine all datasets
data <- data_1
subsets <- paste0("data_",seq(2, length(links)-1))
for(i in 2:length(links)){
  data <- rbind(data, get(paste0("data_",i)))
}
colnames(data) <- c("abbr","title","pdflink","sysdate")
# save the data
write.csv2(data, "scraped/gesetze-im-internet[dot]de.csv2")
