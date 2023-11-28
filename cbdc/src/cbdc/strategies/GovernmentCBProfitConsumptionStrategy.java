/*
 * JMAB - Java Macroeconomic Agent Based Modeling Toolkit
 * Copyright (C) 2013 Alessandro Caiani and Antoine Godin
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 3 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 */
package cbdc.strategies;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import benchmark2.StaticValues;
import benchmark2.agents.CentralBank;
import benchmark2.agents.ConsumptionFirm;
import benchmark2.agents.Government;
import jmab2.agents.AbstractHousehold;
import jmab2.agents.BondDemander;
import jmab2.agents.MacroAgent;
import jmab2.population.MacroPopulation;
import jmab2.population.MarketPopulation;
import jmab2.simulations.MacroSimulation;
import jmab2.simulations.SimpleMarketSimulation;
import jmab2.stockmatrix.Bond;
import jmab2.stockmatrix.Deposit;
import jmab2.stockmatrix.Item;
import jmab2.stockmatrix.Loan;
import jmab2.strategies.ConsumptionStrategy;
import net.sourceforge.jabm.Population;
import net.sourceforge.jabm.SimulationController;
import net.sourceforge.jabm.agent.Agent;
import net.sourceforge.jabm.strategy.AbstractStrategy;

/**
 * @author Simon Hess: With this strategy the government invests its profits from central bank into consumption goods
 *
 */
@SuppressWarnings("serial")
public class GovernmentCBProfitConsumptionStrategy extends AbstractStrategy
		implements ConsumptionStrategy {
	
	/* (non-Javadoc)
	 * @see jmab2.strategies.ConsumptionStrategy#computeRealConsumptionDemand()
	 */
	@Override
	public double computeRealConsumptionDemand() {
		
		// Calculate average price on market
		
		MacroSimulation macroSim = ((MacroSimulation)((SimulationController)this.scheduler).getSimulation());
		SimpleMarketSimulation marketSim = (SimpleMarketSimulation) macroSim.getMarket(StaticValues.MKT_CONSGOOD);
		MarketPopulation marketPop = marketSim.getPopulation();
		List<Agent> sellers = marketPop.getSellers().getAgents();
		double avPrice = 0;
		for(Agent a: sellers) {
			ConsumptionFirm cF = (ConsumptionFirm) a;
			avPrice += cF.getPrice();
		}
		
		avPrice /= sellers.size();
		
		//Calculate expected cb profits
		
		MacroPopulation macroPop = (MacroPopulation) macroSim.getPopulation();

		Population cbPop = macroPop.getPopulation(StaticValues.CB_ID);
		
		CentralBank cb = (CentralBank)cbPop.getAgentList().get(0);
		
		List<Item> reserves=cb.getItemsStockMatrix(false, StaticValues.SM_RESERVES);
		
		double reserveInterest = 0;
		
		for(int i=0;i<reserves.size();i++){
			Deposit deposit=(Deposit)reserves.get(i);
			double iRate=deposit.getInterestRate();
			reserveInterest+= deposit.getValue()*iRate;
		}
		
		
		List<Item> loans=cb.getItemsStockMatrix(true, StaticValues.SM_ADVANCES);

		double advancesInterests = 0;
		
		for(int i=0;i<loans.size();i++){
			Loan loan=(Loan)loans.get(i);
			if(loan.getAge()>0){
				double iRate=loan.getInterestRate();
				double amount=loan.getInitialAmount();
				int length = loan.getLength();
				double interests=iRate*loan.getValue();
				double principal=0.0;
				switch(loan.getAmortization()){
				case Loan.FIXED_AMOUNT:
					double amortization = amount*(iRate*Math.pow(1+iRate, length))/(Math.pow(1+iRate, length)-1);
					principal=amortization-interests;
					break;
				case Loan.FIXED_CAPITAL:
					principal=amount/length;
					break;
				case Loan.ONLY_INTERESTS:
					if(length==loan.getAge())
						principal=amount;
					break;
				}
				advancesInterests+=interests;
			}
		}
			
		List<Item> bonds=cb.getItemsStockMatrix(true, StaticValues.SM_BONDS);

		double interestsBonds=0;
		for(Item b:bonds){
			Bond bond=(Bond)b;
				interestsBonds+=bond.getValue()*bond.getInterestRate();
		}
		
		double expCBProfit = (advancesInterests+interestsBonds-reserveInterest)/avPrice;
		
		return expCBProfit;
	}

	@Override
	public byte[] getBytes() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void populateFromBytes(byte[] content, MacroPopulation pop) {
		// TODO Auto-generated method stub
		
	}
	
}
