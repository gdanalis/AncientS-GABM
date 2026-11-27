import os

current_dir = os.path.dirname(os.path.abspath(__file__))

path = current_dir
for _ in range(2):
    path = os.path.dirname(path)

NETLOGO_HOME = os.path.join(path, "NetLogo-6.4.0-64") 
NETLOGO_MODEL_PATH = os.path.join(path, "Ancients_ABM/ancients-abm-agent-based-modeling-of-past-societies-social-organization_v1.0.0/code/AncientS-ABM.nlogo") 
CACHE_DIR = os.path.join(path, "LLM_CACHE")