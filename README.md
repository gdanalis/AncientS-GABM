# AncientS-GABM

AncientS-GABM is a Generative Agent-Based Model (GABM) for simulating trade among prehistoric settlements in the greater geographical area of Knossos, Crete during the prepalatial Minoan era (3100-1925 BCE, EM I - MM IA).

## Setup

1. Clone or download the repository.
2. Install the required Python packages:

   ```bash
   python -m pip install -r requirements.txt
   ```

3. Set the Hugging Face API token in `GABM_project/Strings/strings.py`:

   ```python
   API_TOKEN = "ADD_YOUR_API_TOKEN_HERE"
   ```

   Replace the placeholder with the token used to download and load the selected model.

4. Run the main script from the repository root:

   ```bash
   python -m GABM_project.main
   ```

The first run downloads NetLogo 6.4.0 automatically when `NetLogo-6.4.0-64` is not already present. The downloaded archive is extracted in the repository root.

## Usage

Run the simulation with the default settings:

```bash
python -m GABM_project.main
```

### Command-Line Options

| Option                   | Type    |                     Default | Description                                   |
| ------------------------ | ------- | --------------------------: | --------------------------------------------- |
| `--llm`                  | string  | `Qwen/Qwen2.5-32B-Instruct` | Hugging Face LLM model used by the LLM-agents |
| `--quant`                | boolean |                      `True` | Enables 4-bit model quantization              |
| `--print`                | boolean |                     `False` | Enables detailed output                       |
| `--printMinimal`         | boolean |                     `False` | Enables minimal output                        |
| `--printSettlementStats` | boolean |                     `False` | Prints settlement statistics                  |
| `--years`                | integer |                         `5` | Number of simulation years                    |
| `--interaction_model`    | string  |             `Gravity model` | Settlement spatial interaction model          |

Available interaction-model names are defined in `GABM_project/Strings/netlogo_strings.py`:

- `Off`
- `XTENT model`
- `Gravity model`
- `All`

## LLM Configuration

The default model is `Qwen/Qwen2.5-32B-Instruct`. The model is loaded through the Hugging Face Transformers library and cached under `LLM_CACHE/`.

The execution code expects CUDA GPU access and assigns the primary model to CUDA device 0 in `GABM_project/llm_negotiation.py`. This device assignment may need to be changed for systems with differently configured GPUs.

Model loading supports 4-bit quantization through a BitsAndBytes configuration. Quantization can be disabled with `--quant False`, subject to sufficient GPU and CPU memory.

## Outputs

The application creates:

- `Logs/` — timestamped simulation logs
- `Figures/` — timestamped trade, resource, and network visualizations

Generated logs and figures are named using the simulation start timestamp.

The metrics system reports trade interactions, accepted negotiations, quit and timeout outcomes, invalid responses, resources gained and given, settlement success rates, and model runtime.

### AncientS-ABM

- Work: AncientS-ABM: Agent-Based Modeling of Past Societies Social Organization
- Author: Angelos Chliaoutakis
- Version: 1.0.0
- Source: https://www.comses.net/codebases/50cf5d2a-0f37-4d4d-84e0-715e641180d9/releases/1.0.0/
- License: CC BY-NC 3.0
- Included files: Ancients_ABM/...
- Changes made: extended into an GABM with historically accurate resource types
