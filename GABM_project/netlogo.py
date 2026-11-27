import pynetlogo, random, math, logging
import GABM_project.Strings.netlogo_strings as nlStrings
import GABM_project.Strings.llm_negotiation_strings as negStrings
import GABM_project.llm_negotiation as neg
import GABM_project.Strings.strings as strings
from GABM_project.SettlementTradePolicy import SettlementTradePolicy

GLOBAL_MIN_ELEVATION = 0.0
MAX_COAST_DISTANCE = 50.0 # 5km

MIN_FOOD_FRACTION = 0.1  # fixed minimum fraction for crops and livestock


global_max_elevation = 0.0
settlement_max_elevation = 0.0

settlement_mdp_dict = {}

def initialize_netlogo(netlogoHome, netlogoModelPath, interaction_model):
    # Load netlogo home and the AncientS-ABM model
    netlogo = pynetlogo.NetLogoLink(gui=False, netlogo_home=netlogoHome)
    netlogo.load_model(netlogoModelPath)

    # run setup and set Settlement-Interaction to Gravity or XTENT
    netlogo.command('setup')

    netlogo.command(f'set Settlement-Interaction "{interaction_model}"')
    netlogo.command('set sint Settlement-Interaction')

    # Get the global maximum elevation of the ABM land patches
    global global_max_elevation 
    global_max_elevation = netlogo.report("max [elevation] of patches")
    return netlogo

def netlogo_loop(netlogo, isPrintingEnabled, metrics, maxYears, negotiator, is_minimal_printing_enabled, is_settlement_stats_printing_enabled):
    for years in range(maxYears):

        if(is_minimal_printing_enabled):
            print("\n------------------------------------New Year Start------------------------------------\n\n")
        logging.info("\n------------------------------------New Year Start------------------------------------\n\n")

        netlogo.command('go-init')
        netlogo.command('go-update-environment')
        netlogo.command('go-cultivate-harvest')
        netlogo.command('go-self-organization')

        # Check if spatial interactions are enabled -> trade
        sint = netlogo.report('sint')
        if (sint != nlStrings.settlement_interaction_options["OFF"]):
            #if (years % 5 == 0):
                spatial_interaction(netlogo, isPrintingEnabled, metrics, negotiator, is_minimal_printing_enabled, is_settlement_stats_printing_enabled)
        
        netlogo.command('go-agents-update')
        netlogo.command('go-selection-dynamics')
        netlogo.command('go-population-dynamics')
        netlogo.command('go-natural-disaster')
        netlogo.command('go-tick-end')


