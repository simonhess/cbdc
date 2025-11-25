library(mFilter)
library(poweRlaw)
library(tseries)
library(propagate)
library('R.devices')
# library
library(ggplot2)

library(tidyverse)
library(scales)

# install.packages("gridExtra")
library(ggplot2)
library(gridExtra)

plotFormat<-c("svg","pdf")
#plotRatio<-2/3
plotRatio<-1/1
devOptions("*", path=getwd())


banksBS_corridor_CBDC <-read.csv(paste("data_exp2/experiment1/aggBBS1.csv",sep=""), header= FALSE)
cbBS_corridor_CBDC <-read.csv(paste("data_exp2/experiment1/aggCBBS1.csv",sep=""), header= FALSE)

banksBS_floor_CBDC <-read.csv(paste("data_exp6/experiment1/aggBBS1.csv",sep=""), header= FALSE)
cbBS_floor_CBDC <-read.csv(paste("data_exp6/experiment1/aggCBBS1.csv",sep=""), header= FALSE)

data <- matrix(0, nrow = 9, ncol = 2)

colnames(data) <- c("Banks Assets","Banks Liabilities")
rownames(data) <- c("CASH","DEPOSIT","CONS_GOOD","CAPITAL_GOOD","LOANS","BONDS","RESERVES", "ADV", "IBLOANS")

stocksColors <- data.frame("Stock"=c("Cash","Deposits","Consumption Goods","Capital Goods","Loans","Bonds","Reserves", "Advances", "Interbank Loans"),
                   "Color"=palette(rainbow(9, s=0.5)))

############################################################## Corridor Balance sheets

data <- data.frame("BalanceSheetSide"=rep( "",36),
                   "Stock"=rep( "",36),
                   "Value"=rep(0,36))

data[1:9,"BalanceSheetSide"] <- "Assets"
data[1:9,"Stock"] <- stocksColors[,1]
data[1:9,"Value"] <- t(banksBS_corridor_CBDC[201,2:10])
data[c(2,8),"Value"] <-0

data[10:18,"BalanceSheetSide"] <- "Liabilities"
data[10:18,"Stock"] <- stocksColors[,1]
data[10:18,"Value"] <- t(banksBS_corridor_CBDC[201,2:10]*-1)
data[c(1+9,3+9,4+9,5+9,6+9,7+9,9+9),"Value"] <-0


data[19:27,"BalanceSheetSide"] <- " Assets "
data[19:27,"Stock"] <- stocksColors[,1]
data[19:27,"Value"] <- t(banksBS_corridor_CBDC[200,2:10])
data[c(2+18,8+18),"Value"] <-0

data[28:36,"BalanceSheetSide"] <- " Liabilities "
data[28:36,"Stock"] <- stocksColors[,1]
data[28:36,"Value"] <- t(banksBS_corridor_CBDC[200,2:10]*-1)
data[c(1+27,3+27,4+27,5+27,6+27,7+27,9+27),"Value"] <-0

data = data[data[,"Value"] > 0, ]

colorMerge = merge(x = data, y = stocksColors, by = "Stock", all.x = TRUE)
uniqueColors=unique(colorMerge[,"Color"])

# Stacked
#BSBS_corridor_plot <- ggplot(data,aes(fill=data[,"Stock"], y=data[,"Value"], x=data[,"BalanceSheetSide"])) + 
#  geom_bar(position="stack", stat="identity", show.legend = FALSE) +
#  geom_text(aes(label=data[,"Stock"]), position = position_stack(vjust = 0.5), fontface = "bold", size=10) +
#  theme_classic()+ theme(axis.title.x=element_blank(),
#        axis.title.y=element_blank(),axis.line.x = element_blank())+
#  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
#  scale_fill_manual(values=uniqueColors) +theme(text=element_text(size=21))


### Plot

plotColors =unique(merge(data[1:3,], stocksColors, by = "Stock")[,"Color"]) 

BSBS_corridor_after_plot <- ggplot(data[1:3,],aes(fill=data[1:3,"Stock"], y=data[1:3,"Value"], x=data[1:3,"BalanceSheetSide"])) + 
  geom_bar(position="stack", colour="black", stat="identity", show.legend = FALSE) +
  geom_text(aes(label=data[1:3,"Stock"]), position = position_stack(vjust = 0.5), fontface = "bold", size=8) +
  theme_classic()+ theme(axis.title.x=element_blank(),
                         axis.title.y=element_blank(),axis.line.x = element_blank(), axis.line.y = element_blank(),
                         axis.text.y=element_blank(),axis.ticks.x = element_blank(), axis.text.x =element_text(colour="black"))+
  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
  scale_fill_manual(values=plotColors) +theme(text=element_text(size=21))+
  scale_y_continuous(limits = c(0, sum(data[data$BalanceSheetSide==" Assets ","Value"])))+
  labs(title = "Banks t=201")+
  theme(plot.title = element_text(hjust = 0.5))

