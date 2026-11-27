import time, logging, os
import matplotlib.pyplot as plt
from collections import defaultdict
import seaborn as sns
import pandas as pd
import networkx as nx
import GABM_project.Strings.strings as strings
import numpy as np

class Metrics:
    def __init__(self, date_time_start):
        self.settlement_ids = []                                      # contains the settlement ids of all settlements
        self.settlement_ids_trade = []                                # contains the settlement ids of all settlements that participated in trades
        self.total_trade_interactions_dict = {}                       # dictionary (key: settlement id) with the total amount of trade interactions
        self.total_trade_interactions_accept_dict = {}                # dictionary (key: settlement id) with the total amount of trade interactions where a negotiator accepted a deal
        self.total_trade_interactions_quit_dict = {}                  # dictionary (key: settlement id) with the total amount of trade interactions where a negotiator quit
        self.total_trade_interactions_timeout_dict = {}               # dictionary (key: settlement id) with the total amount of trade interactions that timed out
        self.total_trade_interactions_invalid_dict = {}               # dictionary (key: settlement id) with the total amount of trade interactions that were invalid
        self.total_rounds_of_negotiation_accept_dict = {}             # dictionary (key: settlement id) with the total rounds of trade interactions where a negotiator accepted a deal
        self.total_rounds_of_negotiation_quit_dict = {}               # dictionary (key: settlement id) with the total rounds of trade interactions where a negotiator quit
        self.total_rounds_of_negotiation_timeout_dict = {}            # dictionary (key: settlement id) with the total rounds of trade interactions that timed out
        self.total_rounds_of_negotiation_invalid_dict = {}            # dictionary (key: settlement id) with the total rounds of trade interactions that were invalid
        self.total_resources_gained_dict = {}                         # dictionary (key: settlement id) with the total resources gained
        self.total_resources_given_dict = {}                          # dictionary (key: settlement id) with the total resources given
        self.total_resource_gain_dict = {}                            # dictionary (key: settlement id) with the total resource gain of each settlement
        self.settlement_trade_success_rate_dict = {}                  # dictionary (keys: settlement ids) with the success rate of each settlement
        self.total_trade_interactions = 0                             # total number of trade interactions
        self.total_trade_interactions_accept = 0                      # total number of trade interactions where a negotiator accepted a deal
        self.total_trade_interactions_quit = 0                        # total number of trade interactions where a negotiator quit
        self.total_trade_interactions_timeout = 0                     # total number of trade interactions where the rounds timed out
        self.total_trade_interactions_invalid = 0                     # total number of trade interactions where the the result was invalid
        self.total_negotiation_rounds = 0                             # total negotiation rounds across all trade interactions
        self.start_time = time.perf_counter()                         # start time of netlogo loop
        self.end_time = 0                                             # end time of netlogo loop
        self.netlogo_runtime = {}                                     # total netlogo and LLM negotiation runtime in hours, minutes and seconds
        self.gini_over_time_given = []                                # the gini coefficient at every time step (year) for the resources given
        self.gini_over_time_gained = []                               # the gini coefficient at every time step (year) for the resources gained
        self.N = 5                                                                           # used for calculating top N stuff
        self.graph_node_scale = 30                                                           # scale of nodes for graphs
        self.date_time_start = date_time_start                                               # used for Figures folder naming
        self.settlement_interaction_dict = defaultdict(lambda: defaultdict(int))             # dictionary (keys: settlement ids - origin and target) with the total interactions between pairs of settlements
        self.settlement_interaction_accept_dict = defaultdict(lambda: defaultdict(int))      # dictionary (keys: settlement ids - origin and target) with the total interactions between pairs of settlements - accepted trade
        self.settlement_interaction_quit_dict = defaultdict(lambda: defaultdict(int))        # dictionary (keys: settlement ids - origin and target) with the total interactions between pairs of settlements - quit trade
        self.settlement_interaction_timeout_dict = defaultdict(lambda: defaultdict(int))     # dictionary (keys: settlement ids - origin and target) with the total interactions between pairs of settlements - timed out
        self.settlement_interaction_invalid_dict = defaultdict(lambda: defaultdict(int))     # dictionary (keys: settlement ids - origin and target) with the total interactions between pairs of settlements - invalid trade
        self.divided_resources_given_dict = defaultdict(lambda: defaultdict(int))            # dictionary (keys: settlement ids - resource_type) with the total of each resource that was given
        self.divided_resources_gained_dict = defaultdict(lambda: defaultdict(int))           # dictionary (keys: settlement ids - resource_type) with the total of each resource that was gained
        
        # create directories for figures and logs
        self.current_dir = os.path.dirname(os.path.abspath(__file__))
        self.path = self.current_dir
        for _ in range(2):
            self.path = os.path.dirname(self.path)

        figures_root = os.path.join(self.path, "Figures")
        os.makedirs(figures_root, exist_ok=True)

        self.figures_dir = os.path.join(figures_root, f"Figures_{date_time_start}")
        os.makedirs(self.figures_dir, exist_ok=True)
        return
    

    def calculate_gini_coefficient(self, array):
        array = np.array(array, dtype=np.float64)
        if np.amin(array) < 0:
            raise ValueError("Gini coefficient is not defined for negative values.")
        if array.sum() == 0:
            return 0.0

        array = np.sort(array)
        n = len(array)
        index = np.arange(1, n + 1)
        return (2 * np.sum(index * array) - (n + 1) * np.sum(array)) / (n * np.sum(array))


    def update_divided_resources(self, settlementId, give, take):
        settlementId = int(settlementId)
        self.divided_resources_given_dict[settlementId][strings.RESOURCES[0]] += give[strings.RESOURCES[0]]
        self.divided_resources_given_dict[settlementId][strings.RESOURCES[1]] += give[strings.RESOURCES[1]]
        self.divided_resources_given_dict[settlementId][strings.RESOURCES[2]] += give[strings.RESOURCES[2]]
        self.divided_resources_given_dict[settlementId][strings.RESOURCES[3]] += give[strings.RESOURCES[3]]
        self.divided_resources_given_dict[settlementId][strings.RESOURCES[4]] += give[strings.RESOURCES[4]]

        self.divided_resources_gained_dict[settlementId][strings.RESOURCES[0]] += take[strings.RESOURCES[0]]
        self.divided_resources_gained_dict[settlementId][strings.RESOURCES[1]] += take[strings.RESOURCES[1]]
        self.divided_resources_gained_dict[settlementId][strings.RESOURCES[2]] += take[strings.RESOURCES[2]]
        self.divided_resources_gained_dict[settlementId][strings.RESOURCES[3]] += take[strings.RESOURCES[3]]
        self.divided_resources_gained_dict[settlementId][strings.RESOURCES[4]] += take[strings.RESOURCES[4]]
        return


    def calculate_netlogo_runtime(self):
        self.end_time = time.perf_counter()
        elapsed_time = self.end_time - self.start_time
        hours = int(elapsed_time // 3600)
        minutes = int((elapsed_time % 3600) // 60)
        seconds = elapsed_time % 60
        self.netlogo_runtime["hours"] = hours
        self.netlogo_runtime["minutes"] = minutes
        self.netlogo_runtime["seconds"] = seconds
        return self.netlogo_runtime


    # updates the given dictionary by the amount of value
    def update_dictionary(self, dictionary, settlementId, value):
        settlementId = int(settlementId)
        if (settlementId in dictionary):
            dictionary[settlementId] += value
        else:
            dictionary[settlementId] = value
        return
    

    def sort_dictionary(self, dictionary, order):
        if (order == "asc"):
            sorted_dict = dict(sorted(dictionary.items(), key=lambda item: item[1]))
        elif (order == "dsc"):
            sorted_dict = dict(sorted(dictionary.items(), key=lambda item: item[1], reverse=True))
        else:
            sorted_dict = {}
        return sorted_dict
    

    def add_settlement_id_trades(self, settlementId):
        settlementId = int(settlementId)
        if settlementId not in self.settlement_ids_trade:
            self.settlement_ids_trade.append(settlementId)


    def add_settlement_id(self, settlementId):
        settlementId = int(settlementId)
        if settlementId not in self.settlement_ids:
            self.settlement_ids.append(settlementId)
    

    def calculate_settlement_total_resource_gain(self, settlementId):
        settlementId = int(settlementId)
        return self.total_resources_gained_dict[settlementId] - self.total_resources_given_dict[settlementId]
    

    def calculate_all_settlements_total_gain(self):
        for settlementId in self.settlement_ids_trade:
            if settlementId in self.total_resources_gained_dict and settlementId in self.total_resources_given_dict:
                self.total_resource_gain_dict[settlementId] = self.calculate_settlement_total_resource_gain(settlementId)
            else:
                if settlementId in self.total_resources_gained_dict:
                    self.total_resource_gain_dict[settlementId] = self.total_resources_gained_dict[settlementId]
                elif settlementId in self.total_resources_given_dict:
                    self.total_resource_gain_dict[settlementId] = -self.total_resources_given_dict[settlementId]
    

    def convert_dict_to_matrix(self, dictionary):
        all_keys = sorted(set(dictionary.keys()) | {dst for src in dictionary for dst in dictionary[src]})
        matrix = pd.DataFrame(0, index=all_keys, columns=all_keys)

        for src in dictionary:
            for dst in dictionary[src]:
                matrix.loc[src, dst] = dictionary[src][dst]
        return matrix


    def calculate_settlement_success_rate(self):
        total = 0
        for settlementId in self.settlement_ids_trade:
            accepted = self.total_trade_interactions_accept_dict.get(settlementId, 0)
            quitted = self.total_trade_interactions_quit_dict.get(settlementId, 0)
            timedout = self.total_trade_interactions_timeout_dict.get(settlementId, 0)
            
            accepted = int(accepted)
            quitted = int(quitted)
            timedout = int(timedout)

            total = accepted + quitted + timedout
            success_rate = accepted / total if total > 0 else 0
            self.settlement_trade_success_rate_dict[settlementId] = success_rate * 100


    def plot_deal_results(self):
        plt.figure()

        labels = [
            'Total', 
            'Accepted', 
            'Quitted', 
            'Timed out',  
            'Invalid'
        ]
        values = [
            self.total_trade_interactions, 
            self.total_trade_interactions_accept, 
            self.total_trade_interactions_quit, 
            self.total_trade_interactions_timeout, 
            self.total_trade_interactions_invalid
        ]

        plt.bar(labels, values)

        plt.xlabel("Number of negotiations")
        plt.ylabel("Quantity")
        plt.title("Negotiation Results")
        fig_path = os.path.join(self.figures_dir, "negotiation_results_plot.png")
        plt.savefig(fig_path)
        return
    

    def plot_gini_over_time_gained(self):
        years = list(range(-3100, -3100 + len(self.gini_over_time_gained)))
        years= [abs(y) for y in years]
        years.reverse()

        plt.figure()
        plt.plot(years, self.gini_over_time_gained, marker='o', linestyle='-')
        plt.xticks(
            ticks=years[::1],
            rotation=45
        )
        plt.xlabel("Year (BCE)")
        plt.ylabel("Gini Coefficient")
        plt.title("Gini Coefficient Over Time for Gained Resources")
        plt.ylim(0, 1)
        plt.grid(True)
        plt.tight_layout()
        fig_path = os.path.join(self.figures_dir, "gini_over_time_gained_plot.png")
        plt.savefig(fig_path)
        return


    def plot_gini_over_time_given(self):
        years = list(range(-3100, -3100 + len(self.gini_over_time_gained)))
        years= [abs(y) for y in years]
        years.reverse()

        plt.figure()
        plt.plot(years, self.gini_over_time_given, marker='o', linestyle='-')
        plt.xlabel("Year (BCE)")
        plt.ylabel("Gini Coefficient")
        plt.title("Gini Coefficient Over Time for Given Resources")
        plt.ylim(0, 1)
        plt.grid(True)
        plt.tight_layout()
        fig_path = os.path.join(self.figures_dir, "gini_over_time_given_plot.png")
        plt.savefig(fig_path)
        return


    def plot_n_best_settlements_by_success_rate(self, N):
        if not self.settlement_trade_success_rate_dict:
            return
        
        plt.figure()

        cleaned_dict = {int(k): v for k, v in self.settlement_trade_success_rate_dict.items()}
        sorted_dict = self.sort_dictionary(cleaned_dict, "asc")
        
        N = min(N, len(sorted_dict))

        top_N = list(sorted_dict.items())[N:]

        labels = [str(item[0]) for item in top_N]
        values = [item[1] for item in top_N]

        plt.bar(labels, values)

        plt.xlabel("Trade success rate")
        plt.ylabel("Settlement ID")
        plt.title(f"Best {N} settlements by trade success rate")
        fig_path = os.path.join(self.figures_dir, "N_best_settlements_success_rate_bar_plot.png")
        plt.savefig(fig_path)
        return
    

    def plot_n_worst_settlements_by_success_rate(self, N):
        if not self.settlement_trade_success_rate_dict:
            return
        
        plt.figure()

        cleaned_dict = {int(k): v for k, v in self.settlement_trade_success_rate_dict.items()}
        sorted_dict = self.sort_dictionary(cleaned_dict, "dsc")

        N = min(N, len(sorted_dict))
        
        top_N = list(sorted_dict.items())[N:]

        labels = [str(item[0]) for item in top_N]
        values = [item[1] for item in top_N]

        plt.bar(labels, values)

        plt.xlabel("Trade success rate")
        plt.ylabel("Settlement ID")
        plt.title(f"Worst {N} settlements by trade success rate")
        fig_path = os.path.join(self.figures_dir, "N_worst_settlements_success_rate_bar_plot.png")
        plt.savefig(fig_path)
        return
    

    def plot_n_best_settlements_by_total_gain(self, N):
        if not self.total_resource_gain_dict:
            return
        
        plt.figure()

        cleaned_dict = {int(k): v for k, v in self.total_resource_gain_dict.items()}
        sorted_dict = self.sort_dictionary(cleaned_dict, "asc")
        
        N = min(N, len(sorted_dict))

        top_N = list(sorted_dict.items())[-N:]

        labels = [str(item[0]) for item in top_N]
        values = [item[1] for item in top_N]

        plt.bar(labels, values)

        plt.xlabel("Total resource gain")
        plt.ylabel("Settlement ID")
        plt.title(f"Best {N} settlements by total resource gain")
        fig_path = os.path.join(self.figures_dir, "N_best_settlements_resource_gain_bar_plot.png")
        plt.savefig(fig_path)
        return
    

    def plot_n_worst_settlements_by_total_gain(self, N):
        if not self.total_resource_gain_dict:
            return
        
        plt.figure()

        cleaned_dict = {int(k): v for k, v in self.total_resource_gain_dict.items()}
        sorted_dict = self.sort_dictionary(cleaned_dict, "dsc")

        N = min(N, len(sorted_dict))
        
        top_N = list(sorted_dict.items())[:N]

        labels = [str(item[0]) for item in top_N]
        values = [item[1] for item in top_N]

        plt.bar(labels, values)

        plt.xlabel("Total resource gain")
        plt.ylabel("Settlement ID")
        plt.title(f"Worst {N} settlements by total resource gain")
        fig_path = os.path.join(self.figures_dir, "N_worst_settlements_resource_gain_bar_plot.png")
        plt.savefig(fig_path)
        return
    
    
    def heatmap_total_interactions(self):
        cleaned_dict = {
            int(outer_k): {int(inner_k): v for inner_k, v in inner_v.items()}
            for outer_k, inner_v in self.settlement_interaction_dict.items()
        }
        settlement_interaction_matrix = self.convert_dict_to_matrix(cleaned_dict)

        if settlement_interaction_matrix.empty or settlement_interaction_matrix.isnull().all().all():
            return 

        plt.figure()

        sns.heatmap(settlement_interaction_matrix, cmap="YlGnBu")
        plt.title("Total trade interactions between settlements")
        fig_path = os.path.join(self.figures_dir, "total_trade_interactions_heatmap.png")
        plt.savefig(fig_path)
        return
    

    def heatmap_total_interactions_accept(self):
        cleaned_dict = {
            int(outer_k): {int(inner_k): v for inner_k, v in inner_v.items()}
            for outer_k, inner_v in self.settlement_interaction_accept_dict.items()
        }
        settlement_interaction_accept_matrix = self.convert_dict_to_matrix(cleaned_dict)

        if settlement_interaction_accept_matrix.empty or settlement_interaction_accept_matrix.isnull().all().all():
            return       

        plt.figure()

        sns.heatmap(settlement_interaction_accept_matrix, cmap="YlGnBu")
        plt.title("Total accepted trade interactions between settlements")
        fig_path = os.path.join(self.figures_dir, "total_trade_interactions_accept_heatmap.png")
        plt.savefig(fig_path)
        return
    

    def heatmap_total_interactions_quit(self):
        cleaned_dict = {
            int(outer_k): {int(inner_k): v for inner_k, v in inner_v.items()}
            for outer_k, inner_v in self.settlement_interaction_quit_dict.items()
        }
        settlement_interaction_quit_matrix = self.convert_dict_to_matrix(cleaned_dict)

        if settlement_interaction_quit_matrix.empty or settlement_interaction_quit_matrix.isnull().all().all():
            return

        plt.figure()

        sns.heatmap(settlement_interaction_quit_matrix, cmap="YlGnBu")
        plt.title("Total quitted trade interactions between settlements")
        fig_path = os.path.join(self.figures_dir, "total_trade_interactions_quit_heatmap.png")
        plt.savefig(fig_path)
        return
    

    def heatmap_total_interactions_timeout(self):
        cleaned_dict = {
            int(outer_k): {int(inner_k): v for inner_k, v in inner_v.items()}
            for outer_k, inner_v in self.settlement_interaction_timeout_dict.items()
        }
        settlement_interaction_timeout_matrix = self.convert_dict_to_matrix(cleaned_dict)

        if settlement_interaction_timeout_matrix.empty or settlement_interaction_timeout_matrix.isnull().all().all():
            return
        
        plt.figure()

        sns.heatmap(settlement_interaction_timeout_matrix, cmap="YlGnBu")
        plt.title("Total timed out trade interactions between settlements")
        fig_path = os.path.join(self.figures_dir, "total_trade_interactions_timeout_heatmap.png")
        plt.savefig(fig_path)
        return
    

    def heatmap_total_interactions_invalid(self):
        cleaned_dict = {
            int(outer_k): {int(inner_k): v for inner_k, v in inner_v.items()}
            for outer_k, inner_v in self.settlement_interaction_invalid_dict.items()
        }
        settlement_interaction_invalid_matrix = self.convert_dict_to_matrix(cleaned_dict)

        if settlement_interaction_invalid_matrix.empty or settlement_interaction_invalid_matrix.isnull().all().all():
            return
        
        plt.figure()

        sns.heatmap(settlement_interaction_invalid_matrix, cmap="YlGnBu")
        plt.title("Total invalid trade interactions between settlements")
        fig_path = os.path.join(self.figures_dir, "total_trade_interactions_invalid_heatmap.png")
        plt.savefig(fig_path)
        return
    

    def trade_accept_network_graph(self):
        if not self.settlement_interaction_accept_dict:
            return
        
        plt.figure()

        settlement_interaction_accept_matrix = self.convert_dict_to_matrix(self.settlement_interaction_accept_dict)
        G = nx.from_pandas_adjacency(settlement_interaction_accept_matrix, create_using=nx.DiGraph())

        node_sizes = (settlement_interaction_accept_matrix.sum(axis=0) + settlement_interaction_accept_matrix.sum(axis=1)).values * self.graph_node_scale

        edge_weights = [G[u][v]['weight'] for u, v in G.edges()]
        edge_widths = [w * 0.5 for w in edge_weights] 

        pos = nx.spring_layout(G, seed=42, k=2.0)

        nx.draw(
            G, pos,
            with_labels=True,
            node_size=node_sizes,
            width=edge_widths,
            edge_color='blue',
            node_color='orange',
            arrowsize=15,
            arrowstyle='-|>'
        )

        plt.title("Settlement trade network")
        fig_path = os.path.join(self.figures_dir, "trade_network_graph.png")
        plt.savefig(fig_path)
        return
    
    
    def plot_all(self):
        self.plot_deal_results()
        self.plot_n_best_settlements_by_total_gain(self.N)
        self.plot_n_worst_settlements_by_total_gain(self.N)
        self.plot_n_best_settlements_by_success_rate(self.N)
        self.plot_n_worst_settlements_by_success_rate(self.N)
        self.plot_gini_over_time_gained()
        self.plot_gini_over_time_given()
        return
    

    def heatmap_all(self):
        self.heatmap_total_interactions()
        self.heatmap_total_interactions_accept()
        self.heatmap_total_interactions_quit()
        self.heatmap_total_interactions_timeout()
        self.heatmap_total_interactions_invalid()
        return
    

    def graphs_all(self):
        self.trade_accept_network_graph()
        return


    def show_all_plots(self):
        self.plot_all()
        self.heatmap_all()
        self.graphs_all()
        return
    

    def print_negotiation_metrics(self):
        print(f"The total negotiation time was: {self.netlogo_runtime['hours']} hours, {self.netlogo_runtime['minutes']} minutes, {self.netlogo_runtime['seconds']} seconds.\n")
        logging.info(f"The total negotiation time was: {self.netlogo_runtime['hours']} hours, {self.netlogo_runtime['minutes']} minutes, {self.netlogo_runtime['seconds']} seconds.\n")

        print(f"Total trade interactions between settlements: {self.total_trade_interactions}\n")
        logging.info(f"Total trade interactions between settlements: {self.total_trade_interactions}\n")

        print(f"Total accepted trade interactions between settlements: {self.total_trade_interactions_accept}\n")
        logging.info(f"Total accepted trade interactions between settlements: {self.total_trade_interactions_accept}\n")

        print(f"Total quitted trade interactions between settlements: {self.total_trade_interactions_quit}\n")
        logging.info(f"Total quitted trade interactions between settlements: {self.total_trade_interactions_quit}\n")

        print(f"Total timed out trade interactions between settlements: {self.total_trade_interactions_timeout}\n")
        logging.info(f"Total timed out trade interactions between settlements: {self.total_trade_interactions_timeout}\n")

        print(f"Total invalid trade interactions between settlements: {self.total_trade_interactions_invalid}\n")
        logging.info(f"Total invalid trade interactions between settlements: {self.total_trade_interactions_invalid}\n")

        print(f"Total settlements: {len(self.settlement_ids)}\n")
        logging.info(f"Total settlements: {len(self.settlement_ids)}\n")

        print(f"Total settlements that negotiated: {len(self.settlement_ids_trade)}\n")
        logging.info(f"Total settlements that negotiated: {len(self.settlement_ids_trade)}\n")

        print(f"Total resources gained by settlement {self.settlement_ids_trade[0]}: {self.total_resources_gained_dict[self.settlement_ids_trade[0]]}\n")
        logging.info(f"Total resources gained by settlement {self.settlement_ids_trade[0]}: {self.total_resources_gained_dict[self.settlement_ids_trade[0]]}\n")

        print(f"Total resources given by settlement {self.settlement_ids_trade[0]}: {self.total_resources_given_dict[self.settlement_ids_trade[0]]}\n")
        logging.info(f"Total resources given by settlement {self.settlement_ids_trade[0]}: {self.total_resources_given_dict[self.settlement_ids_trade[0]]}\n")

        average_success_rate = sum(self.settlement_trade_success_rate_dict.values()) / len(self.settlement_trade_success_rate_dict) if self.settlement_trade_success_rate_dict else 0
        print(f"Average success rate of settlement trade: {average_success_rate}\n")
        logging.info(f"Average success rate of settlement trade: {average_success_rate}\n")
        
        average_negotiation_rounds = self.total_negotiation_rounds / self.total_trade_interactions if self.total_trade_interactions > 0 else self.total_negotiation_rounds
        print(f"Average number of negotiation rounds: {average_negotiation_rounds}\n")
        logging.info(f"Average number of negotiation rounds: {average_negotiation_rounds}\n")
        
        total_resources_gained_list = [self.total_resources_gained_dict.get(sid, 0) for sid in self.settlement_ids]
        gini = self.calculate_gini_coefficient(total_resources_gained_list)
        print(f"Gini Coefficient for total resources gained by settlements: {gini}\n")
        logging.info(f"Gini Coefficient for total resources gained by settlements: {gini}\n")

        total_resources_given_list = [self.total_resources_given_dict.get(sid, 0) for sid in self.settlement_ids]
        gini = self.calculate_gini_coefficient(total_resources_given_list)
        print(f"Gini Coefficient for total resources given by settlements: {gini}\n")
        logging.info(f"Gini Coefficient for total resources given by settlements: {gini}\n")

        return