def spatial_interaction(netlogo, isPrintingEnabled, metrics, negotiator, is_minimal_printing_enabled, is_settlement_stats_printing_enabled):
    netlogo.command('spatial-interaction-init')
    netlogo.command('spatial-interaction-calculate-importance')
    netlogo.command('spatial-interaction-calculate-trade-targets')

    # Get the out interactions of all settlements
    out_interactions = netlogo.report('get-all-settlement-out-interaction-pairs')
    (
        elevation_dict, coastline_dict, river_dict, spring_dict, 
        household_dict, population_dict, resource_dict, 
        uThres_household_avg_dict, uThres_settlement_total_dict, total_utility_dict,
        settlement_resources_dict, settlement_id_list
    ) = get_settlement_stats(netlogo, is_settlement_stats_printing_enabled)

    # Distribute the trade resources of all settlements into types (fish, crops, etc.)
    for sid in settlement_id_list:
        distributed_resources = distribute_resources(
            sid,
            settlement_resources_dict[sid],
            elevation_dict,
            coastline_dict, 
            river_dict, 
            spring_dict, 
            household_dict, 
            population_dict,
            global_max_elevation, 
            GLOBAL_MIN_ELEVATION, 
            MAX_COAST_DISTANCE, 
            is_settlement_stats_printing_enabled
        )
        resource_dict[sid] = distributed_resources

    # Initialize or update the MDPs
    initialize_or_update_Policies(settlement_id_list, population_dict, uThres_settlement_total_dict, total_utility_dict, resource_dict)

    # get the best action for the settlement
    settlement_actions_dict = {}
    for sid, mdp in settlement_mdp_dict.items():
        # Get the action and goal utility for this settlement
        selected_resource, goal_utility = mdp.policy()
        
        settlement_actions_dict[sid] = {
            "resource": selected_resource,
            "goal_utility": goal_utility
        }

    if (out_interactions[0][0] != -1 and out_interactions[0][1] != -1):

        for settlement_ids in out_interactions:
            # if [-1, -1] -> no trades
            if (settlement_ids[0] != -1 and settlement_ids[1] != -1):
                metrics.add_settlement_id(settlement_ids[0])
                metrics.add_settlement_id(settlement_ids[1])

                if (settlement_resources_dict[settlement_ids[0]] > 0 and settlement_resources_dict[settlement_ids[1]] > 0):
                    metrics.add_settlement_id_trades(settlement_ids[0])
                    metrics.add_settlement_id_trades(settlement_ids[1])

                    # Update total interactions for both settlements
                    metrics.total_trade_interactions += 1
                    metrics.update_dictionary(metrics.total_trade_interactions_dict, settlement_ids[0], 1)
                    metrics.update_dictionary(metrics.total_trade_interactions_dict, settlement_ids[1], 1)
                    metrics.settlement_interaction_dict[int(settlement_ids[0])][int(settlement_ids[1])] += 1

                    action, give, take, rounds, id = neg.negotiate_simple( 
                        isPrintingEnabled,
                        resource_dict[settlement_ids[0]],
                        resource_dict[settlement_ids[1]],
                        (settlement_actions_dict[settlement_ids[0]]["resource"], settlement_actions_dict[settlement_ids[0]]["goal_utility"]),
                        (settlement_actions_dict[settlement_ids[1]]["resource"], settlement_actions_dict[settlement_ids[1]]["goal_utility"]),
                        settlement_mdp_dict[settlement_ids[0]].resources_gained_through_trade[settlement_actions_dict[settlement_ids[0]]["resource"]],
                        settlement_mdp_dict[settlement_ids[1]].resources_gained_through_trade[settlement_actions_dict[settlement_ids[1]]["resource"]],
                        settlement_ids[0],
                        settlement_ids[1],
                        metrics,
                        negotiator
                    )

                    settlement_mdp_dict[settlement_ids[0]].set_has_traded_this_turn(True)
                    settlement_mdp_dict[settlement_ids[1]].set_has_traded_this_turn(True)

                    if(is_minimal_printing_enabled):
                        print(f"""\nNegotiation between settlements {settlement_ids[0]} and {settlement_ids[1]} resulted in {action}
                            \n\n-------------------------------------------------------------------\n""")
                    logging.info(f"""\nNegotiation between settlements {settlement_ids[0]} and {settlement_ids[1]} resulted in {action}
                            \n\n-------------------------------------------------------------------\n""")

                    # Handle action -> and update metrics
                    if (action == negStrings.ACTIONS["ACCEPT"]):   
                        # Update metrics
                        metrics.total_trade_interactions_accept += 1
                        metrics.update_dictionary(metrics.total_trade_interactions_accept_dict, settlement_ids[0], 1)
                        metrics.update_dictionary(metrics.total_trade_interactions_accept_dict, settlement_ids[1], 1)
                        metrics.update_dictionary(metrics.total_rounds_of_negotiation_accept_dict, settlement_ids[0], rounds)
                        metrics.update_dictionary(metrics.total_rounds_of_negotiation_accept_dict, settlement_ids[1], rounds)
                        metrics.settlement_interaction_accept_dict[int(settlement_ids[0])][int(settlement_ids[1])] += 1

                        # calculate the total amount of resources given and taken
                        # then add and subtract the resources that were traded from each settlement
                        total_give, total_take = calculate_total_give_take(give, take, id, settlement_ids, settlement_resources_dict[settlement_ids[0]], settlement_resources_dict[settlement_ids[1]], metrics)
                        if (id == settlement_ids[0]):
                            updated_resources0 = add_subtract_tradable_resources(netlogo, give, take, total_give, total_take, resource_dict[settlement_ids[0]], settlement_ids[0])
                            updated_resources1 = add_subtract_tradable_resources(netlogo, take, give, total_take, total_give, resource_dict[settlement_ids[1]], settlement_ids[1])
                            resource_dict[settlement_ids[0]] = updated_resources0
                            resource_dict[settlement_ids[1]] = updated_resources1
                            settlement_resources_dict[settlement_ids[0]] = settlement_resources_dict[settlement_ids[0]] - total_give + total_take
                            settlement_resources_dict[settlement_ids[1]] = settlement_resources_dict[settlement_ids[1]] + total_give - total_take
                            metrics.update_dictionary(metrics.total_resources_gained_dict, settlement_ids[0], total_take)
                            metrics.update_dictionary(metrics.total_resources_given_dict, settlement_ids[0], total_give)
                            metrics.update_dictionary(metrics.total_resources_gained_dict, settlement_ids[1], total_give)
                            metrics.update_dictionary(metrics.total_resources_given_dict, settlement_ids[1], total_take)
                        else:
                            updated_resources1 = add_subtract_tradable_resources(netlogo, give, take, total_give, total_take, resource_dict[settlement_ids[1]], settlement_ids[1])
                            updated_resources0 = add_subtract_tradable_resources(netlogo, take, give, total_take, total_give, resource_dict[settlement_ids[0]], settlement_ids[0])
                            resource_dict[settlement_ids[0]] = updated_resources0
                            resource_dict[settlement_ids[1]] = updated_resources1
                            settlement_resources_dict[settlement_ids[1]] = settlement_resources_dict[settlement_ids[1]] - total_give + total_take
                            settlement_resources_dict[settlement_ids[0]] = settlement_resources_dict[settlement_ids[0]] + total_give - total_take
                            metrics.update_dictionary(metrics.total_resources_gained_dict, settlement_ids[0], total_give)
                            metrics.update_dictionary(metrics.total_resources_given_dict, settlement_ids[0], total_take)
                            metrics.update_dictionary(metrics.total_resources_gained_dict, settlement_ids[1], total_take)
                            metrics.update_dictionary(metrics.total_resources_given_dict, settlement_ids[1], total_give)

                    elif (action == negStrings.ACTIONS["QUIT"]):
                        # Update metrics
                        metrics.total_trade_interactions_quit += 1
                        metrics.update_dictionary(metrics.total_trade_interactions_quit_dict, settlement_ids[0], 1)
                        metrics.update_dictionary(metrics.total_trade_interactions_quit_dict, settlement_ids[1], 1)
                        metrics.update_dictionary(metrics.total_rounds_of_negotiation_quit_dict, settlement_ids[0], rounds)
                        metrics.update_dictionary(metrics.total_rounds_of_negotiation_quit_dict, settlement_ids[1], rounds)
                        metrics.settlement_interaction_quit_dict[int(settlement_ids[0])][int(settlement_ids[1])] += 1

                    elif (action == negStrings.ACTIONS["TIMEOUT"]): # Negotiation timed out
                        # Update metrics
                        metrics.total_trade_interactions_timeout += 1
                        metrics.update_dictionary(metrics.total_trade_interactions_timeout_dict, settlement_ids[0], 1)
                        metrics.update_dictionary(metrics.total_trade_interactions_timeout_dict, settlement_ids[1], 1)
                        metrics.update_dictionary(metrics.total_rounds_of_negotiation_timeout_dict, settlement_ids[0], rounds)
                        metrics.update_dictionary(metrics.total_rounds_of_negotiation_timeout_dict, settlement_ids[1], rounds)
                        metrics.settlement_interaction_timeout_dict[int(settlement_ids[0])][int(settlement_ids[1])] += 1

                    else: # Negotiation was invalid
                        # Update metrics
                        metrics.total_trade_interactions_invalid += 1
                        metrics.update_dictionary(metrics.total_trade_interactions_invalid_dict, settlement_ids[0], 1)
                        metrics.update_dictionary(metrics.total_trade_interactions_invalid_dict, settlement_ids[1], 1)
                        metrics.update_dictionary(metrics.total_rounds_of_negotiation_invalid_dict, settlement_ids[0], rounds)
                        metrics.update_dictionary(metrics.total_rounds_of_negotiation_invalid_dict, settlement_ids[1], rounds)
                        metrics.settlement_interaction_invalid_dict[int(settlement_ids[0])][int(settlement_ids[1])] += 1

        # calculate the gini coefficients
        total_resources_gained_list = [metrics.total_resources_gained_dict.get(sid, 0) for sid in metrics.settlement_ids]
        metrics.gini_over_time_gained.append(metrics.calculate_gini_coefficient(total_resources_gained_list))
        total_resources_given_list = [metrics.total_resources_given_dict.get(sid, 0) for sid in metrics.settlement_ids]
        metrics.gini_over_time_given.append(metrics.calculate_gini_coefficient(total_resources_given_list))\
        
        # update the policy for each settlement
        update_all_settlement_MDPs(settlement_id_list, settlement_actions_dict)

        # Add any remaining tradable resources to the settlement payoff - to be distributed to the households
        netlogo.command('spatial-interaction-payoff-cleanup')

    # distribute the payoff to households and
    # update the trade network
    netlogo.command("spatial-interaction-distribute-payoff-and-Update-network")
    return