plotColors =unique(merge(data[4:8,], stocksColors, by = "Stock")[,"Color"]) 

BSBS_corridor_before_plot <- ggplot(data[4:8,],aes(fill=data[4:8,"Stock"], y=data[4:8,"Value"], x=data[4:8,"BalanceSheetSide"])) + 
  geom_bar(position="stack",colour="black", stat="identity", show.legend = FALSE) +
  geom_text(aes(label=data[4:8,"Stock"]), position = position_stack(vjust = 0.5), fontface = "bold", size=8) +
  theme_classic()+ theme(axis.title.x=element_blank(),
                         axis.title.y=element_blank(),axis.line.x = element_blank(), axis.line.y = element_blank(),
                         axis.text.y=element_blank(),axis.ticks.x = element_blank(), axis.text.x =element_text(colour="black"))+
  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
  scale_fill_manual(values=plotColors) +theme(text=element_text(size=21))+
  scale_y_continuous(limits = c(0, sum(data[data$BalanceSheetSide==" Assets ","Value"])))+
  labs(title = "Banks t=200")+
  theme(plot.title = element_text(hjust = 0.5))

plot3 <- ggplot() + theme_void()

yAxis_plot <- ggplot(data[1:3,],aes(fill=data[1:1,"Stock"], y=data[1:1,"Value"], x=data[1:1,"BalanceSheetSide"])) + 
  #geom_bar(position="stack", stat="identity", show.legend = FALSE) +
  theme_classic()+ theme(axis.title.x=element_blank(),
                         axis.title.y=element_blank(),axis.line.x = element_blank(),axis.ticks.x = element_blank())+
  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
  theme(axis.text.x=element_text(colour="white"))+
  theme(text=element_text(size=21))+
  scale_y_continuous(limits = c(0, sum(data[data$BalanceSheetSide==" Assets ","Value"])))+
  labs(title = "")





data2 <- data.frame("BalanceSheetSide"=rep( "",36),
                   "Stock"=rep( "",36),
                   "Value"=rep(0,36))

data2[1:9,"BalanceSheetSide"] <- "Assets"
data2[1:9,"Stock"] <- stocksColors[,1]
data2[1:9,"Value"] <- t(cbBS_corridor_CBDC[201,2:10])
data2[c(2,7),"Value"] <-0

data2[10:18,"BalanceSheetSide"] <- "Liabilities"
data2[10:18,"Stock"] <- stocksColors[,1]
data2[16,"Value"] <- cbBS_corridor_CBDC[201,8]*-1


data2[19:27,"BalanceSheetSide"] <- " Assets "
data2[19:27,"Stock"] <- stocksColors[,1]
data2[19:27,"Value"] <- t(cbBS_corridor_CBDC[200,2:10])
data2[c(2+18,7+18),"Value"] <-0

data2[28:36,"BalanceSheetSide"] <- " Liabilities "
data2[28:36,"Stock"] <- stocksColors[,1]
data2[34,"Value"] <- cbBS_corridor_CBDC[200,8]*-1


data2 = data2[data2[,"Value"] > 0, ]
colorMerge = merge(x = data2, y = stocksColors, by = "Stock", all.x = TRUE)
uniqueColors=unique(colorMerge[,"Color"])

# Stacked
#CBBS_corridor_plot <- ggplot(data2,aes(fill=data2[,"Stock"], y=data2[,"Value"], x=data2[,"BalanceSheetSide"])) + 
#  geom_bar(position="stack", stat="identity", show.legend = FALSE) +
#  geom_text(aes(label=data2[,"Stock"]), position = position_stack(vjust = 0.5), fontface = "bold", size=10) +
#  theme_classic()+ theme(axis.title.x=element_blank(),
#                         axis.title.y=element_blank(),axis.line.x = element_blank())+
#  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
#  scale_fill_manual(values=uniqueColors) +theme(text=element_text(size=21))

#ggsave(file="CBBS_corridor_plot.svg", plot=CBBS_corridor_plot, width=10, height=10)


