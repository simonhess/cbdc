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

public class CBDCShock extends AbstractStrategy implements ShockStrategy{
	
	public void performShock(){
		
		int round = ((MacroSimulation)((SimulationController)this.scheduler).getSimulation()).getRound();
		
		if(round==200) {
			SimulationController controller = (SimulationController)this.getScheduler();
			MacroPopulation macroPop = (MacroPopulation) controller.getPopulation();
			Population hhs = macroPop.getPopulation(StaticValues.HOUSEHOLDS_ID);
			Population cs = macroPop.getPopulation(StaticValues.CONSUMPTIONFIRMS_ID);
			Population ks = macroPop.getPopulation(StaticValues.CAPITALFIRMS_ID);
			
			
			for(Agent a:hhs.getAgents()) {
				Households h = (Households) a;
				h.setPreferredDepositRatio(0);
				h.setPreferredCashRatio(0);
				h.setPreferredReserveRatio(1);
			}
			
			for(Agent a:cs.getAgents()) {
				ConsumptionFirm c = (ConsumptionFirm) a;
				c.setPreferredDepositRatio(0);
				c.setPreferredCashRatio(0);
				c.setPreferredReserveRatio(1);
			}
			
			for(Agent a:ks.getAgents()) {
				CapitalFirm k = (CapitalFirm) a;
				k.setPreferredDepositRatio(0);
				k.setPreferredCashRatio(0);
				k.setPreferredReserveRatio(1);
			}
			
		}
		
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
