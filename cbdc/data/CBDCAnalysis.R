library(mFilter)
library(poweRlaw)
library(tseries)
library(propagate)
library('R.devices')
library(matrixStats)
library(zoo)

plotFormat<-c("svg","pdf")
#plotRatio<-2/3
plotRatio<-1/1
devOptions("*", path=getwd())


################################################################################ Tables for average values of each run


rgdpAverages <- matrix(, nrow = 600, ncol = 12)
invAverages <- matrix(, nrow = 600, ncol = 12)
consAverages <- matrix(, nrow = 600, ncol = 12)
cpAverages <- matrix(, nrow = 600, ncol = 12)
kpAverages <- matrix(, nrow = 600, ncol = 12)
unempAverages <- matrix(, nrow = 600, ncol = 12)
giniAverages <- matrix(, nrow = 600, ncol = 12)
govconsAverages <- matrix(, nrow = 600, ncol = 12)

rbankcreditAverages <- matrix(, nrow = 600, ncol = 12)
rbankprofitAverages <- matrix(, nrow = 600, ncol = 12)
rbankdividendAverages <- matrix(, nrow = 600, ncol = 12)
rbankdepinterestpaidAverages <- matrix(, nrow = 600, ncol = 12)
rbankadvinterestpaidAverages <- matrix(, nrow = 600, ncol = 12)

banksdepinterestrateAverages <- matrix(, nrow = 600, ncol = 12)
cbadvancesrateAverages <- matrix(, nrow = 600, ncol = 12)
banksloanavinterestAverages <- matrix(, nrow = 600, ncol = 12)
banksinterbankavinterestAverages <- matrix(, nrow = 600, ncol = 12)

banksCARAverages <- matrix(, nrow = 600, ncol = 12)
banksDepositUpperBoundSpreadAverages <- matrix(, nrow = 600, ncol = 12)

# bank spread loan interest and funding costs
banksLoanInterestSpreadAverages <- matrix(, nrow = 600, ncol = 12)

banksInterestRevenueAverages <- matrix(, nrow = 600, ncol = 12)

rGovResAverages <- matrix(, nrow = 600, ncol = 12)

firmBankruptciesAverages <- matrix(, nrow = 600, ncol = 12)

