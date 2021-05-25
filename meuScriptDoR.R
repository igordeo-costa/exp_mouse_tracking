# Acessado dados de mouse track
require(dplyr)
require(tidyr)
require(ggplot2)
require(stringr)

# Primeiro, é preciso acessar a tabela de dados do PCIbex com a função read.pcibex
read.pcibex <- function(filepath, auto.colnames=TRUE, fun.col=function(col,cols){cols[cols==col]<-paste(col,"Ibex",sep=".");return(cols)}) {
  n.cols <- max(count.fields(filepath,sep=",",quote=NULL),na.rm=TRUE)
  if (auto.colnames){
    cols <- c()
    con <- file(filepath, "r")
    while ( TRUE ) {
      line <- readLines(con, n = 1, warn=FALSE)
      if ( length(line) == 0) {
        break
      }
      m <- regmatches(line,regexec("^# (\\d+)\\. (.+)\\.$",line))[[1]]
      if (length(m) == 3) {
        index <- as.numeric(m[2])
        value <- m[3]
        if (is.function(fun.col)){
          cols <- fun.col(value,cols)
        }
        cols[index] <- value
        if (index == n.cols){
          break
        }
      }
    }
    close(con)
    return(read.csv(filepath, comment.char="#", header=FALSE, col.names=cols))
  }
  else{
    return(read.csv(filepath, comment.char="#", header=FALSE, col.names=seq(1:n.cols)))
  }
}

mousetrack_data<-read.pcibex("/home/igor/Área de Trabalho/test.csv")

# Limpar algumas colunas não relevantes
# Investigar uma a uma quando do experimento real
mousetrack_data <- mousetrack_data %>%
  select(-c(Results.reception.time,
            #MD5.hash.of.participant.s.IP.address,
            Controller.name,
            Order.number.of.item,
            Inner.element.number,
            Latin.Square.Group,
            PennElementType,
            # PennElementName,
            Comments))

#------------------------------------------------------------------------------
# Fazer uma tabela apenas com os valores clicados pelo participante.
img_clicada <- mousetrack_data %>%
  filter(Parameter == "Selection")
# Não irei trabahar com isso por agora.
#------------------------------------------------------------------------------

# Filtrar apenas as colunas com dados de mouse track
mousetrack_data<-mousetrack_data %>%
  filter(str_detect(Value, "^x"))

# Usar o script abaixo para filtrar os dados
results<-mousetrack_data

# O script começa aqui------------------------------
timestamps_get_response <- vector()
xpos_get_response <- vector()
ypos_get_response <- vector()
for(row in 1:nrow(results)){
  time <- 0
  stream <- as.character(results[row,"Value"])
  pos <- data.frame(time=c(time),x=as.numeric(gsub("^x(\\d+)y.+$","\\1", stream)), y=as.numeric(gsub("^.+y(\\d+)w.+$","\\1", stream)))
  ptime <- time
  counter <- 1
  px <- pos[1,'x']
  py <- pos[1,'y']
  for(s in (strsplit(stream,'t')[[1]][-1])){
    row <- strsplit(gsub("^(\\d+)([+-]\\d+)([+-]\\d+)$","\\1 \\2 \\3",s),' ')
    ntime <- as.numeric(ptime+as.numeric(row[[1]][1]))
    nx <- as.numeric(px+as.numeric(row[[1]][2]))
    ny <- as.numeric(py+as.numeric(row[[1]][3]))
    pos <- rbind(pos, data.frame(time=ntime,x=nx,y=ny))
    ptime <- ntime
    px <- nx
    py <- ny
    counter <- counter+1
  }
  times <- toString(pos[["time"]])
  timestamp <- paste("", times, "", sep = "") # retirei os colchetes. Estava assim: paste("[", times, "]", sep = "")
  timestamps_get_response <- c(timestamps_get_response, timestamp)
  xpos <- toString(pos[["x"]])
  xpos_str <- paste("", xpos, "", sep = "") # idem aqui
  xpos_get_response <- c(xpos_get_response, xpos_str)
  ypos <- toString(pos[["y"]])
  ypos_str <- paste("", ypos, "", sep = "") # idem aqui
  ypos_get_response <- c(ypos_get_response, ypos_str)
}
results$timestamps <- timestamps_get_response
results$xpos <- xpos_get_response
results$ypos <- ypos_get_response
# O script termina aqui ------------------------------------------

# A coluna "Value" agora é redundante
results <- results %>%
  select(-Value)

# Solução disponibilizada aqui: https://stackoverflow.com/questions/67654632/how-to-automate-the-transformation-of-a-list-to-numeric-values
results <- separate_rows(results, c(timestamps, xpos, ypos), sep = ',\\s', convert = TRUE)

# Convertendo como fator
results$item <- as.factor(results$item)
results$grupo <- as.factor(results$grupo)
results$MD5.hash.of.participant.s.IP.address <- as.factor(results$MD5.hash.of.participant.s.IP.address)

# Elaborando o gráfico
results %>%
  ggplot(aes(x=xpos, y=ypos, group = EventTime, colour = MD5.hash.of.participant.s.IP.address))+
  geom_line(size = 0.5, alpha = 0.5)+
  geom_point(size = 0.8, alpha = 0.5, color = "grey")+
  scale_y_reverse()+
  theme_classic()+
  theme(legend.position = 'none')
  #+facet_wrap(grupo~item)

#---------------------------------------------------------------------------------
