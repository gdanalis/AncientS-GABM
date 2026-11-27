AVAILABLE_RESOURCES = "Your available resources are: {crops} pieces of crops, {livestock} pieces of livestock, {fish} pieces of fish, {pottery} pieces of pottery, {wood} pieces of wood and {luxury} pieces of luxury goods."

CONTEXT_MESSAGE = ("""
You are the representative of a settlement negotiating with another settlement.
{available_resources}
Goal: Get as much pieces of {resource} as possible while reaching a deal.  
You have currently gathered {amount} pieces of {resource} through previous trades out of the {amount2} pieces that you have to gather this year.
If turns run out with no deal → no resources for either side.  

 Resources allowed: crops, livestock, fish, pottery, wood, luxury ONLY.  
You may only offer what you have (>0) and cannot exceed your supply.  

### FORMAT:
    Talk: [Brief, natural reply. Acknowledge last offer, then accept or counter. If countering, move toward agreement. ALWAYS mention the numerical amounts of resources you are proposing to trade (both Give and Take) and make it CLEAR who is receiving which amounts and resources.]
    Give: [JSON – only what you are offering to give to the other negotiator.]
    Take: [JSON – only what you want to take from the other negotiator.]
    Action: [ACCEPT | PROPOSE | QUIT]
                                
### Actions:
    ACCEPT: [Accept the deal that the other negotiator made.]
    PROPOSE: [Propose a new deal.]
    QUIT: [End the negotiation if you don't think you can reach a beneficial deal.]
                                
### Rules:
    - Always consider the negotiation history carefully before replying and view each entry from your perspective.
    - Never invent or mention other resources.
    - Do NOT repeat your own earlier offers or statements word-for-word.
    - Follow the exact format below every turn.
    - Always output valid JSON for Give and Take. Do NOT invent fields or swap keys incorrectly.
    - When ACCEPTING, flip the last (opponents) PROPOSE Give and Take to reflect your perspective:
        - Give = what the other side requested from you (their Take)
        - Take = what the other side offered to you (their Give)
        - So if their last PROPOSE was:
            Talk: I appreciate your counteroffer. To move closer to an agreement, how about we trade 500 crops for 125 pieces of fish?
            Give: {{\"crops\": \"500\"}}
            Take: {{\"fish\": \"125\"}}
            Action: PROPOSE
        - Then if you ACCEPT, your Give and Take must be:
            Talk: I agree with your proposal. Let's finalize this trade of 500 crops for 125 pieces of fish.
            Give: {{\"fish\": \"125\"}}
            Take: {{\"crops\": \"500\"}}
            Action: ACCEPT
        - When ACCEPTING, ALWAYS copy the numerical values exactly from the opponent’s last PROPOSE, just swap Give and Take.
    - When PROPOSING, your Give and Take must match what you say in Talk from your perspective:
        - Give = what you are offering to give to the other negotiator
        - Take = what you are requesting to take from the other negotiator
        - For example, if you say:
            Talk: I can give you 100 crops, and in return I want 30 livestock and 20 pottery.
            Give: {{\"crops\": \"100\"}}
            Take: {{\"livestock\": \"30\", \"pottery\": \"20\"}}
            Action: PROPOSE
### Notes:
    - Give ≠ Take.
    - Never mix up what you are offering (Give) and what you are requesting (Take).
    - No empty/null JSON.
    - When PROPOSE don't offer two deals in one turn. ALWAYS offer ONLY ONE proposal (can include multiple resources).
    - ACCEPT means no changes from the other’s last proposal.
    - Ensure that the resources offered in Talk as ‘I give / I offer / you take’ match Give JSON, and the resources described as ‘you give me / I take / you give us’ match Take JSON. Be very careful to get this right.
### Examples:

# 1. Simple PROPOSE
Talk: I can give 20 wood for 25 pottery.
Give: {{\"wood\": \"20\"}}
Take: {{\"pottery\": \"25\"}}
Action: PROPOSE

# 2. Simple ACCEPT
Previous PROPOSE: 
Talk: I can give 20 wood for 25 pottery.
Give: {{\"wood\": \"20\"}}
Take: {{\"pottery\": \"25\"}}
Action: PROPOSE

Talk: I accept your offer of 20 wood for 25 pottery.
Give: {{\"pottery\": \"25\"}}
Take: {{\"wood\": \"20\"}}
Action: ACCEPT

# 3. Counter-offer PROPOSE
Previous PROPOSE:    
Talk: I can give you 120 crops and 20 pottery for 40 livestock.
Give: {{\"crops\": \"120\", \"pottery\": \"20\"}}
Take: {{\"livestock\": \"40\"}}
Action: PROPOSE

Talk: That's closer to what I was looking for. Can we adjust it slightly to 100 crops and 25 pottery for 40 livestock?
Give: {{\"livestock\": \"40\"}}
Take: {{\"crops\": \"100\", \"pottery\": \"25\"}}
Action: PROPOSE

# 4. Complex Multi-resource PROPOSE
Talk: I can give you 100 crops, and in return I want 30 livestock and 20 pottery.
Give: {{\"crops\": \"100\"}}
Take: {{\"livestock\": \"30\", \"pottery\": \"20\"}}
Action: PROPOSE

# 5. PROPOSE with partial role flip
Talk: I’ll give you 60 crops if you give me 40 pottery.
Give: {{\"crops\": \"60\"}}
Take: {{\"pottery\": \"40\"}}
Action: PROPOSE

# 6. Multi-resource ACCEPT
Previous PROPOSE:  
Talk: I can give 200 crops and 50 fish for 80 livestock and 20 pottery.
Give: {{\"crops\": \"200\", \"fish\": \"50\"}}
Take: {{\"livestock\": \"80\", \"pottery\": \"20\"}}
Action: PROPOSE

Talk: I accept your offer of 200 crops and 50 fish for 80 livestock and 20 pottery.
Give: {{\"livestock\": \"80\", \"pottery\": \"20\"}}
Take: {{\"crops\": \"200\", \"fish\": \"50\"}}
Action: ACCEPT

# 7. QUIT
Talk: I don’t think we can reach an agreement, so I will stop negotiations here.
Give: {{\"crops\": \"10\"}}
Take: {{\"pottery\": \"5\"}}
Action: QUIT

# 8. PROPOSE introducing new resources
Talk: How about I give you 100 crops and 20 fish for 40 livestock?
Give: {{\"crops\": \"100\", \"fish\": \"20\"}}
Take: {{\"livestock\": \"40\"}}
Action: PROPOSE

# 9. PROPOSE to finalize a deal
Previous PROPOSE:
Talk: I appreciate your counteroffer. To move closer to an agreement, how about we trade 500 crops for 125 pieces of fish?
Give: {{\"crops\": \"500\"}}
Take: {{\"fish\": \"125\"}}
Action: PROPOSE

Talk: I agree with your proposal. Let's finalize this trade of 500 crops for 125 pieces of fish.
Give: {{\"fish\": \"125\"}}
Take: {{\"crops\": \"500\"}}
Action: ACCEPT
""")

OPPONENT_RESPONSE = (
    """Your opponent negotiator's last response was: {generated_talk}
    """
)

NEGOTIATION_HISTORY = (
    """{negotiation_history}
    Negotiator {negotiator_id}:
        Talk: {generated_talk}
        Give: {generated_give}
        Take: {generated_take}
        Action: {generated_action}
    """
)

CONTEXT_PROMPT = (
    """{context_message}
    You are Negotiator {negotiator_id} and the negotiation history so far is:
    {negotiation_history}
    """
)
