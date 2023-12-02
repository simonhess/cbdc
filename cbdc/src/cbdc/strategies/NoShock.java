package cbdc.strategies;

import java.util.ArrayList;
import java.util.Collections;

import benchmark2.StaticValues;
import benchmark2.agents.Bank;
import benchmark2.agents.CapitalFirm;
import benchmark2.agents.ConsumptionFirm;
import benchmark2.agents.Households;
import benchmark2.strategies.ShockStrategy;
import jmab2.agents.MacroAgent;
import jmab2.population.MacroPopulation;
import jmab2.simulations.MacroSimulation;
import jmab2.stockmatrix.Item;
import net.sourceforge.jabm.Population;
import net.sourceforge.jabm.SimulationController;
import net.sourceforge.jabm.agent.Agent;
import net.sourceforge.jabm.strategy.AbstractStrategy;

public class NoShock extends AbstractStrategy implements ShockStrategy{
	
	public void performShock(){
		
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
