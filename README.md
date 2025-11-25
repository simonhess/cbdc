# CBDC Model

## Overview

This project contains the code for the Agent-based Stock-Flow Consistent model used in the paper: "What Difference Does Central Bank Digital Currency Make? Insights from an Agent-based Model".

The model is based on the <a href="https://github.com/simonhess/benchmark2">JMAB 2.0 benchmark model</a> with minor adjustments:
- The government spends the central bank's profits on consumption goods.
- Bank deposits are sticky meaning that banks adjust their deposit rate only with a certain probability.
- An optional deposit insurance system.

## Prerequisites

JMAB requires Java version 6 or later. It has been tested against version 1.6.0_35 and 1.7.0_75.

Note that on Mac OS, you will need to use the Oracle version of Java instead of the default one shipped with the OS.

## Installation

This repository can be directly imported in Eclipse with the URI: https://github.com/simonhess/cbdc.git and the "Clone Submodules" option being on.

Alternatively, clone this repository recursively and import it in Eclipse as an local Git repository:

```
git clone --recursive https://github.com/simonhess/cbdc.git
```

## Use the model

Use Eclipse and run the Main.java class in the /src/cbdc folder with the VM arguments "-Djabm.config=Model/exp1mainCorridorBaseline.xml -Xmx4G -Xms4G" . In order to do so open the "Run configurations..." menu in Eclipse in the dropdown menu of the Run-Button, go to the arguments tab and add the arguments in the VM arguments section.

## Replicate the paper results

To replicate the results of the paper perform the following steps:

1. Run the simulation for each of the following scenarios with the corresponding VM arguments:

| Scenario| VM argument |
| --- | --- |
| I Baseline| -Djabm.config=Model/exp1mainCorridorBaseline.xml -Xmx4G -Xms4G |
| I CBDC| -Djabm.config=Model/exp2mainCorridorCBDC.xml -Xmx4G -Xms4G|
| II Baseline| -Djabm.config=Model/exp3mainZeroInterestBaseline.xml -Xmx4G -Xms4G|
| II CBDC| -Djabm.config=Model/exp4mainZeroInterestCBDC.xml -Xmx4G -Xms4G|
| III Baseline| -Djabm.config=Model/exp5mainFloorBaseline.xml -Xmx4G -Xms4G|
| III CBDC| -Djabm.config=Model/exp6mainFloorCBDC.xml -Xmx4G -Xms4G|
| IV Baseline| -Djabm.config=Model/exp7mainBailoutBaseline.xml -Djabm.propertyfile=Model/bankAssetShockExperiment.properties -Xmx4G -Xms4G|
| IV CBDC| -Djabm.config=Model/exp8mainBailoutCBDC.xml -Djabm.propertyfile=Model/bankAssetShockExperiment.properties -Xmx4G -Xms4G|
| V Baseline| -Djabm.config=Model/exp9mainBailinBaseline.xml -Djabm.propertyfile=Model/bankAssetShockExperiment.properties -Xmx4G -Xms4G|
| V CBDC| -Djabm.config=Model/exp10mainBailinCBDC.xml -Djabm.propertyfile=Model/bankAssetShockExperiment.properties -Xmx4G -Xms4G|
| VI Baseline| -Djabm.config=Model/exp11mainDepositInsuranceBaseline.xml -Djabm.propertyfile=Model/bankAssetShockExperiment.properties -Xmx4G -Xms4G|
| VI CBDC| -Djabm.config=Model/exp12mainDepositInsuranceCBDC.xml -Djabm.propertyfile=Model/bankAssetShockExperiment.properties -Xmx4G -Xms4G|

2. Open the file /data/CBDCAnalysis.R in R studio and remove the comment symbol "#" in the following lines (Lines 57-59):

```
#source("MergeMonteCarloSim.R")
#generateMergedCSV(folder)
#generateSums(folder)
```

3. Run the /data/CBDCAnalysis.R file to create the plots.

4. Run the /data/CBDCBalanceSheetPlots.R file to create the balance sheet plots.

The plots will be created in the /data folder.


## Custom calibration

To change the calibration of the model edit the .ipynb file in the "/calibration" folder and execute the file with the <a href="https://www.sagemath.org/">SageMath Software</a>. The calibration should print a calibration xml block into the .ipynb file which can be copied into a .xml configuration file in the /Model/ folder.