# Plots

plotColors =unique(merge(data2[1:2,], stocksColors, by = "Stock")[,"Color"]) 

CBBS_corridor_after_plot <- ggplot(data2[1:2,],aes(fill=data2[1:2,"Stock"], y=data2[1:2,"Value"], x=data2[1:2,"BalanceSheetSide"])) + 
  geom_bar(position="stack",colour="black", stat="identity", show.legend = FALSE) +
  geom_text(aes(label=data2[1:2,"Stock"]), position = position_stack(vjust = 0.5), fontface = "bold", size=8) +
  theme_classic()+ theme(axis.title.x=element_blank(),
                         axis.title.y=element_blank(),axis.line.x = element_blank(), axis.line.y = element_blank(),
                         axis.text.y=element_blank(),axis.ticks.x = element_blank(), axis.text.x =element_text(colour="black"))+
  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
  scale_fill_manual(values=plotColors) +theme(text=element_text(size=21))+
  scale_y_continuous(limits = c(0, sum(data[data$BalanceSheetSide==" Assets ","Value"])))+
  labs(title = "Central Bank t=201")+
  theme(plot.title = element_text(hjust = 0.5))

plotColors =unique(merge(data2[3:4,], stocksColors, by = "Stock")[,"Color"]) 

CBBS_corridor_before_plot <- ggplot(data2[3:4,],aes(fill=data2[3:4,"Stock"], y=data2[3:4,"Value"], x=data2[3:4,"BalanceSheetSide"])) + 
  geom_bar(position="stack", colour="black",stat="identity", show.legend = FALSE) +
  geom_text(aes(label=data2[3:4,"Stock"]), position = position_stack(vjust = 0.5), fontface = "bold", size=8) +
  theme_classic()+ theme(axis.title.x=element_blank(),
                         axis.title.y=element_blank(),axis.line.x = element_blank(), axis.line.y = element_blank(),
                         axis.text.y=element_blank(),axis.ticks.x = element_blank(), axis.text.x =element_text(colour="black"))+
  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
  scale_fill_manual(values=plotColors) +theme(text=element_text(size=21))+
  scale_y_continuous(limits = c(0, sum(data[data$BalanceSheetSide==" Assets ","Value"])))+
  labs(title = "Central Bank t=200")+
  theme(plot.title = element_text(hjust = 0.5))


# Combine the plots with gridExtra
corridor_plot <- grid.arrange(yAxis_plot, BSBS_corridor_before_plot,CBBS_corridor_before_plot, plot3, yAxis_plot, BSBS_corridor_after_plot, CBBS_corridor_after_plot, nrow = 1, widths = c(0.5,2.2, 2.2, 0.5,0.5,2.2,2.2)) 


ggsave(file="corridor_plot.svg", plot=corridor_plot, width=20, height=10)

ggsave(file="corridor_plot.pdf", plot=corridor_plot, width=20, height=10)





############################################################## Floor Balance sheets Banks

data3 <- data.frame("BalanceSheetSide"=rep( "",36),
                   "Stock"=rep( "",36),
                   "Value"=rep(0,36))

data3[1:9,"BalanceSheetSide"] <- "Assets"
data3[1:9,"Stock"] <- stocksColors[,1]
data3[1:9,"Value"] <- t(banksBS_floor_CBDC[201,2:10])
data3[c(2,8),"Value"] <-0

data3[10:18,"BalanceSheetSide"] <- "Liabilities"
data3[10:18,"Stock"] <- stocksColors[,1]
data3[10:18,"Value"] <- t(banksBS_floor_CBDC[201,2:10]*-1)
data3[c(1+9,3+9,4+9,5+9,6+9,7+9,9+9),"Value"] <-0


data3[19:27,"BalanceSheetSide"] <- " Assets "
data3[19:27,"Stock"] <- stocksColors[,1]
data3[19:27,"Value"] <- t(banksBS_floor_CBDC[200,2:10])
data3[c(2+18,8+18),"Value"] <-0

data3[28:36,"BalanceSheetSide"] <- " Liabilities "
data3[28:36,"Stock"] <- stocksColors[,1]
data3[28:36,"Value"] <- t(banksBS_floor_CBDC[200,2:10]*-1)
data3[c(1+27,3+27,4+27,5+27,6+27,7+27,9+27),"Value"] <-0



data3 = data3[data3[,"Value"] > 0, ] 

colorMerge = merge(x = data3, y = stocksColors, by = "Stock", all.x = TRUE)
uniqueColors=unique(colorMerge[,"Color"])