# set the resources of the settlement to their new value after trade
def add_subtract_tradable_resources(netlogo, give, take, total_give, total_take, resources, target_id):
    updated_resources = calculate_remaining_resources(give, take, resources)
    command = f"""
        ask settlement {target_id} [
            set tradable-resources tradable-resources - {total_give}
            set payoff payoff + {total_take}
        ]
    """

    # update what the settlement gained (in mdp -> to update the policy at the end)
    settlement_mdp_dict[target_id].update_resources_gained_through_trade(take)
    netlogo.command(command)
    return updated_resources

# calculate the total amount of resources taken/given
def calculate_total_give_take(give, take, id, settlement_ids, resources0, resources1, metrics):
    total_give = give[strings.RESOURCES[0]] + give[strings.RESOURCES[1]] + give[strings.RESOURCES[2]] + give[strings.RESOURCES[3]] + give[strings.RESOURCES[4]] + give[strings.RESOURCES[5]]
    total_take = take[strings.RESOURCES[0]] + take[strings.RESOURCES[1]] + take[strings.RESOURCES[2]] + take[strings.RESOURCES[3]] + take[strings.RESOURCES[4]] + take[strings.RESOURCES[5]]

    if (id == settlement_ids[0]):
        total_give = min(total_give, resources0)
        total_take = min(total_take, resources1)
        metrics.update_divided_resources(settlement_ids[0], give, take)
        metrics.update_divided_resources(settlement_ids[1], take, give)
    else:
        total_give = min(total_give, resources1)
        total_take = min(total_take, resources0)
        metrics.update_divided_resources(settlement_ids[1], give, take)
        metrics.update_divided_resources(settlement_ids[0], take, give)
    return total_give, total_take

