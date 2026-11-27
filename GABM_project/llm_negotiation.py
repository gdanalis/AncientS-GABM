import torch, gc, transformers, os, logging, json
from transformers import BitsAndBytesConfig
from GABM_project.Negotiator import Negotiator
from GABM_project.Util.JsonEditor import JsonEditor
import GABM_project.Strings.strings as strings
import GABM_project.Strings.paths as pathStrings
import GABM_project.Strings.llm_prompt_strings as promptStrings
import GABM_project.Strings.llm_negotiation_strings as negStrings
import GABM_project.Strings.llm_model_strings as modelStrings

NEGOTIATION_ROUNDS_NUM = 10
MAX_TOKENS = 256
IS_PRINTING_ENABLED = True
REFINEMENT_RANGE = 3
VALIDATOR_MODEL = modelStrings.MODEL_QWEN25_7B

validator_tokenizer, validator_model, validator_pipeline = None, None, None

def initialize_LLM(isQuantizationEnabled, modelName):
    if torch.cuda.is_available():
        torch.cuda.empty_cache()

    device = 0
    bnb_config = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_compute_dtype=torch.float16,
    )

    # Build max_memory dict dynamically based on available GPUs
    max_memory = {
        0: "48GiB",
        "cpu": "50GiB"
    }

    # Initialize the LLM
    tokenizer = transformers.AutoTokenizer.from_pretrained(
        modelName, 
        token=strings.API_TOKEN, 
        cache_dir=pathStrings.CACHE_DIR
    )
    
    if (isQuantizationEnabled):
        model = transformers.AutoModelForCausalLM.from_pretrained(
            modelName, 
            token=strings.API_TOKEN, 
            cache_dir=pathStrings.CACHE_DIR, 
            dtype=torch.float16,
            low_cpu_mem_usage=True,
            device_map={"": device},
            max_memory=max_memory,
            trust_remote_code=True,
            quantization_config=bnb_config,
        )
    else:
        model = transformers.AutoModelForCausalLM.from_pretrained(
            modelName, 
            token=strings.API_TOKEN, 
            cache_dir=pathStrings.CACHE_DIR, 
            dtype=torch.float16,
            low_cpu_mem_usage=True,
            device_map=None,
            max_memory=max_memory,
            trust_remote_code=True,
        )

    return tokenizer, model, 

def generate_response(negotiator, roles, context_message, isPrintingEnabled):
    generated_text = negotiator.generate_response(roles, context_message)

    if  (isPrintingEnabled):
        print(strings.PRINT_STRING_SIMPLE.format(no=0, generated_text_to_print=generated_text))
    logging.info(f"Original: {strings.PRINT_STRING_SIMPLE.format(no=0, generated_text_to_print=generated_text)}")

    response = negotiator.get_last_response_chunks()
    return response["talk"], response["give"], response["giveJSON"], response["take"], response["takeJSON"], response["action"]

