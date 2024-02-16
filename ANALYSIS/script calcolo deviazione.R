file_path <- "C:/Users/lollo/Desktop/TIROCINIO/DATI/varianza.txt"
data <- read.table(file_path, header = FALSE, sep = ",")

# Se il file contiene un'intestazione, puoi impostare header = TRUE
# data <- read.table(file_path, header = TRUE, sep = ",")


df_radice <- round(sqrt(data), digits=2)

print(df_radice)
