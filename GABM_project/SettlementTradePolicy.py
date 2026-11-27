import GABM_project.Strings.strings as strings
import math, random, logging

INITIAL_TRADE_RESOURCES_PERCEIVED_VALUE = {
    "crops" : 15,
    "livestock" : 15,
    "fish" : 15,
    "pottery" : 17,
    "wood" : 12,
    "luxury" : 20
}

INITIAL_RESOURCES_GAINED_THROUGH_TRADE = {
    "crops" : 0,
    "livestock" : 0,
    "fish" : 0,
    "pottery" : 0,
    "wood" : 0,
    "luxury" : 0
}

class SettlementTradePolicy:
    def __init__(self, settlement_id, population, uThres_total, cultivated_resources, trade_resources):
        self.settlement_id = settlement_id
        self.population = population
        self.uThres_total = uThres_total
        self.cultivated_resources = cultivated_resources
        self.trade_resources = trade_resources.copy()
        self.transition_probabilities = {res: 1.0 for res in trade_resources.keys()}
        self.transition_probabilities[strings.RESOURCES[5]] = 0.5 # luxury resources are rarer at the beginning of the simulation
        self.perceived_trade_resources_values = INITIAL_TRADE_RESOURCES_PERCEIVED_VALUE.copy()
        self.resources_gained_through_trade = INITIAL_RESOURCES_GAINED_THROUGH_TRADE.copy()
        self.has_traded_this_turn = False
        self.state = {}
        self.set_state()

    def update_resources_gained_through_trade(self, resources_gained_through_trade):
        for resource in strings.RESOURCES:
            self.resources_gained_through_trade[resource] += resources_gained_through_trade[resource]
        self.set_state()
    
    def set_has_traded_this_turn(self, has_traded_this_turn):
        self.has_traded_this_turn = has_traded_this_turn
        self.set_state()

    def set_state(self):
        self.state = {
            "settlement_id" : self.settlement_id,
            "population": self.population,
            "uThres_total" : self.uThres_total,
            "cultivated_resources" : self.cultivated_resources,
            "trade_resources": self.trade_resources.copy(),
            "resources_gained_through_trade": self.resources_gained_through_trade.copy(),
            "has_traded_this_turn": self.has_traded_this_turn
        }

    def get_state(self):
        return self.state

    def update_state(self, settlement_id, population, uThres_total, cultivated_resources, trade_resources):
        self.settlement_id = settlement_id
        self.population = population
        self.uThres_total = uThres_total
        self.cultivated_resources = cultivated_resources
        self.trade_resources = trade_resources.copy()
        self.has_traded_this_turn = False # reset
        self.resources_gained_through_trade = INITIAL_RESOURCES_GAINED_THROUGH_TRADE.copy() # reset
        self.set_state()
    
    def get_reward(self, action):
        resource_type, amount = action
        reward = 0

        if (resource_type == strings.RESOURCES[5] and self.cultivated_resources < self.uThres_total):
            reward = -100
        else:
            reward = self.perceived_trade_resources_values[resource_type] * self.transition_probabilities[resource_type]
        return reward
    
    def get_candidate_actions(self, goal_utility):
        actions = []
        for res in self.trade_resources.keys():
            if res == strings.RESOURCES[5] and self.cultivated_resources < self.uThres_total:
                continue
            actions.append((res, goal_utility))
        return actions
    
    # e-greedy policy
    def policy(self, epsilon=0.1):
        goal_utility = self.calculate_goal_trade_utility(self.settlement_id, self.uThres_total, self.cultivated_resources, self.population)

        actions = self.get_candidate_actions(goal_utility)

        if random.random() < epsilon:
            best_action = random.choice(actions)
        else:
            best_action = max(actions, key=lambda a: self.get_reward(a))
        best_action_reward = self.get_reward(best_action)
        
        return best_action
    
    # learning rate alpha set at 0.1
    def update_policy(self, action, alpha=0.1):
        if (not self.has_traded_this_turn): # if the settlement didn't participate in trades
            return
        
        resource, goal_utility = action
        old_transition_probability = self.transition_probabilities[resource]
        total_gained_goal = self.resources_gained_through_trade[resource]

        if (total_gained_goal >= 0.8 * goal_utility):
            self.transition_probabilities[resource] = (1 - alpha) * old_transition_probability + alpha
        else:
            self.transition_probabilities[resource] = (1 - alpha) * old_transition_probability

        logging.info(f"Transition Probability: {self.transition_probabilities[resource]}\n")

    @staticmethod
    def calculate_goal_trade_utility(settlement_id, uThres_settlement_total, total_utility, population):
        missing_utility = 0.0
        if (total_utility >= uThres_settlement_total):
            if (population > 100):
                missing_utility = uThres_settlement_total*0.02
            elif (population > 50):
                missing_utility = uThres_settlement_total*0.015
            elif (population > 25):
                missing_utility = uThres_settlement_total*0.01
            else:
                missing_utility = uThres_settlement_total*0.005
            return int(missing_utility)
        else:
            # If the settlement doesn't possess the required utility, the missing utility is the difference between the threshold and the total utility
            missing_utility = uThres_settlement_total - total_utility
            return int(missing_utility)