def negotiate_simple(isPrintingEnabled, resources0, resources1, action0, action1, resources_gained0, resources_gained1, id0, id1, metrics, negotiator):
    goal_resource0, goal_amount0 = action0
    goal_resource1, goal_amount1 = action1
    negotiation_rounds_num = 1
    metrics.total_negotiation_rounds += 1
    negotiation_history = ""
    context_messages = []

    available_resources0 = promptStrings.AVAILABLE_RESOURCES.format(
        crops=int(resources0[strings.RESOURCES[0]]),
        livestock=int(resources0[strings.RESOURCES[1]]), 
        fish=int(resources0[strings.RESOURCES[2]]), 
        pottery=int(resources0[strings.RESOURCES[3]]),
        wood=int(resources0[strings.RESOURCES[4]]), 
        luxury=int(resources0[strings.RESOURCES[5]]),
    )

    available_resources1 = promptStrings.AVAILABLE_RESOURCES.format(
        crops=int(resources1[strings.RESOURCES[0]]), 
        livestock=int(resources1[strings.RESOURCES[1]]), 
        fish=int(resources1[strings.RESOURCES[2]]), 
        pottery=int(resources1[strings.RESOURCES[3]]), 
        wood=int(resources1[strings.RESOURCES[4]]), 
        luxury=int(resources1[strings.RESOURCES[5]]), 
    )

    context_messages.append(promptStrings.CONTEXT_MESSAGE.format(available_resources=available_resources0, resource=goal_resource0, amount=int(resources_gained0), amount2=int(goal_amount0)))
    context_messages.append(promptStrings.CONTEXT_MESSAGE.format(available_resources=available_resources1, resource=goal_resource1, amount=int(resources_gained1), amount2=int(goal_amount1)))

    generated_talk, generated_give, generated_give_JSON, generated_take, generated_take_JSON, generated_action = generate_response(
        negotiator, 
        [negStrings.ROLES[0]], 
        [f"{context_messages[0]}. \nYou are starting the negotiation."], 
        isPrintingEnabled
    )
    negotiation_history = promptStrings.NEGOTIATION_HISTORY.format(
        negotiation_history=negotiation_history, 
        negotiator_id=negStrings.NEGOTIATOR_TAGS[0], 
        generated_talk=generated_talk, 
        generated_give=generated_give, 
        generated_take=generated_take, 
        generated_action=generated_action      
    )

    if (generated_action == negStrings.ACTIONS["ACCEPT"] or generated_action == negStrings.ACTIONS["QUIT"]):
        return generated_action, generated_give_JSON, generated_take_JSON, negotiation_rounds_num, id0

    prompt = promptStrings.CONTEXT_PROMPT.format(context_message=context_messages[1], negotiator_id=negStrings.NEGOTIATOR_TAGS[1], negotiation_history=negotiation_history)
    generated_talk, generated_give, generated_give_JSON, generated_take, generated_take_JSON, generated_action = generate_response(
        negotiator, 
        [negStrings.ROLES[0]], 
        [prompt], 
        isPrintingEnabled
    )
    negotiation_history = promptStrings.NEGOTIATION_HISTORY.format(
        negotiation_history=negotiation_history, 
        negotiator_id=negStrings.NEGOTIATOR_TAGS[1], 
        generated_talk=generated_talk, 
        generated_give=generated_give, 
        generated_take=generated_take, 
        generated_action=generated_action      
    )

    if (generated_action == negStrings.ACTIONS["ACCEPT"] or generated_action == negStrings.ACTIONS["QUIT"]):
        return generated_action, generated_give_JSON, generated_take_JSON, negotiation_rounds_num, id1

    for i in range(NEGOTIATION_ROUNDS_NUM):
        metrics.total_negotiation_rounds += 1
        negotiation_rounds_num += 1
        prompt = promptStrings.CONTEXT_PROMPT.format(context_message=context_messages[0], negotiator_id=negStrings.NEGOTIATOR_TAGS[0], negotiation_history=negotiation_history)
        generated_talk, generated_give, generated_give_JSON, generated_take, generated_take_JSON, generated_action = generate_response(
            negotiator, 
            [negStrings.ROLES[0]], 
            [prompt], 
            isPrintingEnabled
        )
        negotiation_history = promptStrings.NEGOTIATION_HISTORY.format(
            negotiation_history=negotiation_history, 
            negotiator_id=negStrings.NEGOTIATOR_TAGS[0], 
            generated_talk=generated_talk, 
            generated_give=generated_give, 
            generated_take=generated_take, 
            generated_action=generated_action      
        )

        if (generated_action == negStrings.ACTIONS["ACCEPT"] or generated_action == negStrings.ACTIONS["QUIT"]):
            return generated_action, generated_give_JSON, generated_take_JSON, negotiation_rounds_num, id0
        
        prompt = promptStrings.CONTEXT_PROMPT.format(context_message=context_messages[1], negotiator_id=negStrings.NEGOTIATOR_TAGS[1], negotiation_history=negotiation_history)
        generated_talk, generated_give, generated_give_JSON, generated_take, generated_take_JSON, generated_action = generate_response(
            negotiator, 
            [negStrings.ROLES[0]], 
            [prompt], 
            isPrintingEnabled
        )
        negotiation_history = promptStrings.NEGOTIATION_HISTORY.format(
            negotiation_history=negotiation_history, 
            negotiator_id=negStrings.NEGOTIATOR_TAGS[1], 
            generated_talk=generated_talk, 
            generated_give=generated_give, 
            generated_take=generated_take, 
            generated_action=generated_action      
        )

        if (generated_action == negStrings.ACTIONS["ACCEPT"] or generated_action == negStrings.ACTIONS["QUIT"]):
            return generated_action, generated_give_JSON, generated_take_JSON, negotiation_rounds_num, id1

    generated_action = negStrings.ACTIONS["TIMEOUT"]
    return generated_action, generated_give_JSON, generated_take_JSON, negotiation_rounds_num, id1