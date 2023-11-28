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
package cbdc.agents;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import benchmark2.StaticValues;
import benchmark2.agents.CentralBank;
import benchmark2.agents.ConsumptionFirm;
import benchmark2.agents.GovernmentAntiCyclical;
import benchmark2.strategies.ShockStrategy;
import cern.jet.random.engine.RandomEngine;
import jmab2.agents.BondSupplier;
import jmab2.agents.GoodDemander;
import jmab2.agents.LaborDemander;
import jmab2.agents.LaborSupplier;
import jmab2.agents.LiabilitySupplier;
import jmab2.agents.MacroAgent;
import jmab2.events.MacroTicEvent;
import jmab2.population.MacroPopulation;
import jmab2.population.MarketPopulation;
import jmab2.simulations.MacroSimulation;
import jmab2.simulations.SimpleMarketSimulation;
import jmab2.simulations.TwoStepMarketSimulation;
import jmab2.stockmatrix.Bond;
import jmab2.stockmatrix.Deposit;
import jmab2.stockmatrix.Item;
import jmab2.strategies.ConsumptionStrategy;
import jmab2.strategies.InterestRateStrategy;
import jmab2.strategies.InvestmentStrategy;
import jmab2.strategies.RealCapitalDemandStrategy;
import jmab2.strategies.SelectSellerStrategy;
import jmab2.strategies.SelectWorkerStrategy;
import net.sourceforge.jabm.Population;
import net.sourceforge.jabm.SimulationController;
import net.sourceforge.jabm.agent.Agent;
import net.sourceforge.jabm.agent.AgentList;
import net.sourceforge.jabm.event.AgentArrivalEvent;

/**
 * @author Alessandro Caiani and Antoine Godin
 * Note that the government uses a reserve account in the central bank rather than a deposit account due to
 * the bond market.
 */
/**
 * @author Alessandro Caiani and Antoine Godin
 *
 */
@SuppressWarnings("serial")
public class GovernmentAntiCyclicalWithInvestment extends GovernmentAntiCyclical implements LaborDemander, BondSupplier, GoodDemander{
	
	protected double desiredRealCapitalDemand;
	protected ArrayList<Agent> selectedCapitalGoodSuppliers;
	private double demand;


	/* (non-Javadoc)
	 * @see jmab2.agents.SimpleAbstractAgent#onTicArrived(AgentTicEvent)
	 */
	@Override
	protected void onTicArrived(MacroTicEvent event) {
		switch(event.getTic()){
		case StaticValues.TIC_GOVERNMENTLABOR:
			computeLaborDemand();
			break;
		case StaticValues.TIC_UNEMPLOYMENTBENEFITAMOUNT:
			determineUnemploymentBenefitAmount(event.getSimulationController());
			break;
		case StaticValues.TIC_TAXES:
			collectTaxes(event.getSimulationController());
			break;
		case StaticValues.TIC_INVESTMENTDEMAND:
			computeDesiredInvestment(null);
			break;
		case StaticValues.TIC_CONSUMPTIONDEMAND:
			computeConsumptionDemand();
			break;
		case StaticValues.TIC_BONDINTERESTS:
			payInterests();
			break;
		case StaticValues.TIC_BONDSUPPLY:
			receiveCBProfits();
			determineBondsInterestRate();
			emitBonds();
			break;
		case StaticValues.TIC_WAGEPAYMENT:
			payWages();
			payUnemploymentBenefits(event.getSimulationController());
			break;
		case StaticValues.TIC_COMPUTEAGGREGATES:
			this.updateAggregateVariables();
			break;
		case StaticValues.TIC_UPDATEEXPECTATIONS:
			this.updateExpectations();
			break;
		case StaticValues.TIC_SHOCK:
			this.performShock();
			break;
		}
		
	}
	
	private void performShock() {
		// TODO Auto-generated method stub
		ShockStrategy shockStrategy = (ShockStrategy) this.getStrategy(StaticValues.STRATEGY_SHOCK);
		shockStrategy.performShock();
		
	}

