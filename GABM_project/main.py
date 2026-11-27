import torch, argparse, sys, transformers, logging, os
from datetime import datetime
import GABM_project.Strings.paths as pathStrings
import GABM_project.Strings.llm_model_strings as modelStrings
import GABM_project.llm_negotiation as neg
import GABM_project.netlogo as nl
import GABM_project.Util.Metrics as m
import GABM_project.Util.Downloader as dl
import GABM_project.Strings.netlogo_strings as nlStrings
import GABM_project.Strings.strings as strings
from GABM_project.Negotiator import Negotiator

def main():
    torch.cuda.reset_peak_memory_stats()
    torch.cuda.empty_cache()

    parser = argparse.ArgumentParser()
    parser.add_argument("--llm", type=str, default=modelStrings.MODEL_QWEN25_32B, help="The LLM model that the negotiator agents will use.")
    parser.add_argument("--quant", type=bool, default=True)
    parser.add_argument("--print", type=bool, default=False)
    parser.add_argument("--printMinimal", type=bool, default=False)
    parser.add_argument("--printSettlementStats", type=bool, default=False)
    parser.add_argument("--years", type=int, default=5)
    parser.add_argument("--interaction_model", type=str, default=nlStrings.settlement_interaction_options["GRAVITY"])
    
    args = parser.parse_args()
    llm_model = args.llm
    is_quantization_enabled = args.quant
    is_printing_enabled = args.print
    is_minimal_printing_enabled = args.printMinimal
    is_settlement_stats_printing_enabled = args.printSettlementStats
    max_years = args.years
    interaction_model = args.interaction_model

    date_time_start = datetime.now().strftime('%Y%m%d_%H%M%S')
    initializeLogs(date_time_start)
    logging.info(f"LLM Model: {llm_model}")
    logging.info(f"Quantization: {is_quantization_enabled}")
    logging.info(f"Running for {max_years} years.")
    logging.info(f"Interaction Model: {interaction_model}\n")
    logging.info(f"Seed: 347\n")

    # Download netlogo
    downloader = dl.Downloader()
    downloader.download_netlogo()

    # Initialize the LLM
    tokenizer, model = neg.initialize_LLM(is_quantization_enabled, llm_model)
    negotiator = Negotiator(tokenizer, model)

    # Initialize metrics
    metrics = m.Metrics(date_time_start)

    # Initialize the netlogo model
    netlogo = nl.initialize_netlogo(pathStrings.NETLOGO_HOME, pathStrings.NETLOGO_MODEL_PATH, interaction_model)
    
    # Run the netlogo model and the LLM negotiation
    nl.netlogo_loop(netlogo, is_printing_enabled, metrics, max_years, negotiator, is_minimal_printing_enabled, is_settlement_stats_printing_enabled)

    # Calculate the total runtime of the netlogo model and LLM negotiation
    metrics.calculate_netlogo_runtime()
    metrics.calculate_all_settlements_total_gain()
    metrics.calculate_settlement_success_rate()
    metrics.print_negotiation_metrics()
    metrics.show_all_plots()
    sys.exit(0)

if __name__ == "__main__":
    main()
    sys.exit(0)

def initializeLogs(date_time_start):
    path = os.path.dirname(os.path.abspath(__file__))
    for _ in range(1):
        path = os.path.dirname(path)

    logs_root = os.path.join(path, "Logs")
    os.makedirs(logs_root, exist_ok=True)

    log_filename = os.path.join(logs_root, f"simulation_{date_time_start}.log")
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[logging.FileHandler(log_filename, mode='a')]
    )