# Stacked
#BSBS_floor_plot <- ggplot(data3,aes(fill=data3[,"Stock"], y=data3[,"Value"], x=data3[,"BalanceSheetSide"])) + 
#  geom_bar(position="stack", stat="identity", show.legend = FALSE) +
#  geom_text(aes(label=data3[,"Stock"]), position = position_stack(vjust = 0.5), fontface = "bold", size=10) +
#  theme_classic()+ theme(axis.title.x=element_blank(),
#                         axis.title.y=element_blank(),axis.line.x = element_blank())+
#  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
#  scale_fill_manual(values=uniqueColors) +theme(text=element_text(size=21))

#ggsave(file="BSBS_floor_plot.svg", plot=BSBS_floor_plot, width=10, height=10)


## Central bank BS

data4 <- data.frame("BalanceSheetSide"=rep( "",36),
                   "Stock"=rep( "",36),
                   "Value"=rep(0,36))

data4[1:9,"BalanceSheetSide"] <- "Assets"
data4[1:9,"Stock"] <- stocksColors[,1]
data4[1:9,"Value"] <- t(cbBS_floor_CBDC[201,2:10])
data4[c(2,7),"Value"] <-0

data4[10:18,"BalanceSheetSide"] <- "Liabilities"
data4[10:18,"Stock"] <- stocksColors[,1]
data4[16,"Value"] <- cbBS_floor_CBDC[201,8]*-1


data4[19:27,"BalanceSheetSide"] <- " Assets "
data4[19:27,"Stock"] <- stocksColors[,1]
data4[19:27,"Value"] <- t(cbBS_floor_CBDC[200,2:10])
data4[c(2+18,7+18),"Value"] <-0

data4[28:36,"BalanceSheetSide"] <- " Liabilities "
data4[28:36,"Stock"] <- stocksColors[,1]
data4[34,"Value"] <- cbBS_floor_CBDC[200,8]*-1


data4 = data4[data4[,"Value"] > 0, ]
colorMerge = merge(x = data4, y = stocksColors, by = "Stock", all.x = TRUE)
uniqueColors=unique(colorMerge[,"Color"])

# Stacked
#CBBS_floor_plot <- ggplot(data4,aes(fill=data4[,"Stock"], y=data4[,"Value"], x=data4[,"BalanceSheetSide"])) + 
#  geom_bar(position="stack", stat="identity", show.legend = FALSE) +
#  geom_text(aes(label=data4[,"Stock"]), position = position_stack(vjust = 0.5), fontface = "bold", size=10) +
#  theme_classic()+ theme(axis.title.x=element_blank(),
#                         axis.title.y=element_blank(),axis.line.x = element_blank())+
#  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
#  scale_fill_manual(values=uniqueColors) +theme(text=element_text(size=21))

#ggsave(file="CBBS_floor_plot.svg", plot=CBBS_floor_plot, width=10, height=10)





### BS Plots

plotColors =unique(merge(data3[1:2,], stocksColors, by = "Stock")[,"Color"]) 

BSBS_floor_after_plot <- ggplot(data3[1:2,],aes(fill=data3[1:2,"Stock"], y=data3[1:2,"Value"], x=data3[1:2,"BalanceSheetSide"])) + 
  geom_bar(position="stack", colour="black", stat="identity", show.legend = FALSE) +
  geom_text(aes(label=data3[1:2,"Stock"]), position = position_stack(vjust = 0.5), fontface = "bold", size=8) +
  theme_classic()+ theme(axis.title.x=element_blank(),
                         axis.title.y=element_blank(),axis.line.x = element_blank(), axis.line.y = element_blank(),
                         axis.text.y=element_blank(),axis.ticks.x = element_blank(), axis.text.x =element_text(colour="black"))+
  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
  scale_fill_manual(values=plotColors) +theme(text=element_text(size=21))+
  scale_y_continuous(limits = c(0, sum(data3[data3$BalanceSheetSide==" Assets ","Value"])))+
  labs(title = "Banks t=201")+
  theme(plot.title = element_text(hjust = 0.5))

plotColors =unique(merge(data3[3:5,], stocksColors, by = "Stock")[,"Color"]) 