	public void onAgentArrival(AgentArrivalEvent event) {
		MacroSimulation macroSim = (MacroSimulation)event.getSimulationController().getSimulation();
		int marketID=macroSim.getActiveMarket().getMarketId();
		switch(marketID){
		case StaticValues.MKT_LABOR: //se should use random robin mixer in the case of government labor market
			SelectWorkerStrategy strategy = (SelectWorkerStrategy) this.getStrategy(StaticValues.STRATEGY_LABOR);
			List<MacroAgent> workers= (List<MacroAgent>)strategy.selectWorkers(event.getObjects(),this.laborDemand);
			for(MacroAgent worker:workers)
				macroSim.getActiveMarket().commit(this, worker,marketID);
			break;
		case StaticValues.MKT_CAPGOOD:
			TwoStepMarketSimulation sim = (TwoStepMarketSimulation)macroSim.getActiveMarket();
			if(sim.isFirstStep()){				
				this.selectedCapitalGoodSuppliers=event.getObjects();
			}else if(sim.isSecondStep()){
				int nbSellers = this.selectedCapitalGoodSuppliers.size()+1;//There are nbSellers+1 options for the firm to invest
				for(int i=0; i<nbSellers&&this.desiredRealCapitalDemand>0&&this.selectedCapitalGoodSuppliers.size()>0;i++){
					SelectSellerStrategy buyingStrategy = (SelectSellerStrategy) this.getStrategy(StaticValues.STRATEGY_BUYING);
					MacroAgent selSupplier = buyingStrategy.selectGoodSupplier(this.selectedCapitalGoodSuppliers, desiredRealCapitalDemand, true);
					computeDesiredInvestment(selSupplier);
					macroSim.getActiveMarket().commit(this, selSupplier,marketID);
					this.selectedCapitalGoodSuppliers.remove(selSupplier);
				}
			}
			break;
		case StaticValues.MKT_CONSGOOD:
//			SelectSellerStrategy sellerStrategy = (SelectSellerStrategy) this.getStrategy(StaticValues.STRATEGY_BUYING);
//			MacroAgent seller = sellerStrategy.selectGoodSupplier(event.getObjects(), this.demand, true); 
//			macroSim.getActiveMarket().commit(this, seller, marketID);
			
			SimpleMarketSimulation marketSim = (SimpleMarketSimulation) macroSim.getActiveMarket();
			MarketPopulation marketPop = marketSim.getPopulation();
			List<Agent> sellers = marketPop.getSellers().getAgents();
			double totalSupply = 0;
			for(Agent a: sellers) {
				ConsumptionFirm cF = (ConsumptionFirm) a;
				Item output = cF.getItemStockMatrix(true, StaticValues.SM_CONSGOOD);
				totalSupply+= output.getQuantity();
			}
			double initialDemand = this.demand;
			for(Agent a: sellers) {
				ConsumptionFirm cF = (ConsumptionFirm) a;
				Item output = cF.getItemStockMatrix(true, StaticValues.SM_CONSGOOD);
				double marketShare = output.getQuantity()/totalSupply;
				double maxQuantity = marketShare*initialDemand;
				this.demand = maxQuantity;
				macroSim.getActiveMarket().commit(this, cF,marketID);
			}
			break;
		}
	}

	/**
	 * 
	 */
	private void receiveCBProfits() {
		Item deposit=this.getItemStockMatrix(true, StaticValues.SM_RESERVES);
		CentralBank cb=(CentralBank) deposit.getLiabilityHolder();
		deposit.setValue(deposit.getValue()+cb.getCBProfits());
		profitsFromCB=cb.getCBProfits();
	}


