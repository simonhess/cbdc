package cbdc.strategies;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

import benchmark2.StaticValues;
import benchmark2.agents.Bank;
import benchmark2.agents.ConsumptionFirm;
import benchmark2.strategies.ShockStrategy;
import cern.jet.random.Uniform;
import cern.jet.random.engine.RandomEngine;
import jmab2.agents.MacroAgent;
import jmab2.population.MacroPopulation;
import jmab2.simulations.MacroSimulation;
import jmab2.stockmatrix.Bond;
import jmab2.stockmatrix.Item;
import jmab2.stockmatrix.Loan;
import net.sourceforge.jabm.Population;
import net.sourceforge.jabm.SimulationController;
import net.sourceforge.jabm.agent.Agent;
import net.sourceforge.jabm.strategy.AbstractStrategy;

public class BankAssetValueShock extends AbstractStrategy implements ShockStrategy{
	
	protected RandomEngine prng;

	public void performShock(){
		
		int round = ((MacroSimulation)((SimulationController)this.scheduler).getSimulation()).getRound();
		SimulationController controller = (SimulationController)this.getScheduler();
		MacroPopulation macroPop = (MacroPopulation) controller.getPopulation();
		Population bs = macroPop.getPopulation(StaticValues.BANKS_ID);
			
			if(round==400) {
				Uniform distr = new Uniform(0,bs.getSize()-1,prng);
				int bankruptBankIndex = distr.nextInt();
				MacroAgent bankruptBank = (MacroAgent)bs.getAgentList().get(bankruptBankIndex);
				
				double loansTotalValue=0;
				
				for (Item i:bankruptBank.getItemsStockMatrix(true, StaticValues.SM_LOAN)){
				loansTotalValue+=i.getValue();
				}
					
				double loanLosses = 0;
				
				List<Item> loans = bankruptBank.getItemsStockMatrix(true, StaticValues.SM_LOAN);
				Uniform loanDistr = new Uniform(0,loans.size()-1,prng);
			
				// reduce value of loans till
				while(loanLosses<=loansTotalValue*0.5) {
					loans = bankruptBank.getItemsStockMatrix(true, StaticValues.SM_LOAN);
					int loanIndex = loanDistr.nextIntFromTo(0, loans.size()-1);
					if(loans.size()<1)break;
					// Get random loan from bank
					Loan l= (Loan)loans.get(loanIndex);
					loanLosses+=l.getValue();
					l.setValue(0);
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

	
	public RandomEngine getPrng() {
		return prng;
	}



	public void setPrng(RandomEngine prng) {
		this.prng = prng;
	}


}