#x= 5
for (x in 1:12){
  folder<-paste("data_exp",x, sep = "")

  expNb <- x
  
  #COMMENT IF MERGED .CSV FILES ALREADY CREATED#######
  #source("MergeMonteCarloSim.R")
  #generateMergedCSV(folder)
  #generateSums(folder)
  ####################################################
  
  #IMPORT DATA FROM .csv FILES
  gdp<-read.csv(paste(folder,"/Merged_nominalGDP.csv",sep=""))
  cPrices<-read.csv(paste(folder,"/Merged_cAvPrice.csv",sep=""))
  kPrices<-read.csv(paste(folder,"/Merged_kAvPrice.csv",sep=""))
  netIncome<-read.csv(paste(folder,"/Merged_hhAvNetIncome.csv",sep=""))
  unemp<-read.csv(paste(folder,"/Merged_unemployment.csv",sep=""))
  inv<-read.csv(paste(folder,"/Merged_cFirmsRealInvestment.csv",sep=""))
  cons<-read.csv(paste(folder,"/Merged_cFirmsRealSales.csv",sep=""))
  credGap<-read.csv(paste(folder,"/Merged_cAggConsCredit.csv",sep=""))
#  cFirmsBS<-read.csv(paste(folder,"/Merged_aggCFBS.csv",sep=""))
#  hhBS=read.csv(paste(folder,"/Merged_aggHHBS.csv",sep=""))
#  kFirmsBS=read.csv(paste(folder,"/Merged_aggKFBS.csv",sep=""))
  banksBS<-read.csv(paste(folder,"/Merged_aggBBS.csv",sep=""))
  kSales=read.csv(paste(folder,"/Merged_kFirmsRealSales.csv",sep=""))
  banksCredit=read.csv(paste(folder,"/Merged_banksTotalCredit.csv",sep=""))
 # banksCreditDegree<-read.csv(paste(folder,"/Merged_banksCreditDegreeDistribution.csv",sep=""))
  hhWages=read.csv(paste(folder,"/Merged_hhAvWage.csv",sep=""))
  cFirmsBankruptcy=read.csv(paste(folder,"/Merged_cFirmsBankrupcty.csv",sep=""))
  kFirmsBankruptcy=read.csv(paste(folder,"/Merged_kFirmsBankrupcty.csv",sep=""))
  banksBankruptcies=read.csv(paste(folder,"/Merged_banksBankrupcty.csv",sep=""))
  
  gini=read.csv(paste(folder,"/Merged_gini.csv",sep=""))
  
  govBS<-read.csv(paste(folder,"/Merged_aggGBS.csv",sep=""))
  
  banksProfits=read.csv(paste(folder,"/Merged_banksProfits.csv",sep=""))
  banksDividends=read.csv(paste(folder,"/Merged_banksDividends.csv",sep=""))
  banksDepositInterestPaid=read.csv(paste(folder,"/Merged_banksDepositInterestPaid.csv",sep=""))
  banksAdvancesInterestPaid=read.csv(paste(folder,"/Merged_banksAdvancesInterestPaid.csv",sep=""))
  
#  cFirmsMarkup=read.csv(paste(folder,"/Merged_cFirmsMarkup.csv",sep=""))
#  kFirmsMarkup=read.csv(paste(folder,"/Merged_kFirmsMarkup.csv",sep=""))
#  banksMarkup=read.csv(paste(folder,"/Merged_banksMarkup.csv",sep=""))
  
  cbAdvancesRate=read.csv(paste(folder,"/Merged_cbAdvancesInterestRate.csv",sep=""))
  banksLoanAvInterest=read.csv(paste(folder,"/Merged_banksLoanAvInterest.csv",sep=""))
  banksDepAvInterest=read.csv(paste(folder,"/Merged_banksDepAvInterest.csv",sep=""))
  banksInterbankAvInterest=read.csv(paste(folder,"/Merged_banksInterbankAvInterest.csv",sep=""))
  banksDepositInterest=read.csv(paste(folder,"/Merged_banksDepositInterestRate.csv",sep=""))
  banksDepositsStock=read.csv(paste(folder,"/Merged_banksDepositsStock.csv",sep=""))
  
  banksDepositsStock=read.csv(paste(folder,"/Merged_banksDepositsStock.csv",sep=""))
  
  banksCAR=read.csv(paste(folder,"/Merged_banksCapitalAdequacyRatio.csv",sep=""))
  banksDepositInterestUpperBoundSpread=read.csv(paste(folder,"/Merged_banksDepositUBSpread.csv",sep=""))
  
  banksBondsInterestReceived=read.csv(paste(folder,"/Merged_banksBondsInterestReceived.csv",sep=""))
  banksLoansInterestReceived=read.csv(paste(folder,"/Merged_banksLoansInterestReceived.csv",sep=""))
  banksReservesInterestReceived=read.csv(paste(folder,"/Merged_banksReservesInterestReceived.csv",sep=""))
  

  
  nbRounds <- nrow(gdp)
  
  #LOOK FOR CRASHED SIMULATIONS BASED ON UNEMPLOYMENT RATE (ONLY PUBLIC EMPLOYMENT REMAINS)
  toBeRemoved=c()
  for (i in 2:length(unemp[1,])){
    if (any(unemp[,i]>0.8)){
      toBeRemoved=c(toBeRemoved,i)
    }
  }
  
  #FIND THE NAME OF THE SIMULATIONS CRASHED
  simCrashed=colnames(unemp)
  simCrashed=simCrashed[toBeRemoved]
  #REMOVE CRASHED SIMULATIONS
  if (!is.null(toBeRemoved)){
    unemp=unemp[,-toBeRemoved]
    gdp=gdp[,-toBeRemoved]
    netIncome=netIncome[,-toBeRemoved]
    cPrices=cPrices[,-toBeRemoved]
    kPrices=kPrices[,-toBeRemoved]
    credGap=credGap[,-toBeRemoved]
    hhWages=hhWages[,-toBeRemoved]
    cFirmsBankruptcy=cFirmsBankruptcy[,-toBeRemoved]
    kFirmsBankruptcy=kFirmsBankruptcy[,-toBeRemoved]
    banksBankruptcies=banksBankruptcies[,-toBeRemoved]
  }
  #IDENTIFY THE COLUMNS WHERE AGGREGATE INVESTMENT&CONSUMPTION FOR EACH SIMULATION HAS BEEN COMPUTED
  cn<-colnames(inv)
  indexSum<-grep("SUM",colnames(inv))
  nbRuns0<-length(grep(paste("Run",sep=""),cn[indexSum]))
  #nbRuns0<-10
  #CREATE DATASET FOR AGGREGATE INVESTMENT AND CONSUMPTION
  invAggregate=inv[,c(1,indexSum)]
  consAggregate=cons[,c(1,indexSum)]
  #IDENTIFY THE CRASHED SIMULATIONS BASED ON THE CRASHED SIMULATION NAMES
  if (!is.null(toBeRemoved)){
    indexCrashed=c()
    for (i in 1:length(simCrashed)){
      indexCrashed=c(indexCrashed,grep(simCrashed[i], colnames(invAggregate)))
    }
    
    #REMOVE CRASHED SIMULATIONS
    invAggregate=invAggregate[,-indexCrashed]
    consAggregate=consAggregate[,-indexCrashed]
  }
  invUnitsAggregate=invAggregate
  #GET REAL VALUE OF INVESTMENT GOODS
  for (i in 1:(nbRuns0)){
    if (!(paste("Exp1Run",i,sep="")%in% simCrashed)){
      invAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(invAggregate))]=invAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(invAggregate))]*kPrices[,grep(paste("Run",i,"$",sep=""),colnames(kPrices))]/cPrices[,grep(paste("Run",i,"$",sep=""),colnames(cPrices))]
    }
  }
  
  
  # Calcuate real values of bank loans, profit, dividends and interest paid
  cn<-colnames(inv)
  indexSum<-grep("SUM",colnames(banksCredit))
  nbRuns0<-length(grep(paste("Run",sep=""),cn[indexSum]))
  #CREATE DATASET FOR AGGREGATE BANKS LOANS, PROFIT, DIVIDENDS AND INTEREST PAID
  
  rBankCreditAggregate = banksCredit[,c(1,indexSum)]
  rBankProfitAggregate = banksProfits[,c(1,indexSum)]
  rBankDividendAggregate = banksDividends[,c(1,indexSum)]
  rBankDepInterestPaidAggregate = banksDepositInterestPaid[,c(1,indexSum)]
  rBankAdvInterestPaidAggregate = banksAdvancesInterestPaid[,c(1,indexSum)]
  rBanksDepositInterestUpperBoundSpreadAggregate = banksDepositInterestUpperBoundSpread[,c(1,indexSum)]
  rBanksBondsInterestReceivedAggregate=banksBondsInterestReceived[,c(1,indexSum)]
  rBanksLoansInterestReceivedAggregate=banksLoansInterestReceived[,c(1,indexSum)]
  rBanksReservesInterestReceivedAggregate=banksReservesInterestReceived[,c(1,indexSum)]
  
  

  #GET REAL VALUE OF BANK DATA
  for (i in 1:(nbRuns0)){
    if (!(paste("Exp1Run",i,sep="")%in% simCrashed)){
      rBankCreditAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBankCreditAggregate))]=rBankCreditAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBankCreditAggregate))]/cPrices[,grep(paste("Run",i,"$",sep=""),colnames(cPrices))]
      rBankProfitAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBankProfitAggregate))]=rBankProfitAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBankProfitAggregate))]/cPrices[,grep(paste("Run",i,"$",sep=""),colnames(cPrices))]
      rBankDividendAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBankDividendAggregate))]=rBankDividendAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBankDividendAggregate))]/cPrices[,grep(paste("Run",i,"$",sep=""),colnames(cPrices))]
      rBankDepInterestPaidAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBankDepInterestPaidAggregate))]=rBankDepInterestPaidAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBankDepInterestPaidAggregate))]/cPrices[,grep(paste("Run",i,"$",sep=""),colnames(cPrices))]
      rBankAdvInterestPaidAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBankAdvInterestPaidAggregate))]=rBankAdvInterestPaidAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBankAdvInterestPaidAggregate))]/cPrices[,grep(paste("Run",i,"$",sep=""),colnames(cPrices))]
      rBanksDepositInterestUpperBoundSpreadAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBanksDepositInterestUpperBoundSpreadAggregate))]=rBanksDepositInterestUpperBoundSpreadAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBanksDepositInterestUpperBoundSpreadAggregate))]/cPrices[,grep(paste("Run",i,"$",sep=""),colnames(cPrices))]
      
      rBanksBondsInterestReceivedAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBanksBondsInterestReceivedAggregate))]=rBanksBondsInterestReceivedAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBanksBondsInterestReceivedAggregate))]/cPrices[,grep(paste("Run",i,"$",sep=""),colnames(cPrices))]
      rBanksLoansInterestReceivedAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBanksLoansInterestReceivedAggregate))]=rBanksLoansInterestReceivedAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBanksLoansInterestReceivedAggregate))]/cPrices[,grep(paste("Run",i,"$",sep=""),colnames(cPrices))]
      rBanksReservesInterestReceivedAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBanksReservesInterestReceivedAggregate))]=rBanksReservesInterestReceivedAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(rBanksReservesInterestReceivedAggregate))]/cPrices[,grep(paste("Run",i,"$",sep=""),colnames(cPrices))]
      }
  }
  
  rBanksInterestRevenue=rBanksBondsInterestReceivedAggregate
  rBanksInterestRevenue[,2:ncol(rBanksInterestRevenue)]=rBanksBondsInterestReceivedAggregate[,2:ncol(rBanksInterestRevenue)]+rBanksLoansInterestReceivedAggregate[,2:ncol(rBanksInterestRevenue)]+rBanksReservesInterestReceivedAggregate[,2:ncol(rBanksInterestRevenue)]
  
  
  #COMPUTE REAL GDP
  rgdp<-gdp
  #rgdp[,2:ncol(rgdp)]=gdp[,2:ncol(rgdp)]/cPrices[,2:ncol(rgdp)]
  #or alternatively (if you want just focus on real output)
  for (i in 1:(nbRuns0)){
    if (!(paste("Exp1Run",i,sep="")%in% simCrashed)){
      rgdp[,grep(paste("Run",i,"$",sep=""),colnames(rgdp))]=invAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(invAggregate))]+consAggregate[,grep(paste("Run",i,"SUM",sep=""),colnames(consAggregate))]
    }
  }
  
  
  cPricesGrRates <- cPrices[1:(nrow(cPrices)-1),]
  kPricesGrRates <- kPrices[1:(nrow(kPrices)-1),]
  
  for(i in 2:ncol(cPrices)){
    cPr<-as.ts(cPrices[,i],frequency=4)
    kPr<-as.ts(kPrices[,i],frequency=4)
    nInc<-as.ts(netIncome[,i],frequency=4)
    #COMPUTE RATES OF GROWTH OF PRICES AND NET INCOME
    cPrGr<-100*(cPr[-1]-cPr[-length(cPr)])/cPr[-length(cPr)]
    kPrGr<-100*(kPr[-1]-kPr[-length(kPr)])/kPr[-length(kPr)]
    nIncGr<-100*(nInc[-1]-nInc[-length(nInc)])/nInc[-length(nInc)]
    
    cPricesGrRates[,i] <- cPrGr
    kPricesGrRates[,i] <- kPrGr
  }
  
  
  #Real Gov Spending
  #EXTRACT gov spending/ cGoods FROM Gov' BS
  indexGovCons<-grep("CONS_GOOD",colnames(govBS))
  
  rGovCons <- govBS[,c(1,indexGovCons)]

  rGovCons[,2:ncol(rGovCons)] <- rGovCons[,2:ncol(rGovCons)]/cPrices[,2:ncol(rGovCons)]
  
  
  #Real Deposit Insurance Fund
  #EXTRACT gov reserves FROM Gov' BS
  indexGovRes<-grep("RESERVES",colnames(govBS))
  
  rGovRes <- govBS[,c(1,indexGovRes)]
  
  rGovRes[,2:ncol(rGovRes)] <- rGovRes[,2:ncol(rGovRes)]/cPrices[,2:ncol(rGovRes)]
  
  cbAdvancesRateAverage <- cbAdvancesRate 
  cbAdvancesRateAverage <- rowMeans(cbAdvancesRate[,2:ncol(cbAdvancesRate)])
  
  firmBankruptcies <- cFirmsBankruptcy
  firmBankruptcies[,2:ncol(firmBankruptcies)] <- firmBankruptcies[,2:ncol(firmBankruptcies)]+kFirmsBankruptcy[,2:ncol(firmBankruptcies)]
  
  ##### Non filtered average values
  
  calcMovingAverage <- function(multiColTable) {
    result <- multiColTable
    for (x in 2:ncol(multiColTable)) {
      result[,x] <- rollmean(multiColTable[,x], k = 20, fill=NA, align='right')
    }
    return(result)
  }
  # Create smoothed versions of all tables
  rgdp_smoothed <- calcMovingAverage(rgdp)
  invUnitsAggregate_smoothed <- calcMovingAverage(invUnitsAggregate)
  consAggregate_smoothed <- calcMovingAverage(consAggregate)
  cPricesGrRates_smoothed <- calcMovingAverage(cPricesGrRates)
  kPricesGrRates_smoothed <- calcMovingAverage(kPricesGrRates)
  unemp_smoothed <- calcMovingAverage(unemp)
  gini_smoothed <- calcMovingAverage(gini)
  rGovCons_smoothed <- calcMovingAverage(rGovCons)
  rGovRes_smoothed <- calcMovingAverage(rGovRes)
  firmBankruptcies_smoothed <- calcMovingAverage(firmBankruptcies)
  rBankCreditAggregate_smoothed <- calcMovingAverage(rBankCreditAggregate)
  rBankProfitAggregate_smoothed <- calcMovingAverage(rBankProfitAggregate)
  rBankDividendAggregate_smoothed <- calcMovingAverage(rBankDividendAggregate)
  rBankDepInterestPaidAggregate_smoothed <- calcMovingAverage(rBankDepInterestPaidAggregate)
  rBankAdvInterestPaidAggregate_smoothed <- calcMovingAverage(rBankAdvInterestPaidAggregate)
  rBanksInterestRevenue_smoothed <- calcMovingAverage(rBanksInterestRevenue)
  banksDepAvInterest_smoothed <- calcMovingAverage(banksDepAvInterest)
  cbAdvancesRate_smoothed <- calcMovingAverage(cbAdvancesRate)
  banksLoanAvInterest_smoothed <- calcMovingAverage(banksLoanAvInterest)
  banksInterbankAvInterest_smoothed <- calcMovingAverage(banksInterbankAvInterest)
  banksCAR_smoothed <- calcMovingAverage(banksCAR)
  rBanksDepositInterestUpperBoundSpreadAggregate_smoothed <- calcMovingAverage(rBanksDepositInterestUpperBoundSpreadAggregate)
  
  
  rgdpAverages[1:nbRounds,expNb] <- rowMeans(rgdp_smoothed[,2:ncol(rgdp_smoothed)])
  invAverages[1:nbRounds,expNb] <- rowMeans(invUnitsAggregate_smoothed[,2:ncol(invUnitsAggregate_smoothed)])
  consAverages[1:nbRounds,expNb] <- rowMeans(consAggregate_smoothed[,2:ncol(consAggregate_smoothed)])
  cpAverages[1:nbRounds-1,expNb] <- rowMeans(cPricesGrRates_smoothed[,2:ncol(cPricesGrRates_smoothed)])
  kpAverages[1:nbRounds-1,expNb] <- rowMeans(kPricesGrRates_smoothed[,2:ncol(kPricesGrRates_smoothed)])
  unempAverages[1:nbRounds,expNb] <- rowMeans(unemp_smoothed[,2:ncol(unemp_smoothed)])
  giniAverages[1:nbRounds,expNb] <- rowMeans(gini_smoothed[,2:ncol(gini_smoothed)])
  govconsAverages[1:nbRounds,expNb] <- rowMeans(rGovCons_smoothed[,2:ncol(rGovCons_smoothed)])
  
  rGovResAverages[1:nbRounds,expNb] <- rowMeans(rGovRes_smoothed[,2:ncol(rGovRes_smoothed)])
  
  firmBankruptciesAverages[1:nbRounds,expNb] <- rowMeans(firmBankruptcies_smoothed[,2:ncol(firmBankruptcies_smoothed)])
  
  rbankcreditAverages[1:nbRounds,expNb] <- rowMeans(rBankCreditAggregate_smoothed[,2:ncol(rBankCreditAggregate_smoothed)])
  rbankprofitAverages[1:nbRounds,expNb] <- rowMeans(rBankProfitAggregate_smoothed[,2:ncol(rBankProfitAggregate_smoothed)])
  rbankdividendAverages[1:nbRounds,expNb] <- rowMeans(rBankDividendAggregate_smoothed[,2:ncol(rBankDividendAggregate_smoothed)])
  rbankdepinterestpaidAverages[1:nbRounds,expNb] <- rowMeans(rBankDepInterestPaidAggregate_smoothed[,2:ncol(rBankDepInterestPaidAggregate_smoothed)])
  rbankadvinterestpaidAverages[1:nbRounds,expNb] <- rowMeans(rBankAdvInterestPaidAggregate_smoothed[,2:ncol(rBankAdvInterestPaidAggregate_smoothed)])
  
  banksInterestRevenueAverages[1:nbRounds,expNb] <- rowMeans(rBanksInterestRevenue_smoothed[,2:ncol(rBanksInterestRevenue_smoothed)])
  
  banksdepinterestrateAverages[1:nbRounds,expNb] <- rowMeans(banksDepAvInterest_smoothed[,2:ncol(banksDepAvInterest_smoothed)])
  cbadvancesrateAverages[1:nbRounds,expNb] <- rowMeans(cbAdvancesRate_smoothed[,2:ncol(cbAdvancesRate_smoothed)])
  banksloanavinterestAverages[1:nbRounds,expNb] <- rowMeans(banksLoanAvInterest_smoothed[,2:ncol(banksLoanAvInterest_smoothed)])
  banksinterbankavinterestAverages[1:nbRounds,expNb] <- rowMeans(banksInterbankAvInterest_smoothed[,2:ncol(banksInterbankAvInterest_smoothed)])
  
  banksCARAverages[1:nbRounds,expNb] <- rowMeans(banksCAR_smoothed[,2:(ncol(banksCAR_smoothed)-nbRuns0)])
  #banksLoanInterestSpreadAverages[1:nbRounds,expNb] <- banksloanavinterestAverages[1:nbRounds,expNb]-banksnonequityfundingrateAverages[1:nbRounds,expNb]
  
  banksDepositUpperBoundSpreadAverages[1:nbRounds,expNb] <- rowMeans(rBanksDepositInterestUpperBoundSpreadAggregate_smoothed[,2:ncol(rBanksDepositInterestUpperBoundSpreadAggregate_smoothed)])
  
}



