import json
import logging
import GABM_project.Strings.strings as strings

class JsonEditor:
    pass

    def strip_json(self, text):
        text = text.strip()
        isValid = True

        # Try parsing json directly
        try:
            return json.loads(text), isValid
        except json.JSONDecodeError:
            pass

        # Try removing outer braces repeatedly
        while text.startswith("{") and text.endswith("}"):
            text = text[1:-1].strip()
            try:
                return json.loads(text), isValid
            except json.JSONDecodeError:
                continue

        logging.error("No valid JSON found.")
        return "{}", not isValid
    
    def json_filler(self, json):
        expected_keys = strings.RESOURCES
        full_json = {}

        if not isinstance(json, dict):
            for key in expected_keys:
                full_json[key] = 0
            return full_json
    
        for key in expected_keys:
            try:
                val = json.get(key, 0)
                full_json[key] = float(val)
            except (ValueError, TypeError):
                full_json[key] = 0
        return full_json