	/**
	 * Sets the labor demand equal to the fixed labor demand
	 */
	@Override
	protected void computeLaborDemand() {
		int currentWorkers = this.employees.size();
		AgentList emplPop = new AgentList();
		for(MacroAgent ag : this.employees)
			emplPop.add(ag);
		emplPop.shuffle(prng);
		for(int i=0;i<this.turnoverLabor*currentWorkers;i++){
			fireAgent((MacroAgent)emplPop.get(i));
		}
		cleanEmployeeList();
		currentWorkers = this.employees.size();
		int nbWorkers = this.fixedLaborDemand;
		if(nbWorkers>currentWorkers){
			this.setActive(true, StaticValues.MKT_LABOR);
			this.laborDemand=nbWorkers-currentWorkers;
		}else{
			this.setActive(false, StaticValues.MKT_LABOR);
			this.laborDemand=0;
			emplPop = new AgentList();
			for(MacroAgent ag : this.employees)
				emplPop.add(ag);
			emplPop.shuffle(prng);
			for(int i=0;i<currentWorkers-nbWorkers;i++){
				fireAgent((MacroAgent)emplPop.get(i));
			}
		}
		cleanEmployeeList();	
	}

	protected void payWages(){
		if(employees.size()>0){
			Deposit deposit = (Deposit) this.getItemStockMatrix(true, StaticValues.SM_RESERVES);
			payWages(deposit,StaticValues.MKT_LABOR);
		}
	}

	/**
	 * @return the doleExpenditure
	 */
	public double getDoleExpenditure() {
		return doleExpenditure;
	}

	/**
	 * @param doleExpenditure the doleExpenditure to set
	 */
	public void setDoleExpenditure(double doleExpenditure) {
		this.doleExpenditure = doleExpenditure;
	}


	/**
	 * @return the profitsFromCB
	 */
	public double getProfitsFromCB() {
		return profitsFromCB;
	}

	/**
	 * @param profitsFromCB the profitsFromCB to set
	 */
	public void setProfitsFromCB(double profitsFromCB) {
		this.profitsFromCB = profitsFromCB;
	}	

	/**
	 * 
	 */
	protected void computeDesiredInvestment(MacroAgent selectedCapitalGoodSupplier) {
		Deposit deposit = (Deposit) this.getItemsStockMatrix(true, StaticValues.SM_RESERVES).get(1);
		if(deposit.getValue()>0) {
		this.desiredRealCapitalDemand=deposit.getValue();
		}
		else {this.desiredRealCapitalDemand=0;}
		if(desiredRealCapitalDemand>0){
			this.setActive(true,StaticValues.MKT_CAPGOOD);
		}
	}
	
	/**
	 * 
	 */
	private void computeConsumptionDemand() {
		ConsumptionStrategy strategy = (ConsumptionStrategy)this.getStrategy(StaticValues.STRATEGY_CONSUMPTION);
		this.setDemand(strategy.computeRealConsumptionDemand(), StaticValues.MKT_CONSGOOD);
		//this.addValue(StaticValues.LAG_CONSUMPTION, this.demand);
		
		if (this.demand>0){
			this.setActive(true, StaticValues.MKT_CONSGOOD);
		}
	}
	
