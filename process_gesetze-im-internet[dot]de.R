data <- read.csv2("scraped/gesetze-im-internet[dot]de.csv")
  data$X <- NULL # remove row number
  data$sysdate <- NULL # remove date scraped

# remove links
  data$pdflink <- NULL

# there is one duplicate which had two different links attached to it
subset(data, duplicated(data)) 
# remove it
data <- subset(data, !duplicated(data))

# 6 duplicate abbreviations remain, with different titles
subset(data, duplicated(data$abbr))

# AFRG:
  # Gesetz zur Regelung bestimmter Altforderungen
  # Gesetz zur Reform der Arbeitsförderung
data[which(data$abbr == "AFRG"),]
# BKV:
  # Verordnung über die Berufsausbildung zum Berufskraftfahrer/zur Berufskraftfahrerin
  # Berufskrankheiten-Verordnung
data[which(data$abbr == "BKV"),]
# EBV:
  # Verordnung zur Erstellung einer Entgeltbescheinigung nach § 108 Absatz 3 Satz 1 der Gewerbeordnung
  # Verordnung über die Bestellung und Bestätigung sowie die Aufgaben und Befugnisse von Betriebsleitern für Eisenbahnen
data[which(data$abbr == "EBV"),]
# RheinSchPersEV:
  # Verordnung zur Einführung der Rheinschiffspersonalverordnung
  #  Verordnung zur Einführung der Verordnung über das Schiffspersonal auf dem Rhein
data[which(data$abbr == "RheinSchPersEV"),]
# RheinSchPersV:
  # Rheinschiffspersonalverordnung (Anlage 1 zur Verordnung zur Einführung der Rheinschiffspersonalverordnung)
  # Verordnung über das Schiffspersonal auf dem Rhein
data[which(data$abbr == "RheinSchPersV"),]
# WTO:
  # Satzung der Weltorganisation für Tourismus
  # Verordnung über die Gewährung von Vorrechten und Befreiungen an die Weltorganisation für Tourismus
data[which(data$abbr == "WTO"),]

# remove these
data <- subset(data, !duplicated(data$abbr))

# remove titles
data$title <- NULL

# process text #
# lowercase and remove duplicates
data$abbr <- tolower(data$abbr)
data <- subset(data, !duplicated(data))

# create additional entries by removing symbols and numbers
data.dump <- gsub("[^[:alnum:]]","", data$abbr)
data <- c(data$abbr, data.dump)
data <- data[!duplicated(data)]

# check for string length == 2 
data[which(nchar(data) == 2)]
# remove "^wg$" (can be meaningful: Wohnungsgemeinschaft)
data <- data[-which(grepl("^wg$", data))]
# remove "^wo$" (can be meaningful)
data <- data[-which(grepl("^wo$", data))]

write.csv2(data, "stopwords/legal-stopwords.csv")