# calculate remaining individual resources after trade
def calculate_remaining_resources(give, take, resources):
    crops = max(0, resources[strings.RESOURCES[0]] - give[strings.RESOURCES[0]] + take[strings.RESOURCES[0]])
    livestock = max(0, resources[strings.RESOURCES[1]] - give[strings.RESOURCES[1]] + take[strings.RESOURCES[1]])
    fish = max(0, resources[strings.RESOURCES[2]] - give[strings.RESOURCES[2]] + take[strings.RESOURCES[2]])
    pottery = max(0, resources[strings.RESOURCES[3]] - give[strings.RESOURCES[3]] + take[strings.RESOURCES[3]])
    wood = max(0, resources[strings.RESOURCES[4]] - give[strings.RESOURCES[4]] + take[strings.RESOURCES[4]])
    luxury = max(0, resources[strings.RESOURCES[5]] - give[strings.RESOURCES[5]] + take[strings.RESOURCES[5]])

    return {
        'crops': crops,
        'livestock': livestock,
        'fish': fish,
        'pottery': pottery,
        'wood': wood,
        'luxury':luxury
    }

def get_settlement_stats(netlogo, is_settlement_stats_printing_enabled):
    # Get the max, average, min elevation and distance to coastline per settlement
    elevation_stats = netlogo.report('settlement-elevation-stats')
    coastline_stats = netlogo.report('all-settlements-dt-coastline')

    # Get the number of cultivated patches with a river or spring per settlement
    river_stats = netlogo.report('settlement-river-stats')
    spring_stats = netlogo.report('settlement-spring-stats')

    # Get the household and population numbers per settlement
    household_stats = netlogo.report('settlement-households')
    population_stats = netlogo.report('settlement-populations')

    # The average (minimum) resources that each household of the settlement needs to survive
    uThres_household_avg_stats = netlogo.report('settlement-uThres-household-avg-stats')

    # The total minimum resources that the settlement needs so that all households survive
    uThres_settlement_total_stats = netlogo.report('settlement-uThres-total-stats')

    # The total utility of the settlement this year (round)
    total_utility_stats = netlogo.report("settlement-total-utility")

    tradable_resources_stats = netlogo.report('settlements-tradable-resources')
    

    # Convert to dictionaries
    elevation_dict = { stat[0]: {'avg_elev': stat[1], 'max_elev': stat[2], 'min_elev': stat[3]} for stat in elevation_stats}
    coastline_dict = {settlement_id: dt_coast for settlement_id, dt_coast in coastline_stats}
    river_dict = { stat[0]: {'river_patches': stat[1]} for stat in river_stats}
    spring_dict = { stat[0]: {'spring_patches': stat[1]} for stat in spring_stats}
    household_dict = {sid: count for sid, count in household_stats}
    population_dict = {sid: pop for sid, pop in population_stats}
    uThres_household_avg_dict = {sid: avg for sid, avg in uThres_household_avg_stats}
    uThres_settlement_total_dict = {sid: total for sid, total in uThres_settlement_total_stats}
    total_utility_dict = {sid: total for sid, total in total_utility_stats}
    settlement_resources_dict = {sid: resources for sid, resources in tradable_resources_stats}
    settlement_id_list = list(elevation_dict.keys())


    global settlement_max_elevation
    settlement_max_elevation = max(entry['max_elev'] for entry in elevation_dict.values())

    resource_dict = {
        sid: {
            'crops': -1,
            'livestock': -1,
            'fish': -1,
            'pottery': -1,
            'wood': -1
        } for sid in elevation_dict.keys()
    }

    # print the stats for each settlement
    if (is_settlement_stats_printing_enabled):
        print_settlement_stats(elevation_dict, coastline_dict, river_dict, spring_dict, household_dict, population_dict, 
                             uThres_household_avg_dict, uThres_settlement_total_dict, total_utility_dict)
    log_settlement_stats(elevation_dict, coastline_dict, river_dict, spring_dict, household_dict, population_dict, 
                             uThres_household_avg_dict, uThres_settlement_total_dict, total_utility_dict)

    return (elevation_dict, coastline_dict, river_dict, spring_dict, household_dict, population_dict, resource_dict, uThres_household_avg_dict, 
            uThres_settlement_total_dict, total_utility_dict, settlement_resources_dict, settlement_id_list)