	/**
	 * Populates the agent characteristics using the byte array content. The structure is as follows:
	 * [sizeMacroAgentStructure][MacroAgentStructure][bondPrice][bondInterestRate][turnoverLabor][unemploymentBenefit][laborDemand]
	 * [fixedLaborDemand][bondMaturity][sizeTaxedPop][taxedPopulations][matrixSize][stockMatrixStructure][expSize][ExpectationStructure]
	 * [passedValSize][PassedValStructure][stratsSize][StrategiesStructure]
	 */
	@Override
	public void populateAgent(byte[] content, MacroPopulation pop) {
		ByteBuffer buf = ByteBuffer.wrap(content);
		byte[] macroBytes = new byte[buf.getInt()];
		buf.get(macroBytes);
		super.populateCharacteristics(macroBytes, pop);
		bondPrice = buf.getDouble();
		bondInterestRate = buf.getDouble();
		turnoverLabor = buf.getDouble();
		unemploymentBenefit = buf.getDouble();
		laborDemand = buf.getInt();
		fixedLaborDemand = buf.getInt();
		bondMaturity = buf.getInt();
		int lengthTaxedPopulatiobns = buf.getInt();
		taxedPopulations = new int[lengthTaxedPopulatiobns];
		for(int i = 0 ; i < lengthTaxedPopulatiobns ; i++){
			taxedPopulations[i] = buf.getInt();
		}
		int matSize = buf.getInt();
		if(matSize>0){
			byte[] smBytes = new byte[matSize];
			buf.get(smBytes);
			this.populateStockMatrixBytes(smBytes, pop);
		}
		int expSize = buf.getInt();
		if(expSize>0){
			byte[] expBytes = new byte[expSize];
			buf.get(expBytes);
			this.populateExpectationsBytes(expBytes);
		}
		int lagSize = buf.getInt();
		if(lagSize>0){
			byte[] lagBytes = new byte[lagSize];
			buf.get(lagBytes);
			this.populatePassedValuesBytes(lagBytes);
		}
		int stratSize = buf.getInt();
		if(stratSize>0){
			byte[] stratBytes = new byte[stratSize];
			buf.get(stratBytes);
			this.populateStrategies(stratBytes, pop);
		}
	}
	
	/**
	 * protected ArrayList<MacroAgent> employees;
	protected UnemploymentRateComputer uComputer; 
	 * Generates the byte array containing all relevant informations regarding the household agent. The structure is as follows:
	 * [sizeMacroAgentStructure][MacroAgentStructure][bondPrice][bondInterestRate][turnoverLabor][unemploymentBenefit][laborDemand]
	 * [fixedLaborDemand][bondMaturity][sizeTaxedPop][taxedPopulations][matrixSize][stockMatrixStructure][expSize][ExpectationStructure]
	 * [passedValSize][PassedValStructure][stratsSize][StrategiesStructure]
	 */
	@Override
	public byte[] getBytes() {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		try {
			byte[] charBytes = super.getAgentCharacteristicsBytes();
			out.write(ByteBuffer.allocate(4).putInt(charBytes.length).array());
			out.write(charBytes);
			ByteBuffer buf = ByteBuffer.allocate(48+4*taxedPopulations.length);
			buf.putDouble(bondPrice);
			buf.putDouble(bondInterestRate);
			buf.putDouble(turnoverLabor);
			buf.putDouble(unemploymentBenefit);
			buf.putInt(laborDemand);
			buf.putInt(fixedLaborDemand);
			buf.putInt(bondMaturity);
			buf.putInt(taxedPopulations.length);
			for(int i = 0 ; i < taxedPopulations.length ; i++){
				buf.putInt(taxedPopulations[i]);
			}
			out.write(buf.array());
			byte[] smBytes = super.getStockMatrixBytes();
			out.write(ByteBuffer.allocate(4).putInt(smBytes.length).array());
			out.write(smBytes);
			byte[] expBytes = super.getExpectationsBytes();
			out.write(ByteBuffer.allocate(4).putInt(expBytes.length).array());
			out.write(expBytes);
			byte[] passedValBytes = super.getPassedValuesBytes();
			out.write(ByteBuffer.allocate(4).putInt(passedValBytes.length).array());
			out.write(passedValBytes);
			byte[] stratsBytes = super.getStrategiesBytes();
			out.write(ByteBuffer.allocate(4).putInt(stratsBytes.length).array());
			out.write(stratsBytes);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return out.toByteArray();
	}

	@Override
	public double getDemand(int idMarket) {
		// TODO Auto-generated method stub
		if(idMarket==StaticValues.MKT_CAPGOOD) {
			return this.desiredRealCapitalDemand;
		}else {
			return this.demand;
		}
	}

	@Override
	public void setDemand(double d, int idMarket) {
		// TODO Auto-generated method stub
		if(idMarket==StaticValues.MKT_CAPGOOD) {
			this.desiredRealCapitalDemand=d;
		}else {
			this.demand=d;
		}
	}
}
