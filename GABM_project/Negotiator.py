import transformers, json, logging
import GABM_project.Strings.strings as strings
import GABM_project.Strings.llm_negotiation_strings as negStrings
from GABM_project.Util.JsonEditor import JsonEditor

# Class for LLM-agent negotiators
class Negotiator:
    def __init__(self, tokenizer, model):
        self.tokenizer = tokenizer
        self.model = model
        self.pipeline = transformers.pipeline(
            "text-generation",
            model=model,
            tokenizer=tokenizer,  
            pad_token_id=tokenizer.eos_token_id,   
        )
        self.responses = []
        self.talk = []
        self.give = []
        self.giveJSON = []
        self.take = []
        self.takeJSON = []
        self.action = []
        self.jsonEditor = JsonEditor()
        return

    # Create a prompt
    def create_prompt(self, roles, content):
        prompt = []
        for i in range(len(roles)):
            prompt.append(
                {"role": roles[i], "content": content[i]}
            )
        return prompt
    
    # Pass a prompt to the LLM and get a response
    def generate_response(self, roles, content):
        text = self.tokenizer.apply_chat_template(
            self.create_prompt(roles, content),
            tokenize=False,
            add_generation_prompt=True
        )
        model_inputs = self.tokenizer([text], return_tensors="pt").to(self.model.device)

        generated_ids = self.model.generate(
            **model_inputs,
            max_new_tokens=512
        )
        generated_ids = [
            output_ids[len(input_ids):] for input_ids, output_ids in zip(model_inputs.input_ids, generated_ids)
        ]

        response = self.tokenizer.batch_decode(generated_ids, skip_special_tokens=True)[0]

        self.responses.append(response)
        return response
    
    def get_last_response_chunks(self):
        response = self.responses[-1] if self.responses else ""
        response_lines = [line.strip() for line in response.strip().split('\n') if line.strip()]

        # Initialize defaults
        talk = give = take = ""
        action = negStrings.ACTIONS["INVALID"]

        try:
            if len(response_lines) > 0 and response_lines[0].startswith("Talk:"):
                talk = response_lines[0].split("Talk:", 1)[1].strip()
            if len(response_lines) > 1 and response_lines[1].startswith("Give:"):
                give = response_lines[1].split("Give:", 1)[1].strip()
            if len(response_lines) > 2 and response_lines[2].startswith("Take:"):
                take = response_lines[2].split("Take:", 1)[1].strip()
            if len(response_lines) > 3 and response_lines[3].startswith("Action:"):
                action = response_lines[3].split("Action:", 1)[1].strip()
        except Exception as e:
            action = negStrings.ACTIONS["INVALID"]
            print("Exception:", e)
            logging.error("Exception:", e)

        self.action.append(action)
        self.talk.append(talk)

        self.give.append(give)
        stripped_give_JSON, isValidGive = self.jsonEditor.strip_json(give)  
        self.giveJSON.append(self.jsonEditor.json_filler(stripped_give_JSON))
        
        self.take.append(take)
        stripped_take_JSON, isValidTake = self.jsonEditor.strip_json(take)
        self.takeJSON.append(self.jsonEditor.json_filler(stripped_take_JSON))

        if (not isValidGive or not isValidTake):
            action = negStrings.ACTIONS["INVALID"]
        self.action.append(action)

        result = {
            "talk": self.talk[-1],
            "give": self.give[-1],
            "giveJSON": self.giveJSON[-1],
            "take": self.take[-1],
            "takeJSON": self.takeJSON[-1],
            "action": self.action[-1],
        }

        return result