#Reports new

scenarioIndex <-1

for (x in 1:6){
  
plotname <- paste(c("Scenario", x), collapse = "")

nbRows <- 600
xlimLeft <- 200

if(x<4){
  nbRows <- 400
  xlimLeft <- 200
}

nbBaseline <- scenarioIndex
nbCBDC <- scenarioIndex+1

print(nbBaseline)
print(nbCBDC)

if(x<=3){
  plotRatio=1
}
if(x>3){
  # First three plots have 6 rows of plots. Experiments 4 and 5 have 4 rows of plots meaning 4/6 of the first three plots
  plotRatio=4/6
}

if(x==6){
  plotRatio=5/6
}


devEval(plotFormat, name=plotname, aspectRatio=plotRatio, {
  par(las=1)
  par(mar = c(2, 4, 2, 2))
  
  
  
  baselineAverages <- data.frame(matrix(ncol = 18, nrow = nbRows))
  reportTitles <- c("Real GDP","Real Investment","Real Consumption", "Real Gov Consumption", "C Price Growth rate (%)","Gini Index (%)", "Bank's Average CAR (%)", "Real Bank's Profits",
                    "Real Bank's Dividends", "Real Bank's Loans", "Bank's Loan Interest Rate (%)", "CB's Advances Rate/ IB Rate (%)", "Real Bank's Interest Revenue", "Real Bank's Borrowing Cost",
                    "Real Bank's Deposit Interest Cost", "Real Bank's Advances Interest Cost", "Real Bank's Deposit UB Spread", "Deposit Insurance Fund")
  colnames(baselineAverages) <- reportTitles
  
  baselineAverages["Real GDP"] <- rgdpAverages[1:nbRows,nbBaseline]
  baselineAverages["Real Investment"] <- invAverages[1:nbRows,nbBaseline]
  baselineAverages["Real Consumption"] <- consAverages[1:nbRows,nbBaseline]
  baselineAverages["Real Gov Consumption"] <- govconsAverages[1:nbRows,nbBaseline]
  baselineAverages[2:nbRows,"C Price Growth rate (%)"] <- cpAverages[1:(nbRows-1),nbBaseline]
  baselineAverages[2:nbRows,"Gini Index (%)"] <- giniAverages[1:(nbRows-1),nbBaseline]
  baselineAverages["Bank's Average CAR (%)"] <- banksCARAverages[1:nbRows,nbBaseline]
  baselineAverages["Real Bank's Profits"] <- rbankprofitAverages[1:nbRows,nbBaseline]
  baselineAverages["Real Bank's Dividends"] <- rbankdividendAverages[1:nbRows,nbBaseline]
  baselineAverages["Real Bank's Loans"] <- rbankcreditAverages[1:nbRows,nbBaseline]
  
  baselineAverages["Bank's Loan Interest Rate (%)"] <- banksloanavinterestAverages[1:nbRows,nbBaseline]
  baselineAverages["CB's Advances Rate/ IB Rate (%)"] <- banksinterbankavinterestAverages[1:nbRows,nbBaseline]
  baselineAverages["Real Bank's Interest Revenue"] <- banksInterestRevenueAverages[1:nbRows,nbBaseline]
  baselineAverages["Real Bank's Borrowing Cost"] <- rbankdepinterestpaidAverages[1:nbRows,nbBaseline]+rbankadvinterestpaidAverages[1:nbRows:nbRows,nbBaseline]
  baselineAverages["Real Bank's Deposit Interest Cost"] <- rbankdepinterestpaidAverages[1:nbRows,nbBaseline]
  baselineAverages["Real Bank's Advances Interest Cost"] <- rbankadvinterestpaidAverages[1:nbRows,nbBaseline]
  baselineAverages["Cost Advantage Deposits vs Advances"] <- banksDepositUpperBoundSpreadAverages[1:nbRows,nbBaseline]
  baselineAverages["Deposit Insurance Fund"] <- rGovResAverages[1:nbRows,nbBaseline]
  baselineAverages["Firm Bankruptcies"] <- firmBankruptciesAverages[1:nbRows,nbBaseline]
  
  CBDCAverages <- data.frame(matrix(ncol = 18, nrow = nbRows))
  colnames(CBDCAverages) <- reportTitles
  
  CBDCAverages["Real GDP"] <- rgdpAverages[1:nbRows,nbCBDC]
  CBDCAverages["Real Investment"] <- invAverages[1:nbRows,nbCBDC]
  CBDCAverages["Real Consumption"] <- consAverages[1:nbRows,nbCBDC]
  CBDCAverages["Real Gov Consumption"] <- govconsAverages[1:nbRows,nbCBDC]
  CBDCAverages[2:nbRows,"C Price Growth rate (%)"] <- cpAverages[1:(nbRows-1),nbCBDC]
  CBDCAverages[2:nbRows,"Gini Index (%)"] <- giniAverages[1:(nbRows-1),nbCBDC]
  CBDCAverages["Bank's Average CAR (%)"] <- banksCARAverages[1:nbRows,nbCBDC]
  CBDCAverages["Real Bank's Profits"] <- rbankprofitAverages[1:nbRows,nbCBDC]
  CBDCAverages["Real Bank's Dividends"] <- rbankdividendAverages[1:nbRows,nbCBDC]
  CBDCAverages["Real Bank's Loans"] <- rbankcreditAverages[1:nbRows,nbCBDC]
  
  CBDCAverages["Bank's Loan Interest Rate (%)"] <- banksloanavinterestAverages[1:nbRows,nbCBDC]
  CBDCAverages["CB's Advances Rate/ IB Rate (%)"] <- banksinterbankavinterestAverages[1:nbRows,nbCBDC]
  CBDCAverages["Real Bank's Interest Revenue"] <- banksInterestRevenueAverages[1:nbRows,nbCBDC]
  CBDCAverages["Real Bank's Borrowing Cost"] <- rbankdepinterestpaidAverages[1:nbRows,nbCBDC]+rbankadvinterestpaidAverages[1:nbRows:nbRows,nbCBDC]
  CBDCAverages["Real Bank's Deposit Interest Cost"] <- rbankdepinterestpaidAverages[1:nbRows,nbCBDC]
  CBDCAverages["Real Bank's Advances Interest Cost"] <- rbankadvinterestpaidAverages[1:nbRows,nbCBDC]
  CBDCAverages["Cost Advantage Deposits vs Advances"] <- banksDepositUpperBoundSpreadAverages[1:nbRows,nbCBDC]
  CBDCAverages["Deposit Insurance Fund"] <- rGovResAverages[1:nbRows,nbCBDC]
  CBDCAverages["Firm Bankruptcies"] <- firmBankruptciesAverages[1:nbRows,nbCBDC]
  
  
  reportNames <- colnames(baselineAverages)
  
  if(x==1){
    reportNames = c("Real GDP","Real Investment","Real Consumption", "Real Gov Consumption", "C Price Growth rate (%)", "Bank's Average CAR (%)", "Real Bank's Profits",
                    "Real Bank's Dividends", "Real Bank's Loans", "Bank's Loan Interest Rate (%)", "CB's Advances Rate/ IB Rate (%)", "Real Bank's Interest Revenue", "Real Bank's Borrowing Cost",
                    "Real Bank's Deposit Interest Cost", "Real Bank's Advances Interest Cost", "Cost Advantage Deposits vs Advances")
    layout(matrix(c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18), 6, 3, byrow = TRUE))
  }
  
  if(x==2||x==3){
    reportNames = c("Real GDP","Real Investment","Real Consumption", "C Price Growth rate (%)", "Bank's Average CAR (%)", "Real Bank's Profits",
                    "Real Bank's Dividends", "Real Bank's Loans", "Bank's Loan Interest Rate (%)", "CB's Advances Rate/ IB Rate (%)", "Real Bank's Interest Revenue", "Real Bank's Borrowing Cost",
                    "Real Bank's Deposit Interest Cost", "Real Bank's Advances Interest Cost", "Cost Advantage Deposits vs Advances")
    layout(matrix(c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18), 6, 3, byrow = TRUE))
  }
  
  if(x>3){
    reportNames = c("Real GDP","Real Investment","Real Consumption", "C Price Growth rate (%)","Gini Index (%)", "Bank's Average CAR (%)", "Real Bank's Profits",
                    "Real Bank's Dividends", "Real Bank's Loans", "Bank's Loan Interest Rate (%)", "Firm Bankruptcies")
    layout(matrix(c(1,2,3,4,5,6,7,8,9,10,11,12), 4, 3, byrow = TRUE))
  }
  
  if(x==6){
    reportNames = c("Real GDP","Real Investment","Real Consumption", "C Price Growth rate (%)","Gini Index (%)", "Bank's Average CAR (%)", "Real Bank's Profits",
                    "Real Bank's Dividends", "Real Bank's Loans", "Bank's Loan Interest Rate (%)", "Firm Bankruptcies", "Deposit Insurance Fund")
    layout(matrix(c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15), 5, 3, byrow = TRUE))
  }
  
  percentageReports = c("C Price Growth rate (%)","Gini Index (%)", "Bank's Average CAR (%)","Bank's Loan Interest Rate (%)", "CB's Advances Rate/ IB Rate (%)")
  
  for (i in reportNames){
      
      yMinValue <- min(min(CBDCAverages[xlimLeft:nbRows,i]),min(baselineAverages[xlimLeft:nbRows,i]))
      yMaxValue <- max(max(CBDCAverages[xlimLeft:nbRows,i]),max(baselineAverages[xlimLeft:nbRows,i]))
      
      yAltMinValue <- baselineAverages[200,i]*0.995
      yAltMaxValue <- baselineAverages[200,i]*1.005
      
      if(any(i %in% percentageReports)){
        yAltMinValue <- baselineAverages[200,i]-0.0005
        yAltMaxValue <- baselineAverages[200,i]+0.0005
      }
      
      yMinValue <-min(yMinValue, yAltMinValue)
      yMaxValue <-max(yMaxValue, yAltMaxValue)
      
      if(i == "Firm Bankruptcies"){
        if(yMaxValue < 1){
          yMaxValue <- 1
        }
      }
      
      if(any(i %in% percentageReports) && i != "C Price Growth rate (%)"){
        plot(baselineAverages[1:nbRows,i]*100,type="l",main=i,ylab="",xlab="", lwd=2, col = "blue", xlim=c(xlimLeft,nbRows), ylim=c(yMinValue*100,yMaxValue*100), cex.lab=1, cex.axis=1, cex.main=1, cex.sub=1)
        lines(CBDCAverages[1:nbRows,i]*100,lwd=2,lty=2, col = "orange")
      }else{
        plot(baselineAverages[1:nbRows,i],type="l",main=i,ylab="",xlab="", lwd=2, col = "blue", xlim=c(xlimLeft,nbRows), ylim=c(yMinValue,yMaxValue), cex.lab=1, cex.axis=1, cex.main=1, cex.sub=1)
        lines(CBDCAverages[1:nbRows,i],lwd=2,lty=2, col = "orange")
      }

      
    
  }
  plot.new()
  if(x==6||x==2||x==3){
    plot.new()
  }
  legend("center", legend=c("Baseline", "CBDC"),
         col=c("blue", "orange"), lty=c(1,2), lwd=2, cex=1.0)
  
  
  })

scenarioIndex=scenarioIndex+2

}

getwd() 