def print_settlement_stats(elevation_dict, coastline_dict, river_dict, spring_dict, household_dict, population_dict,
                         uThres_household_avg_dict, uThres_settlement_total_dict, total_utility_dict):

    print("=== Elevation Stats ===")
    for sid, stats in elevation_dict.items():
        print(f"Settlement {sid}: avg={stats['avg_elev']}, max={stats['max_elev']}, min={stats['min_elev']}")

    print("\n=== Coastline Distance ===")
    for sid, dt_coast in coastline_dict.items():
        print(f"Settlement {sid}: dt_coastline={dt_coast}")

    print("\n=== River Patches ===")
    for sid, stats in river_dict.items():
        print(f"Settlement {sid}: river_patches={stats['river_patches']}")

    print("\n=== Spring Patches ===")
    for sid, stats in spring_dict.items():
        print(f"Settlement {sid}: spring_patches={stats['spring_patches']}")

    print("\n=== Household Counts ===")
    for sid, count in household_dict.items():
        print(f"Settlement {sid}: households={count}")

    print("\n=== Population Counts ===")
    for sid, pop in population_dict.items():
        print(f"Settlement {sid}: population={pop}")

    print("\n=== Household Average uThres ===")
    for sid, avg in uThres_household_avg_dict.items():
        print(f"Settlement {sid}: avg_uThres={avg}")

    print("\n=== Settlement Total uThres ===")
    for sid, total in uThres_settlement_total_dict.items():
        print(f"Settlement {sid}: total_uThres={total}")

    print("\n=== Settlement Total Utility ===")
    for sid, total in total_utility_dict.items():
        print(f"Settlement {sid}: total_utility={total}")

    print(f"\nThe max elevation amongst the settlements is: {settlement_max_elevation}")
    print(f"The max global elevation is: {global_max_elevation}")
    print("\n")

