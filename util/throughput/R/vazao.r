rm(list = ls())
library(ggplot2)

df <- read.csv('/home/tocha/git/MiniSecBGP/util/throughput/csv/vazao.csv')

df$qtdhosts <- factor(df$qtdhosts)

p <- ggplot(df, aes(x = qtdhosts, y = vazao)) +  geom_boxplot()

p <- p + scale_x_discrete(name="Número de contêineres") + scale_y_log10(breaks=c(1,5,10,15,20,30,50,70), name="Vazão (log10) [Gbps]")

p + theme(text = element_text(size=25.5))
