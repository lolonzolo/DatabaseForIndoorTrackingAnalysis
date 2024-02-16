library(ggplot2)







dataframe <- data.frame(
  Colonna1 = c( 1215.746,
                646.930,
                687.135,
                793.012,
                640.449,
                658.115,
                624.127
                
               
               
               
               
               
               
  ),
  Colonna2 = c( 760.430,
                1053.888,
                1031.468,
                1081.187,
                1072.830,
                746.169,
                526.803
                
               
               
               
               
               
               
               
  ),
  Colonna3 = c( 714.718,
                601.311,
                706.304,
                682.338,
                640.353,
                726.200,
                1081.187
               
               
               
               
               
               
  )
)


rowMeans(dataframe)
mediadata <- data.frame(media= c(round (rowMeans(dataframe), digits=2)), Colonna1 = c(500, 1500, 2500, 3500, 4500, 5500, 7500))


ggplot(mediadata, aes(x = Colonna1, y = media)) + geom_text(aes(label = media), hjust = 0.5, vjust = -1) +
  geom_point() + geom_line() + xlab("n collegamenti") + ylab("time in ms") 

# Funzione per calcolare la varianza riga per riga
calcola_varianza_righe <- function(row) {
  return(var(row))
}
varianza<-var(dataframe[1,])
print(varianza)

# Applicazione della funzione alle righe del dataset
varianze_righe <- apply(dataframe, 1, calcola_varianza_righe)

# Stampa delle varianze calcolate
cat("Varianza per riga:\n")
print(varianze_righe)