def log_settlement_stats(elevation_dict, coastline_dict, river_dict, spring_dict, household_dict, population_dict,
                         uThres_household_avg_dict, uThres_settlement_total_dict, total_utility_dict):
    
    # Elevation stats
    logging.info("=== Elevation Stats ===")
    for sid, stats in elevation_dict.items():
        logging.info(f"Settlement {sid}: avg={stats['avg_elev']}, max={stats['max_elev']}, min={stats['min_elev']}")

    # Coastline distance
    logging.info("=== Coastline Distance ===")
    for sid, dt_coast in coastline_dict.items():
        logging.info(f"Settlement {sid}: dt_coastline={dt_coast}")

    # River patches
    logging.info("=== River Patches ===")
    for sid, stats in river_dict.items():
        logging.info(f"Settlement {sid}: river_patches={stats['river_patches']}")

    # Spring patches
    logging.info("=== Spring Patches ===")
    for sid, stats in spring_dict.items():
        logging.info(f"Settlement {sid}: spring_patches={stats['spring_patches']}")

    # Household counts
    logging.info("=== Household Counts ===")
    for sid, count in household_dict.items():
        logging.info(f"Settlement {sid}: households={count}")

    # Population counts
    logging.info("=== Population Counts ===")
    for sid, pop in population_dict.items():
        logging.info(f"Settlement {sid}: population={pop}")

    # Household average uThres
    logging.info("=== Household Average uThres ===")
    for sid, avg in uThres_household_avg_dict.items():
        logging.info(f"Settlement {sid}: avg_uThres={avg}")

    # Settlement total uThres
    logging.info("=== Settlement Total uThres ===")
    for sid, total in uThres_settlement_total_dict.items():
        logging.info(f"Settlement {sid}: total_uThres={total}")

    # Settlement total utility
    logging.info("=== Settlement Total Utility ===")
    for sid, total in total_utility_dict.items():
        logging.info(f"Settlement {sid}: total_utility={total}")

    # Global stats
    logging.info(f"The max elevation amongst the settlements is: {settlement_max_elevation}")
    logging.info(f"The max global elevation is: {global_max_elevation}")

