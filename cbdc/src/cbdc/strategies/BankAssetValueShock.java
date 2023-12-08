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
			
			if(round==201) {
				Uniform distr = new Uniform(0,bs.getSize()-1,prng);
				int bankruptBankIndex = distr.nextInt();
				MacroAgent bankruptBank = (MacroAgent)bs.getAgentList().get(bankruptBankIndex);
				
				double loansTotalValue=0;
				
				for (Item i:bankruptBank.getItemsStockMatrix(true, StaticValues.SM_LOAN)){
				loansTotalValue+=i.getValue();
				}
				
				double loansSold = 0;
				
				List<Item> loans = bankruptBank.getItemsStockMatrix(true, StaticValues.SM_LOAN);
				Uniform loanDistr = new Uniform(0,loans.size()-1,prng);

				// Determine solvent banks
				
				ArrayList<Bank> solventBanks = new ArrayList<Bank>();
				
				for(Agent mA:bs.getAgents()) {
					Bank b = (Bank) mA;
					if(!b.equals(bankruptBank)) {
						solventBanks.add(b);
					}
				}
				Uniform receiverDistr = new Uniform(0,solventBanks.size()-1,prng);
				
				while(loansSold<loansTotalValue*0.25) {
					loans = bankruptBank.getItemsStockMatrix(true, StaticValues.SM_LOAN);
					int loanIndex = loanDistr.nextIntFromTo(0, loans.size()-1);
	
					// Get random loan from bank
					Loan l= (Loan)loans.get(loanIndex);
					loansSold+=l.getValue();
					int receiverBankID = receiverDistr.nextInt();
					// Assign loan to other random bank
					MacroAgent receiverBank = solventBanks.get(receiverBankID);
					l.setAssetHolder(receiverBank);
					bankruptBank.removeItemStockMatrix(l, true, StaticValues.SM_LOAN);
					receiverBank.addItemStockMatrix(l, true, StaticValues.SM_LOAN);
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