BSBS_floor_before_plot <- ggplot(data3[3:5,],aes(fill=data3[3:5,"Stock"], y=data3[3:5,"Value"], x=data3[3:5,"BalanceSheetSide"])) + 
  geom_bar(position="stack",colour="black", stat="identity", show.legend = FALSE) +
  geom_text(aes(label=data3[3:5,"Stock"]), position = position_stack(vjust = 0.5), fontface = "bold", size=8) +
  theme_classic()+ theme(axis.title.x=element_blank(),
                         axis.title.y=element_blank(),axis.line.x = element_blank(), axis.line.y = element_blank(),
                         axis.text.y=element_blank(),axis.ticks.x = element_blank(), axis.text.x =element_text(colour="black"))+
  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
  scale_fill_manual(values=plotColors) +theme(text=element_text(size=21))+
  scale_y_continuous(limits = c(0, sum(data3[data3$BalanceSheetSide==" Assets ","Value"])))+
  labs(title = "Banks t=200")+
  theme(plot.title = element_text(hjust = 0.5))

# CB Plots

plotColors =unique(merge(data4[1:3,], stocksColors, by = "Stock")[,"Color"]) 

CBBS_floor_after_plot <- ggplot(data4[1:3,],aes(fill=data4[1:3,"Stock"], y=data4[1:3,"Value"], x=data4[1:3,"BalanceSheetSide"])) + 
  geom_bar(position="stack", colour="black", stat="identity", show.legend = FALSE) +
  geom_text(aes(label=data4[1:3,"Stock"]), position = position_stack(vjust = 0.5), fontface = "bold", size=8) +
  theme_classic()+ theme(axis.title.x=element_blank(),
                         axis.title.y=element_blank(),axis.line.x = element_blank(), axis.line.y = element_blank(),
                         axis.text.y=element_blank(),axis.ticks.x = element_blank(), axis.text.x =element_text(colour="black"))+
  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
  scale_fill_manual(values=plotColors) +theme(text=element_text(size=21))+
  scale_y_continuous(limits = c(0, sum(data3[data3$BalanceSheetSide==" Assets ","Value"])))+
  labs(title = "Central Bank t=201")+
  theme(plot.title = element_text(hjust = 0.5))

plotColors =unique(merge(data4[4:5,], stocksColors, by = "Stock")[,"Color"]) 

CBBS_floor_before_plot <- ggplot(data4[4:5,],aes(fill=data4[4:5,"Stock"], y=data4[4:5,"Value"], x=data4[4:5,"BalanceSheetSide"])) + 
  geom_bar(position="stack", colour="black", stat="identity", show.legend = FALSE) +
  geom_text(aes(label=data4[4:5,"Stock"]), position = position_stack(vjust = 0.5), fontface = "bold", size=8) +
  theme_classic()+ theme(axis.title.x=element_blank(),
                         axis.title.y=element_blank(),axis.line.x = element_blank(), axis.line.y = element_blank(),
                         axis.text.y=element_blank(),axis.ticks.x = element_blank(), axis.text.x =element_text(colour="black"))+
  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
  scale_fill_manual(values=plotColors) +theme(text=element_text(size=21))+
  scale_y_continuous(limits = c(0, sum(data3[data3$BalanceSheetSide==" Assets ","Value"])))+
  labs(title = "Central Bank t=200")+
  theme(plot.title = element_text(hjust = 0.5))


floor_yAxis_plot <- ggplot(data[1:3,],aes(fill=data[1:1,"Stock"], y=data[1:1,"Value"], x=data[1:1,"BalanceSheetSide"])) + 
  #geom_bar(position="stack", stat="identity", show.legend = FALSE) +
  theme_classic()+ theme(axis.title.x=element_blank(),
                         axis.title.y=element_blank(),axis.line.x = element_blank(),axis.ticks.x = element_blank())+
  scale_x_discrete(position = "top") + theme(panel.background = element_rect(fill = 'white', colour = 'white'))+
  theme(axis.text.x=element_text(colour="white"))+
  theme(text=element_text(size=21))+
  scale_y_continuous(limits = c(0, sum(data3[data$BalanceSheetSide==" Assets ","Value"])))+
  labs(title = "")


floor_plot <- grid.arrange(floor_yAxis_plot, BSBS_floor_before_plot,CBBS_floor_before_plot, plot3, floor_yAxis_plot, BSBS_floor_after_plot, CBBS_floor_after_plot, nrow = 1, widths = c(0.5,2.2, 2.2, 0.5,0.5,2.2,2.2)) 


ggsave(file="floor_plot.svg", plot=floor_plot, width=20, height=10)

ggsave(file="floor_plot.pdf", plot=floor_plot, width=20, height=10)