def distribute_resources(settlement_id, total_resource, elevation_dict, coastline_dict,
                         river_dict, spring_dict, household_dict, population_dict,
                         global_max_elevation, global_min_elevation,
                         max_coast_distance, is_settlement_stats_printing_enabled):

    # Get metrics from corresponding dictionaries
    elev = elevation_dict[settlement_id]
    avg_elev = elev['avg_elev']
    max_elev = elev['max_elev']
    dt_coast = coastline_dict[settlement_id]
    river_patches = river_dict[settlement_id]['river_patches']
    spring_patches = spring_dict[settlement_id]['spring_patches']
    households = household_dict[settlement_id]
    population = population_dict[settlement_id]

    food_portion = 0.7  # 70% of total resources go to food


    # ---------- Crops and Livestock ----------
    # Calculate the weights for crops and livestock based on settlement elevation
    # Higher elevation results in more livestock
    # Lower elevation results in more crops
    # First we take into account the global maximum elevation
    if global_max_elevation == 0:
        w_crops_global = 0.5
    else:
        w_crops_global = 1 - (avg_elev / global_max_elevation)

    # Then we also consider the maximum elevation encountered in the existing settlements (usually lower than the global)
    if settlement_max_elevation == 0:
        w_crops_local = 0.5
    else:
        w_crops_local = 1 - (avg_elev / settlement_max_elevation)

    # We blend those two factors (70% global, 30% local) so that the result depends of both the global and local max elevation
    blend = 0.3 # we use a low blend because in our target area the local maximum differs significantly from the global
    w_crops = blend * w_crops_global + (1 - blend) * w_crops_local
    w_livestock = 1 - w_crops  # Complement to get the livestock weight

    # Ensure nonzero minimum for each of these (currently set to 10%)
    w_crops = max(w_crops, MIN_FOOD_FRACTION)
    w_livestock = max(w_livestock, MIN_FOOD_FRACTION)
    

    # ---------- Fish ----------
    # Fish production depends on the distance to the sea
    # We set a max distance to the coastline (50). Only settlements within this distance use the sea for fishing
    if (dt_coast <= max_coast_distance):
        coast_factor = max(0.0, 1 - dt_coast / max_coast_distance)  # 0 to 1
    else:
        coast_factor = 0.0

    # calculate the total fish weight
    # w_fish = coast_factor
    w_fish = coast_factor

    # Normalize the food weights
    total_food_weight = w_crops + w_livestock + w_fish
    if total_food_weight > 0:
        w_crops /= total_food_weight
        w_livestock /= total_food_weight
        w_fish /= total_food_weight
    else:
        w_crops = w_livestock = 0.5
        w_fish = 0.0


    # ---------- All Food Resources ----------
    # Allocate the food resources based on the weights that we calculated (food resources take up 70% of the settlements total resources)
    crops = total_resource * food_portion * w_crops
    livestock = total_resource * food_portion * w_livestock
    fish = total_resource * food_portion * w_fish
    

    # ---------- Pottery ----------
    # We use 3 factors that influence the existence of pottery workshops
    # The first factor is the amount of households
    # The second factor is the population of the settlement
    # And the third factor is an occupancy factor for the households

    pottery = 0.0
    pottery_factor = 0.0
    occupancy_factor = 0.0
    population_factor = 0.0
    household_factor = 0.0
    max_people_per_household = 10
    max_pottery_percentage = 0.1 # Up to 10% of total is pottery
    if (river_patches > 0 or spring_patches > 0 or dt_coast < max_coast_distance):
        household_factor = households / (households + 1.0)
        population_factor = population / (population + 1.0)

        if households > 0:
            occupancy_factor = min(population / (households * max_people_per_household), 1.0)
        else:
            occupancy_factor = 0.0

        # The weights for our three factors
        w_households, w_population, w_occupancy = 0.4, 0.4, 0.2

        # Combined pottery factor
        pottery_factor = w_households * household_factor + w_population * population_factor + w_occupancy * occupancy_factor

        # Final pottery allocation
        pottery = total_resource * max_pottery_percentage * pottery_factor


    # ---------- Luxury ----------
    # Luxury resources depend on whether the settlement is near the sea (to trade with foreign traders) and is a low percentage of the total
    max_luxury_percentage = 0.05  # at most 5% of total resources
    luxury_factor = 0.0
    luxury = 0.0
    if (dt_coast < max_coast_distance):
        luxury_factor = coast_factor
        luxury = total_resource * max_luxury_percentage

    # ---------- Wood ----------
    # Allocate the remainder of the resources as wood
    wood = total_resource - (crops + livestock + fish + pottery + luxury)

    if(is_settlement_stats_printing_enabled):
        print(f"\nFactors:\nNot bounded:\n\tCrops: {w_crops}, \n\tLivestock: {w_livestock}, \n\tFish: {w_fish}")
        print(f"Bounded:\n\tCrops: {w_crops*food_portion}, \n\tLivestock: {w_livestock*food_portion}, \n\tLivestock: {w_livestock*food_portion}, \n\tPottery: {pottery_factor*max_pottery_percentage}\n\tLuxury: {luxury_factor*max_luxury_percentage}\n")
        print(f"Settlement {settlement_id} metrics:")
        print(f"\tAvg Elevation: {avg_elev:.2f}, Max Elevation: {max_elev:.2f}")
        print(f"\tDistance to Coast: {dt_coast:.2f}")
        print(f"\tRiver patches: {river_patches}, Spring patches: {spring_patches}")
        print(f"\tHouseholds: {households}, Population: {population}")
        print("Resource distribution:")
        print(f"\tCrops: {crops:.2f}")
        print(f"\tLivestock: {livestock:.2f}")
        print(f"\tFish: {fish:.2f}")
        print(f"\tPottery: {pottery:.2f}")
        print(f"\tWood: {wood:.2f}")
        print(f"\tLuxury: {luxury:.2f}\n")


    # Log the factors
    logging.info("Factors:")
    logging.info(f"Not bounded:\n\tCrops: {w_crops}, \n\tLivestock: {w_livestock}, \n\tFish: {w_fish}")
    logging.info(f"Bounded:\n\tCrops: {w_crops*food_portion}, "
                f"\n\tLivestock: {w_livestock*food_portion}, "
                f"\n\tLivestock: {w_livestock*food_portion}, "
                f"\n\tPottery: {pottery_factor*max_pottery_percentage}, "
                f"\n\tLuxury: {luxury_factor*max_luxury_percentage}")

    # Log settlement metrics
    logging.info(f"Settlement {settlement_id} metrics:")
    logging.info(f"\tAvg Elevation: {avg_elev:.2f}, Max Elevation: {max_elev:.2f}")
    logging.info(f"\tDistance to Coast: {dt_coast:.2f}")
    logging.info(f"\tRiver patches: {river_patches}, Spring patches: {spring_patches}")
    logging.info(f"\tHouseholds: {households}, Population: {population}")

    # Log resource distribution
    logging.info("Resource distribution:")
    logging.info(f"\tCrops: {crops:.2f}")
    logging.info(f"\tLivestock: {livestock:.2f}")
    logging.info(f"\tFish: {fish:.2f}")
    logging.info(f"\tPottery: {pottery:.2f}")
    logging.info(f"\tWood: {wood:.2f}")
    logging.info(f"\tLuxury: {luxury:.2f}")

    return {
        'crops': crops,
        'livestock': livestock,
        'fish': fish,
        'pottery': pottery,
        'wood': wood,
        'luxury':luxury
    }
    
def initialize_or_update_Policies(settlement_id_list, population_dict, uThres_settlement_total_dict, total_utility_dict, resource_dict):
    for settlement_id in settlement_id_list:
        # Initialize the settlement Policy
        if (settlement_id not in settlement_mdp_dict):
            settlement_mdp_dict[settlement_id] = SettlementTradePolicy(
                settlement_id, 
                population_dict[settlement_id], 
                uThres_settlement_total_dict[settlement_id], 
                total_utility_dict[settlement_id], 
                resource_dict[settlement_id]
            )
        else: # Update the settlement Policy state values
            settlement_mdp_dict[settlement_id].update_state(
                settlement_id, 
                population_dict[settlement_id], 
                uThres_settlement_total_dict[settlement_id], 
                total_utility_dict[settlement_id], 
                resource_dict[settlement_id]
            )

def update_all_settlement_MDPs(settlement_id_list, settlement_actions_dict):
    for settlement_id in settlement_id_list:
        settlement_mdp_dict[settlement_id].update_policy((settlement_actions_dict[settlement_id]["resource"], settlement_actions_dict[settlement_id]["goal_utility"]))
