extensions [ gis profiler palette nw]

;; Model related entities and relationships
breed [ settlements settlement ]
breed [ households household ]

;; Known archaeological habitation sites
breed [ sites site ]

directed-link-breed [ peers peer ]
directed-link-breed [ acquaintances acquaintance]
directed-link-breed [ subordinates subordinate ]
directed-link-breed [ superiors superior ]

;; Spatial interaction (trade relations) between settlements
directed-link-breed [ interactions interaction ]

;; MDP states and transition actions for optimal migration policy
breed [ states state ]
directed-link-breed [ actions action ]

states-own [ V*s class hop stages] ; state value, previous state value, class of state (the number of "hop", representing migration radius in km), and stages-to-go storage list of V* for the MDP
actions-own [ R Pr] ; reward and probability of an action from state s transition to s' (end1 to end2)


settlements-own [
  households-list ; households list within the settlement
  households-cnt; number of households within the settlement
  population-size ; number of inhabitants within the settlement
  candidate-area ; maximum number of cells near the settlement that household agents may cultivate
  dt-coastline-settlement; distance of settlement to coastline (if available, calculated from the main settlement cell)
  ws ; attributes W of settlement location representing the weight of its "importance" for other settlements
  tradable-resources ; total resources available for trade
  payoff ; total resources received through the exchange with other settlements during trade, and to be distributed among the households
  years-exist ; number of (annual) time-steps that the settlement exists in the environment
  in-dgr-nrm ; in-degree centrality of the settlement node over the trading network, expressed as a percentage/ratio
  out-dgr-nrm ; out-degree centrality of the settlement node over the trading network, expressed as a percentage/ratio
  btw-nrm ; betweenness centrality of the settlement node over the trading network, expressed as a percentage/ratio
  cluster-coef ; clustering coefficient of the settlement node over the trading network, defined as the number of links between the node’s neighbors divided by the total number of possible links between its neighbors
]

households-own [
  settlementId; the settlement identification number that agent belongs to
  individuals; current number of inhabitants in the household
  utility ; maximum utility value for the household agent based on its utility function
  uThres    ; minimum resource need for the agent (depends on # of individuals)
  storage ; storage of resources. list with food amounts of the last years
  cultivating-patches ; list of cultivating patches
  migrate ; agent considering migrating to another location (true/false)
  sensory-range ; number of cells that an agent may sense resources (know about)
  years-to-migrate ; years that the agent has to stay within a settlement whenever it decides to migrate (minimum is equal to years of storage)
  years-settled ; years that the agent exists within a settlement
  years-exist ; years that the agent exists in the environment
  years-in-lack ; years that the agent has poor performance

  previous-location ; patch of previous location needed for migration
  migration-patches ; list of candidate migration locations (sequence) suggested by the MDP (optimal policy)

  ;; Self-organization needed fields
  is-peer ; flag denoting if agent is peer to others (true/false)
  is-subordinate ; flag denoting if agent is subordinate to others (true/false)
  is-superior ; flag denoting if agent is superior to others (true/false)

  strategy; strategy of the agent (0:C, 1:D, 2:TFT)
  reward ; current total payoff for the agent
  fitnessL ; accumulated fitness (list) of the agent, for period "time-rate"
]

sites-own [
  name ; settlement name
  chronology ; site chronological period
  category ; site category (villa, House/Houses, Settlement/Village/Site, City, Palace)
  timeStart ; year (tick) that the site start existing in the modeling area
  timeEnd ; year (tick) that the site stop existing in the modeling area
]

links-own [
  ;; applies to all breeds
  time-steps ; the total number of time-steps that this relation exists in the modeling environment
  time-steps-in-lack ; number of time-steps out of the total time that this relation exists that the source agent (end1) had storage level = 0 and U < uThres
  time-steps-on-load ; number of time-steps out of the total time that this relation exists that the source agent (end1) had assigned tasks load (helped)
  assigned-tasks ; total number of tasks that have been assigned by the source agent (end1) to the destination agent (end2) for the current year
  assigned-tasks-total; total number of tasks that have been assigned by the source agent (end1) to the destination agent (end2) in its existence
  load ; total resource amount from tasks that have been executed (given to others) by the destination agent (end2) for the current year
  load-total ; total resource amount from tasks that have been executed (given to others) by the destination agent (end2) in its existence
  behavior ; the strategic behavior of the agent (0: cooperate, 1: defect)
  attractiveness ; the corresponding "attractiveness" between the two ends (settlements) in [0, 1]
]

patches-own [
  elevation ; elevation value of the respective patch
  slope ; slope value of the respective patch
  land-productivity ; land-productivity for the patch (amount of resources), based on population
  land-suitability ; land suitability for the patch [0-1], based on slope
  aquifer-utility ; utility of an aquifier for the respective patch
  agricultural-production ; agricultural production (agent reward) of the cell, based on land suitability and productivity
  avg-agricultural-production ; average agricultural production of Moore neighbor cells (expected utility for an agent)
  resources ; initial resources of the cell based on a sample of the user-defined probability distribution and agricultural practice
  has-river ; binary value for patch denoting the existance of a river source (true/false)
  rvalue ; river location value to assist in grid aquifer density probability calculation
  has-spring ; binary value for patch denoting the existance of a spring source (true/false)
  svalue ; spring location value to assist in grid aquifer density calculation
  has-site ; binary value for patch denoting the existance of a known archaeological site (true/false)
  site-category ; known archaeological settlement type (if available)
  site-importance ; known archaeological site importance bsaed on category [0-1] (if available)
  site-id ; id of existing site, assisting in the various processes in the model
  has-sea ; binary value for patch denoting the existance of sea (true/false)
  is-coastline ; binary value for patch denoting if the cell belongs to the coastline (true/false)
  is-va-affected ; binary value for patch denoting if the patch is affected by volcanic ash of the eruption (true/false)
  is-ts-affected ; binary value for patch denoting if the patch is affected by tsunami waves of the eruption (true/false)
  ve-impact ; volcanic eruption impact to patch resources [0-1]
  dt-coastline; distance of cell to coastline (if available)
  init-resources ; initial resources of the cell, assisting in the various processes in the model
  has-settlement ; binary value for patch denoting the existance of a settlement (true/false)
  is-cultivated ; binary value for patch denoting if the patch is cultivated (true/false)
  is-checked ; beinary value denoting if patch is checked, assisting in the various processes in the model (true/false)
  elevation-state ; value representing elevation zones (1-5 classes)
]

globals [
  coordsys? ; boolean variable for checking if default coordinate system (WGS84) for all spatial data is set
  rivers-dataset ; rivers raster dataset
  springs-dataset ; springs shapefile dataset
  sites-dataset ; known archaeological sites locations shapefile dataset
  elevation-raster ; elevation raster dataset
  slope-raster ; slope raster dataset
  aquifer-raster ; raster dataset with value of percentage of aquifer locations as a density map,
  display-elevation? ; boolean variable for displaying elevation
  display-slope? ; boolean variable for displaying slope
  display-aquifer?  ; boolean variable for displaying aquifer location probability
  display-rivers? ; boolean variable for displaying rivers
  display-springs? ; boolean variable for displaying springs
  display-sites? ; boolean variable for displaying known archaeological habitation sites
  display-resources? ; boolean variable for displaying environmental resources
  land-patches ; patches in the modeling area covered only by land
  migrations ; total number of migrations of agents per (annual) time step
  display-territories? ; boolean variable for displaying settlement territories
  display-indg-nw? ; boolean variable for displaying in-degree centrality of settlements trading network
  display-outdg-nw? ; boolean variable for displaying out-degree centrality of settlements trading network
  display-btw-nw? ; boolean variable for displaying betweenness centrality of settlements trading network
  display-lv-con? ; boolean variable for displaying Louvain communities (clustering) of settlements trading network

  brn ; behaviorspace run number
  cell-size ; the size of a grid cell in Km

  ;; Interface variables
  mnoipc ; maximum number of inhabitants/cell
  sr ; integer value denoting cultivation system, that is extensive or intensive agriculture
  ris ; boolean variable for enabling random initial settlements
  rc? ; boolean variable for enabling resettling cost, representing the decay of migrating probability with increasing distance

  mdp ; decision-making on migration, applying a Markov Decision Process (MDP) or not
  nos ; initial number of settlements
  mnoiph ; maximum number of inhabitants/household
  mr ; integer value of migration radius of agents (in klm)
  yos ; integer value of years of storage allowed for a household agent
  ap? ; boolean variable enabling aquifer proximity for migration (true/false)
  mu ; minimum resources (utility) needed for an individual (household inhabitant, units in kg)
  dm ; value for decision making of an agent denoting social organiation paradigm in use (intependent, sharing, self-organization, etc., ranging from 1-5)
  rdL ; relative difference ratio (L) for re-organzation relationship evaluation

  nomdps ; munber of MDPs run at the current time-step
  nosts ; number of MDP states at the current time-step

  egt ; strategic decision-making, applying EGT selection dynamics for 3 strategic behaviors: cooperative, defective, playing tit-for-tat
  sd ; selection dynamics for strategy replication; none, imitation or probabilistic imitation within a settlement or the whole society
  tr ; time rate element for replication at which agents in the population review their strategy choice
  srv ; strategy review based on average reward of the same, all, or other strategies

  ve ; boolean variable enabling volcanic eruption sub-model
  veyr ; time step (year) of the volcanic eruption
  slr ; sea-level rise in meters
  inund ; water inundation inland in meters
  tyrs ; number of years (time steps) that tsunami renders agricultural fields useless
  vayrs; number of years (time steps) that volcanic ash renders agricultural fields with limited growth
  fprb; likelihood of human fatalities representing the human impact of the natural disaster

  sint ; variable enabling settlement interaction (trade) based on spatial interaction models (XTENT, Gravity)
  simp ; settlement importance during trade is enabled as the one modeled based on settlement population and exisatnce or the based on archaeological evidence
  hst ; household agent percentage of stored surplus to be pooled as corresponding settlement trading resources

  beta ; beta parameter of the XTENT model
  m ; m parameter of XTENT model
  lamda ; lamda parameter of Gravity model

  in-dgr-avg ; average of in-degree centrality (prominence) of the settlement trading network (normalized), expressed as percentage/ratio based on the number of actors (settlements) in the trading network (n-1)
  in-dgr-std ; standard deviaton of the mean in-degree centrality of the settlement trading network (normalized), expressed as percentages of the number of actors (settlements) in the trading network
  in-dgr-cfv ; coefficient of variation (standard deviation devided by the mean) for in-degree centrality of the settlement trading network (std / mean)

  out-dgr-avg ; average of out-degree centrality (influence) of the settlement trading network (normalized), expressed as percentages of the number of actors (settlements) in the trading network (n-1)
  out-dgr-std ; standard deviaton of the mean out-degree centrality of the settlement trading network (normalized), expressed as percentages of the number of actors (settlements) in the trading network
  out-dgr-cfv ; coefficient of variation (standard deviation devided by the mean) for out-degree centrality of the settlement trading network (std / mean)

  btw-avg ; average of betweenness centrality (potential of control, intermediary) of the settlement trading network (normalized), expressed as percentage/ratio based on the number of actors (settlements) in the trading network (n-2)(n-1)
  btw-std ; standard deviaton of the mean betweenness centrality of the settlement trading network (normalized), expressed as percentage/ratio based on the number of actors (settlements) in the trading network
  btw-cfv ; coefficient of variation (standard deviation devided by the mean) for betweenness centrality of the settlement trading network (std / mean)

  in-dgr-index ; relative/general in-degree centrality of the overall settlement trading network (graph)
  out-dgr-index ; relative/general out-degree centrality of the settlement trading network (graph)
  btw-index ; relative/general out-degree centrality of the settlement trading network (graph)

  avg-cluster-cfv ; average clustering coefficient for measuring the amount of clustering in the trading network across settlement nodes
  louvain-con ; number of communities (structure) currently present in the trading network found by maximizing modularity using the Louvain method

  ;; Output variables
  settlement-pattern ; vector dataset of settlement patterns
  cultivation-pattern ; raster dataset of cultivation patterns

  ;; Self-Organization
  superiorAgentsAll ; number of superior agents / settlement of the current year (time step)
  subordinateAgentsAll ; number of subordinate agents / settlement of the current year (time step)
  peerAgentsAll ; number of peer agents / settlement of the current year (time step)

  superiorAgents ; number of unique superior agents / settlement of the current year (time step)
  subordinateAgents ; number of unique subordinate agents / settlement of the current year (time step)
  peerAgents ; number of unique peer agents / settlement of the current year (time step)

  agents ; number of agents / settlement

  relationChangesFromAcqToAuth; number of relation changed from Acquaintance to Authority relation for the current year (time step)
  relationChangesFromPeerToAuth; number of relation changed from Peer to Authority relation for the current year (time step)
  relationChangesFromAcqToPeer; number of relation changed from Acquaintance to Peer relation for the current year (time step)
  relationChangesFromAuthToPeer; number of relation changed from Authority to Peer relation for the current year (time step)
  relationChangesFromAuthToAcq; number of relation changed from Authority to Acquaintance relation for the current year (time step)
  relationChangesFromPeerToAcq; number of relation changed from Peer to Acquaintance relation for the current year (time step)

  superiorAgentsUtil ; utility of unique superior agents / settlement of the current year (time step)
  subordinateAgentsUtil; utility of unique subordinate agents / settlement of the current year (time step)
  peerAgentsUtil; utility of unique peer agents / settlement of the current year (time step)

  superiorAgentsAllUtil ; utility of superior agents / settlement of the current year (time step)
  subordinateAgentsAllUtil; utility of subordinate agents / settlement of the current year (time step)
  peerAgentsAllUtil; utility of peer agents / settlement of the current year (time step)

  superiorAgentsUtilIndiv; utility of unique superior agent individuals / settlement of the current year (time step)
  subordinateAgentsUtilIndiv; utility of unique subordinate agent individuals / settlement of the current year (time step)
  peerAgentsUtilIndiv; utility of unique peer agent individuals / settlement of the current year (time step)

  superiorAgentsAllUtilIndiv; utility of superior agent individuals / settlement of the current year (time step)
  subordinateAgentsAllUtilIndiv; utility of subordinate agent individuals / settlement of the current year (time step)
  peerAgentsAllUtilIndiv; utility of peer agent individuals / settlement of the current year (time step)

  agentsUtil; utility of agents / settlement of the current year (time step)
  agentsUtilIndiv; utility of agents individuals / settlement of the current year (time step)

  superiorAgentsStrg ; storage of unique superior agents / settlement of the current year (time step)
  subordinateAgentsStrg ; storage of unique subordinate agents / settlement of the current year (time step)
  peerAgentsStrg ; storage of unique peer agents / settlement of the current year (time step)

  superiorAgentsAllStrg ; storage of superior agents / settlement of the current year (time step)
  subordinateAgentsAllStrg ; storage of subordinate agents / settlement of the current year (time step)
  peerAgentsAllStrg ; storage of peer agents / settlement of the current year (time step)

  agentsStrg ; storage of agents / settlement of the current year (time step)

  superiorAgentsLoad ; load of unique superior agents / settlement of the current year (time step)
  subordinateAgentsLoad ; load of unique subordinate agents / settlement of the current year (time step)
  peerAgentsLoad ; load of unique peer agents / settlement of the current year (time step)

  superiorAgentsAllLoad ; load of superior agents / settlement of the current year (time step)
  subordinateAgentsAllLoad ; load of subordinate agents / settlement of the current year (time step)
  peerAgentsAllLoad ; load of peer agents / settlement of the current year (time step)

  superiorAgentsTotalLoad ; total load of unique superior agents / settlement
  subordinateAgentsTotalLoad ; total load of unique subordinate agents / settlement
  peerAgentsTotalLoad ; total load of unique peer agents / settlement

  superiorAgentsAllTotalLoad ; total load of superior agents / settlement
  subordinateAgentsAllTotalLoad ; total load of subordinate agents / settlement
  peerAgentsAllTotalLoad ; total load of peer agents / settlement

  agentsLoad ; load of agents / settlement
  agentsTotalLoad ; total (accumulated) load of agents / settlement


  superiorAgentsTasks ; tasks of unique superior agents / settlement of the current year (time step)
  subordinateAgentsTasks ; tasks of unique subordinate agents / settlement of the current year (time step)
  peerAgentsTasks ; tasks of unique peer agents / settlement of the current year (time step)

  superiorAgentsAllTasks ; tasks of superior agents / settlement of the current year (time step)
  subordinateAgentsAllTasks ; tasks of subordinate agents / settlement of the current year (time step)
  peerAgentsAllTasks ; tasks of peer agents / settlement of the current year (time step)

  agntLd ; average load of agents for the current year (time step)
  agntStrg ; average storage of agents for the current year (time step)
  mgrtns; total migrations (asssting parameter)
  relChanges; list with number of relation changes per type

  cagents ; total number of agents currently employing a cooperative strategy
  dagents ; total number of agents currently employing a defective strategy
  tftagents ; total number of agents currently employing a tit-fot-tat strategy
  cbehavior ; percentage of current cooperative behaviour
  dbehavior ; percentage of current defective behaviour
]


to setup
;  profiler:start
  ;; Clear all
  ca

  ;; Start timer
  reset-timer
  print (word "Initializing the ABM... ") ;(" behaviorspace-run-number ")...")
  set brn behaviorspace-run-number
  set cell-size 0.1 ; in Km, ( 100x100m cell size in this model)

  ;; Define random seed
  random-seed 347 + brn ; Set seed in order to reproduce pseudo random numbers for the different scenarios

  ;; Define the environment area: the wider area of Knossos area (default) or Malia
  let area "/"
  ;let area "/malia"


  ;; Load all of our datasets
  print "Importing files..."
  if coordsys? = false [ set-coordinate-system ]
  set elevation-raster gis:load-dataset (word "data" area "/DEM.asc")	
  set rivers-dataset gis:load-dataset (word "data" area "/Rivers.shp")
  set springs-dataset gis:load-dataset (word "data" area "/Springs.shp")
  set sites-dataset gis:load-dataset (word "data" area "/Sites.shp")

  gis:set-world-envelope (gis:envelope-union-of
    (gis:envelope-of elevation-raster)
;    (gis:envelope-of slope-raster)
    (gis:envelope-of rivers-dataset)
    (gis:envelope-of springs-dataset)
    (gis:envelope-of sites-dataset))

  resize-world 0 (gis:width-of elevation-raster - 1) 0 (gis:height-of elevation-raster - 1)
  ;; The maximum height (in pixels) of the environmental area on the GUI is 530, thus
  set-patch-size 530 / (gis:height-of elevation-raster)

  print "Setting model parameters..."
  ask patches [
    set has-settlement false
    set is-cultivated false
    set is-checked false
    set has-river false
    set has-spring false
    set is-va-affected false
    set is-ts-affected false
    set is-coastline false
    set dt-coastline 0
    set rvalue 0
    set svalue 0
    set site-id -1
    set site-importance -1
    set site-category ""
  ]

  ;; Set environmnetal and archaeological information as attributes of patches
  ask patches [ set elevation gis:raster-value elevation-raster pxcor (max-pycor - pycor) ]
  calculate-slope-aspect
  ask patches [ set slope gis:raster-value slope-raster pxcor (max-pycor - pycor) ]
  ask patches gis:intersecting rivers-dataset [ set has-river true set rvalue 1 ]
  ask patches gis:intersecting springs-dataset [ set has-spring true set svalue 1 ]
  set display-springs? false
  set display-rivers? false
  set display-sites? false

  ;; Set the has-sea attribute of patches
  ask patches [ let el gis:raster-sample elevation-raster self
;    ifelse ((el <= 0) or (el >= 0))
    ifelse (el > 0)
    [ set has-sea false ]
    [ set has-sea true ]
  ]
  set land-patches patches with [has-sea = false]
  ask land-patches [
    if (count neighbors with [has-sea] > 0)[
      set rvalue 1
      set is-coastline true
    ]
  ]

  set-land-productivity
  set-land-suitability

  calculate-aquifer-utility
  set-aquifer-utility

  show-elevation

  set migrations 0
  set mgrtns 0
  set relChanges []

  ;; Natural catastrophe (Volcanic eruption) parameters for the specific case study area (Minoan civilization)
  set veyr 1472 ; year of the volcanic eruption, 1628 BCE (since 3100 - 1628 = 1472 years)
  set slr Sea-level-rise ; sea-level rise in meters
  set inund Water-inundation-inland ; water inundation inland in meters
  set tyrs 20 ; number of years that tsunami renders agricultural fields useless
  set vayrs 10 ; number of years that volcanic ash renders agricultural fields with limited growth

  set beta 1.5
  set m .005
  set lamda .2

  ;; Setting interface variables
  set mnoipc Max-number-of-inhabitants/cell
  ifelse Subsistence-regime = "Extensive agriculture"
  [ set sr 1000 ] ; maximum amount of resources is 1000 kg/ha
  [ set sr 1500 ] ; maximum amount of resources is 1500 kg/ha (Intensive agriculture)

  set nos Number-of-initial-settlements
  set mnoiph Max-number-of-inhabitants/household
  set mr Household-migration-radius
  set yos Years-of-storage
  set ap? Aquifer-proximity-on-migration
  set mu Min-resources-person
  set ris Random-initial-settlements
  set rc? Resettling-cost
  set mdp MDP-decision-making

  set egt Evolutionary-selection-dynamics
  set sd Replicator-dynamics
  set tr Time-rate
  set srv Strategy-review

  set ve Volcanic-Eruption
  set fprb VE-mortality

  set sint Settlement-interaction
  set simp Settlement-importance
  set hst Household-surplus-pooled-for-trading / 100

  if Social-behavior = "Independent" [ set dm 1 ]
  if Social-behavior = "Egalitarian" [ set dm 2 ]
  if Social-behavior = "Sharing" [ set dm 3 ]
  if Social-behavior = "Self-Organized (SO)" [ set dm 4 ]
  if Social-behavior = "Hierarchical (static)" [ set dm 5 ]

  set rdL SO-authority-relation-relative-difference / 100

  if sint != "Off" [
    nw:set-context settlements interactions
    set display-territories? false
    set display-indg-nw? false
    set display-outdg-nw? false
    set display-btw-nw? false
    set display-lv-con? false
  ]

  print "Initializing agents..."

  ;; Setup settlements/households
  initialize-settlements-households

;  if (dm = "Self-Organization")[
  if (dm > 3)[
    ;; Setup relationships for self-organization
    initialize-relationships
  ]

  let melp max [elevation] of land-patches

  ;; Initialize the environental resources
  ;; Calculate the agricultural production of cells (Eq. 1) for the whole land modeling area (as with no population)
  ask land-patches [
    set resources int (land-suitability * sr * land-productivity)
    ;; considering 3 elevation states (low, midllde, high) for MDP
    set elevation-state ((precision ((elevation / melp) * 0.3) 1 ) * 10 )]

;  let nh count households
;  print (word "Number of households in modeling area is " nh  )

  if ve = true [ set-natural-disaster ]

  ; Calculate the distance of each settlement from the nearest coastline patch
  setup-settlement-coast-distances

  reset-ticks
  print "Setup completed."

;  profiler:stop
;  print profiler:report  ;; view the results
;  profiler:reset         ;; clear the data

;  if (dm = "Self-Organization")[
;    ;; Create and open files to store social network data
;    let aqf "off"
;    if ap? [ set aqf "on" ]
;    file-open (word "output/" dm "/" brn "/" sr "_" aqf "_social-networks-vertices.txt")
;    file-type (word "TimeStep HouseholdId SettlementId Individuals X Y Utility Storage Load TotalLoad YearSettled Superiors Subordinates Peers Aquaintances\n")
;
;    file-open (word "output/" dm "/" brn "/" sr "_" aqf "_social-networks-lines.txt")
;    file-type (word "TimeStep RelationType V1 V2 TimeStepsExist TimeStepsInLack TimeStepsOnLoad Load TotalLoad AssignedTasks TotalAssignedTasks\n")
;  ]
end

;-------------------------------------------------------- SETUP ---------------------------------------------------------------------
to setup-settlement-coast-distances
  ask settlements [
    let main_patch patch-here
    let coastal_patches patches with [is-coastline]

    ; Calculate the distance of each settlement from the coastline
    if any? coastal_patches [
      let distances [distance main_patch] of coastal_patches
      set dt-coastline-settlement min distances
    ] 

    ; if no coastal patches exist, assign huge distance
    if not any? coastal_patches [
      set dt-coastline-settlement max-pxcor * 2
    ]
  ]
end
;-------------------------------------------------------- SETUP ---------------------------------------------------------------------


to go
;  profiler:start
  let aqf "off"

;  ask settlements [
;    print (word population-size " - " sum [individuals] of households-list)
;    print (word households-cnt " - " count households-list)
;  ]

  if ap? [ set aqf "on" ]
  ;; Print current year
  print ""
  print (word "--- Year " (3100 - ticks) " BC")

  ;; Set known archaeological settlement sites locations and types
  get-current-sites ticks

  if (ticks > 0) [
    set nomdps 0 ; munber of mdps run at every time-step
    set nosts 0  ; number of states at every time-step

    ;; Migration process
    consider-migration
  ]

  ;; Environmental updates
  update-environment

  ;; Cultivate, harvest and calculate agents utility
  cultivate-harvest

  ;; If household agents evolute independently (dm = 1) do nothing
  ;; When dm = 2 or dm = 3 then egalitarian-like sharing of resources
  if (dm = 2 or dm = 3)[
    ; Equally distribute resources among household agents within settlement
    share-resources
  ]

  if (dm > 3) [ ;; Self-Organization
    ; Decision making / Adaptation / Re-organization

    ; Set relation changes
    set relationChangesFromAcqToAuth 0
    set relationChangesFromPeerToAuth 0
    set relationChangesFromAcqToPeer 0
    set relationChangesFromAuthToPeer 0
    set relationChangesFromAuthToAcq 0
    set relationChangesFromPeerToAcq 0

    ;; Watchdog variables
    set superiorAgentsLoad 0
    set subordinateAgentsLoad 0
    set peerAgentsLoad 0

    set superiorAgentsAllLoad 0
    set subordinateAgentsAllLoad 0
    set peerAgentsAllLoad 0

    set superiorAgentsTotalLoad 0
    set subordinateAgentsTotalLoad 0
    set peerAgentsTotalLoad 0

    set superiorAgentsAllTotalLoad 0
    set subordinateAgentsAllTotalLoad 0
    set peerAgentsAllTotalLoad 0

    set agentsLoad 0
    set agentsTotalLoad 0

    set superiorAgentsTasks 0
    set subordinateAgentsTasks 0
    set peerAgentsTasks 0

    set superiorAgentsAllTasks 0
    set subordinateAgentsAllTasks 0
    set peerAgentsAllTasks 0

    set superiorAgents 0
    set subordinateAgents 0
    set peerAgents 0

    set superiorAgentsUtil 0
    set subordinateAgentsUtil 0
    set peerAgentsUtil 0

    set superiorAgentsUtilIndiv 0
    set subordinateAgentsUtilIndiv 0
    set peerAgentsUtilIndiv 0

    set superiorAgentsAll 0
    set subordinateAgentsAll 0
    set peerAgentsAll 0

    set superiorAgentsAllUtil 0
    set subordinateAgentsAllUtil 0
    set peerAgentsAllUtil 0

    set superiorAgentsAllUtilIndiv 0
    set subordinateAgentsAllUtilIndiv 0
    set peerAgentsAllUtilIndiv 0

    set superiorAgentsStrg 0
    set subordinateAgentsStrg 0
    set peerAgentsStrg 0

    set superiorAgentsAllStrg 0
    set subordinateAgentsAllStrg 0
    set peerAgentsAllStrg 0

    ;; Agents interaction
    ;; Targeted resource distribution based on agent relations
    ifelse egt
    [ self-organization-strategic ] ; evolutionary game-theoretic approach (distribution game)
    [ self-organization ]           ; structural adaptation decision-making

    ;; Logging information, tasks, loads, for agents with unique relation types
    let loadList []
    let tloadList []
    let tskList []

    let supags households with [is-superior = true and is-subordinate = false and is-peer = false and [households-cnt] of settlement settlementId > 1 ]
    let subags households with [is-superior = false and is-subordinate = true and is-peer = false and [households-cnt] of settlement settlementId > 1 ]
    let peerags households with [is-superior = false and is-subordinate = false and is-peer = true and [households-cnt] of settlement settlementId > 1 ]

    let supagsAll households with [is-superior = true and [households-cnt] of settlement settlementId > 1 ]
    let subagsAll households with [is-subordinate = true and [households-cnt] of settlement settlementId > 1 ]
    let peeragsAll households with [is-peer = true and [households-cnt] of settlement settlementId > 1 ]


    ask settlements with [households-cnt > 1][
      set supags households-list with [is-superior = true and is-subordinate = false and is-peer = false ]
      if any? supags [
        set loadList lput (mean [sum [load] of my-in-links] of supags) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of supags) tloadList
        set tskList lput (mean [sum [assigned-tasks] of my-in-links] of supags) tskList
      ]
    ]

    if (not empty? loadList) [set superiorAgentsLoad mean loadList]
    if (not empty? tloadList) [set superiorAgentsTotalLoad mean tloadList]
    if (not empty? tskList) [set superiorAgentsTasks mean tskList]

    set loadList []
    set tloadList []
    set tskList []

    ask settlements with [households-cnt > 1] [
      set subags households-list with [is-superior = false and is-subordinate = true and is-peer = false ]
      if any? subags [
        set loadList lput (mean [sum [load] of my-in-links] of subags) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of subags) tloadList
        set tskList lput (mean [sum [assigned-tasks] of my-in-links] of subags) tskList
      ]
    ]

    if (not empty? loadList) [set subordinateAgentsLoad mean loadList]
    if (not empty? tloadList) [set subordinateAgentsTotalLoad mean tloadList]
    if (not empty? tskList) [set subordinateAgentsTasks mean tskList]

    set loadList []
    set tloadList []
    set tskList []

    ask settlements with [households-cnt > 1] [
      set peerags households-list with [is-superior = false and is-subordinate = false and is-peer = true ]
      if any? peerags [
        set loadList lput (mean [sum [load] of my-in-links] of peerags) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of peerags) tloadList
        set tskList lput (mean [sum [assigned-tasks] of my-in-links] of peerags) tskList
      ]
    ]

    if (not empty? loadList) [set peerAgentsLoad mean loadList]
    if (not empty? tloadList) [set peerAgentsTotalLoad mean tloadList]
    if (not empty? tskList) [set peerAgentsTasks mean tskList]


    ;; Logging information, tasks, loads, for agents with multiple relation types
    set loadList []
    set tloadList []
    set tskList []

    ask settlements with [households-cnt > 1] [
      set supagsAll households-list with [is-superior = true ]
      if any? supagsAll [
        set loadList lput (mean [sum [load] of my-in-links] of supagsAll) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of supagsAll) tloadList
        set tskList lput (mean [sum [assigned-tasks] of my-in-links] of supagsAll) tskList
      ]
    ]

    if (not empty? loadList) [set superiorAgentsAllLoad mean loadList]
    if (not empty? tloadList) [set superiorAgentsAllTotalLoad mean tloadList]
    if (not empty? tskList) [set superiorAgentsAllTasks mean tskList]

    set loadList []
    set tloadList []
    set tskList []

    ask settlements with [households-cnt > 1] [
      set subagsAll households-list with [is-subordinate = true ]
      if any? subagsAll [
        set loadList lput (mean [sum [load] of my-in-links] of subagsAll) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of subagsAll) tloadList
        set tskList lput (mean [sum [assigned-tasks] of my-in-links] of subagsAll) tskList
      ]
    ]

    if (not empty? loadList) [set subordinateAgentsAllLoad mean loadList]
    if (not empty? tloadList) [set subordinateAgentsAllTotalLoad mean tloadList]
    if (not empty? tskList) [set subordinateAgentsAllTasks mean tskList]

    set loadList []
    set tloadList []
    set tskList []

    ask settlements with [households-cnt > 1] [
      set peeragsAll households-list with [is-peer = true ]
      if any? peeragsAll [
        set loadList lput (mean [sum [load] of my-in-links] of peeragsAll) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of peeragsAll) tloadList
        set tskList lput (mean [sum [assigned-tasks] of my-in-links] of peeragsAll) tskList
      ]
    ]
    if (not empty? loadList) [set peerAgentsAllLoad mean loadList]
    if (not empty? tloadList) [set peerAgentsAllTotalLoad mean tloadList]
    if (not empty? tskList) [set peerAgentsAllTasks mean tskList]

    let ags households with [[households-cnt] of settlement settlementId > 1 ]

    set loadList []
    set tloadList []
    set tskList []

    ask settlements with [households-cnt > 1] [
      set ags households-list
      if any? ags [
        set loadList lput (mean [sum [load] of my-in-links] of ags) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of ags) tloadList
      ]
    ]

    if (not empty? loadList) [set agentsLoad mean loadList]
    if (not empty? tloadList) [set agentsTotalLoad mean tloadList]

    let agntLdTmp []
    ask households with [[households-cnt] of settlement settlementId > 1 ] [ set agntLdTmp lput (sum [load] of my-in-links) agntLdTmp ]
    set agntLd agntLdTmp

    ;; Reorganization/adaptation
    ;; Evaluation of agent relations
    reorganization-adaptation

    ;; Update relation change histogram
    updt-relations-hist
  ]

  ;; Enable across settlements spatial interaction model
  if sint != "Off" [ spatial-interaction ]

  ;; Agents update (storage, utility, time-steps, etc.)
  update-agents

  ;; Selection dynamics
  if egt [
    set cagents count households with [strategy = 0]
    set dagents count households with [strategy = 1]
    set tftagents count households with [strategy = 2]
    ifelse count links > 0 [
      set cbehavior precision (count links with [behavior = 0] / count links) 2
      set dbehavior precision (count links with [behavior = 1] / count links) 2
    ][ set cbehavior 0 set dbehavior 0 ]

    selection-dynamics
  ]


  let agntStrgTmp []
  ask households [ set agntStrgTmp lput (sum storage) agntStrgTmp ]
  set agntStrg agntStrgTmp

  ;; Watchdog variables
;  if (dm = "Self-Organization") [
  if (dm > 3)[

    ;; Unique/uniform relation types
    let strgList []
    let uIndList []
    let uList []
    let aList []

    let supags households with [is-superior = true and is-subordinate = false and is-peer = false and [households-cnt] of settlement settlementId > 1  ]
    let subags households with [is-superior = false and is-subordinate = true and is-peer = false and [households-cnt] of settlement settlementId > 1  ]
    let peerags households with [is-superior = false and is-subordinate = false and is-peer = true and [households-cnt] of settlement settlementId > 1  ]

    let supagsAll households with [is-superior = true and [households-cnt] of settlement settlementId > 1  ]
    let subagsAll households with [is-subordinate = true and [households-cnt] of settlement settlementId > 1  ]
    let peeragsAll households with [is-peer = true and [households-cnt] of settlement settlementId > 1  ]


    ask settlements with [households-cnt > 1]  [
      set supags households-list with [is-superior = true and is-subordinate = false and is-peer = false ]
      if any? supags [
        set strgList lput (mean [sum storage] of supags) strgList
        set uIndList lput (mean [utility / individuals] of supags) uIndList
        set uList lput (mean [utility] of supags) uList
        set aList lput (count supags) aList
      ]
    ]

    if (not empty? strgList) [set superiorAgentsStrg mean strgList]
    if (not empty? uIndList) [set superiorAgentsUtilIndiv mean uIndList]
    if (not empty? uList) [set superiorAgentsUtil mean uList]
    if (not empty? aList) [set superiorAgents mean aList]

    set strgList []
    set uIndList []
    set uList []
    set aList []

    ask settlements with [households-cnt > 1]  [
      set subags households-list with [is-superior = false and is-subordinate = true and is-peer = false ]
      if any? subags [
        set strgList lput (mean [sum storage] of subags) strgList
        set uIndList lput (mean [utility / individuals] of subags) uIndList
        set uList lput (mean [utility] of subags) uList
        set aList lput (count subags) aList
      ]
    ]

    if (not empty? strgList) [set subordinateAgentsStrg mean strgList]
    if (not empty? uIndList) [set subordinateAgentsUtilIndiv mean uIndList]
    if (not empty? uList) [set subordinateAgentsUtil mean uList]
    if (not empty? aList) [set subordinateAgents mean aList]

    set strgList []
    set uIndList []
    set uList []
    set aList []

    ask settlements with [households-cnt > 1]  [
      set peerags households-list with [is-superior = false and is-subordinate = false and is-peer = true ]
      if any? peerags [
        set strgList lput (mean [sum storage] of peerags) strgList
        set uIndList lput (mean [utility / individuals] of peerags) uIndList
        set uList lput (mean [utility] of peerags) uList
        set aList lput (count peerags) aList
      ]
    ]

    if (not empty? strgList) [set peerAgentsStrg mean strgList]
    if (not empty? uIndList) [set peerAgentsUtilIndiv mean uIndList]
    if (not empty? uList) [set peerAgentsUtil mean uList]
    if (not empty? aList) [set peerAgents mean aList]


    ;; Multiple relation types
    set strgList []
    set uIndList []
    set uList []
    set aList []

    ask settlements with [households-cnt > 1]  [
      set supagsAll households-list with [is-superior = true ]
      if any? supagsAll [
        set strgList lput (mean [sum storage] of supagsAll) strgList
        set uIndList lput (mean [utility / individuals] of supagsAll) uIndList
        set uList lput (mean [utility] of supagsAll) uList
        set aList lput (count supagsAll) aList
      ]
    ]

    if (not empty? strgList) [set superiorAgentsAllStrg mean strgList]
    if (not empty? uIndList) [set superiorAgentsAllUtilIndiv mean uIndList]
    if (not empty? uList) [set superiorAgentsAllUtil mean uList]
    if (not empty? aList) [set superiorAgentsAll mean aList]

    set strgList []
    set uIndList []
    set uList []
    set aList []

    ask settlements with [households-cnt > 1]  [
      set subagsAll households-list with [is-subordinate = true ]
      if any? subagsAll [
        set strgList lput (mean [sum storage] of subagsAll) strgList
        set uIndList lput (mean [utility / individuals] of subagsAll) uIndList
        set uList lput (mean [utility] of subagsAll) uList
        set aList lput (count subagsAll) aList
      ]
    ]

    if (not empty? strgList) [set subordinateAgentsAllStrg mean strgList]
    if (not empty? uIndList) [set subordinateAgentsAllUtilIndiv mean uIndList]
    if (not empty? uList) [set subordinateAgentsAllUtil mean uList]
    if (not empty? aList) [set subordinateAgentsAll mean aList]

    set strgList []
    set uIndList []
    set uList []
    set aList []

    ask settlements with [households-cnt > 1]  [
      set peeragsAll households-list with [is-peer = true ]
      if any? peeragsAll [
        set strgList lput (mean [sum storage] of peeragsAll) strgList
        set uIndList lput (mean [utility / individuals] of peeragsAll) uIndList
        set uList lput (mean [utility] of peeragsAll) uList
        set aList lput (count peeragsAll) aList
      ]
    ]

    if (not empty? strgList) [set peerAgentsAllStrg mean strgList]
    if (not empty? uIndList) [set peerAgentsAllUtilIndiv mean uIndList]
    if (not empty? uList) [set peerAgentsAllUtil mean uList]
    if (not empty? aList) [set peerAgentsAll mean aList]

  ]

  set agents 0
  set agentsUtil 0
  set agentsUtilIndiv 0
  set agentsStrg 0
  let ags households

  let strgList []
  let uIndList []
  let uList []
  let aList []

  ask settlements with [households-cnt > 1]  [
    set ags households-list
    if any? ags [
      set strgList lput (mean [sum storage] of ags) strgList
      set uIndList lput (mean [utility / individuals] of ags) uIndList
      set uList lput (mean [utility] of ags) uList
      set aList lput (count ags) aList
    ]
  ]

  if (not empty? strgList) [set agentsStrg mean strgList]
  if (not empty? uIndList) [set agentsUtilIndiv mean uIndList]
  if (not empty? uList) [set agentsUtil mean uList]
  if (not empty? aList) [set agents mean aList]


  ;; Population dynamics
  population-dynamics

;  print (word ticks "\t" nomdps "\t" nosts ) ; munber of mdps solution runs and total states at current time-step

  ;; Run volcanic erupion model
  if ve = true [ run-natural-disaster ]

  ;; Advance time
  tick

;  if (dm = "Self-Organization" AND any? households)[
;    ;; Save social networks data
;    file-open (word "output/" dm "/" brn "/" sr "_" aqf "_social-networks-vertices.txt")
;    ask households [
;      file-type (word ticks " " settlementId " " individuals " " xcor "." who " " ycor "." who " " utility " " sum storage " " sum [load] of my-in-links " " sum [load-total] of my-in-links " " years-settled " " count my-in-superiors " " count my-in-subordinates " " count my-in-peers " " count my-in-acquaintances "\n")
;    ]
;
;    file-open (word "output/" dm "/" brn "/" sr "_" aqf "_social-networks-lines.txt")
;    ask links [
;      file-type (word ticks " " breed " " [who] of end1 " " [who] of end2 " " time-steps " " time-steps-in-lack " " time-steps-on-load " " load " " load-total " " assigned-tasks " " assigned-tasks-total "\n")
;    ]
;  ]

  ;; Check settlement and cultivation patterns after one 'n half milenium
;  if ticks > 1500 AND any? households AND rdL = 0.6
;    [
;      ; type (word "Storing settlement & land-use patterns")
;      set settlement-pattern gis:turtle-dataset households
;      gis:store-dataset settlement-pattern (word "output/" dm "/" brn "/" sr "_" aqf "_settlements_" (ticks - 1500))
;
;      ; ask land-patches [ if is-cultivated = false [ set agricultural-production 0 ] ]
;      set cultivation-pattern gis:patch-dataset agricultural-production
;      gis:store-dataset cultivation-pattern (word "output/" dm "/" brn "/" sr "_" aqf "_cultivation_" (ticks - 1500))
;      ; print (word " ...done.")
;
;;      ;; More exports here, interface, plots and output
;;      export-all-plots (word "output/" dm "/" brn "/_" sr "_" aqf "_plots.csv")
;      carefully
;      [
;        export-interface (word "output/" dm "/" brn "/_" sr "_" aqf "_interaface.png")
;;        export-output (word "output/" dm "/" brn "/_" sr "_" aqf "_output.txt")
;      ]
;      [ print (word "Current experiment runs in background. Cannot export Interface (png) files.") ]
;;      [ print (word "Current experiment runs in background. Cannot export Interface (png) and Output (txt) files.") ]
;    ]


  ;; Stop running the model if all households die or time advanced to 2000 years.
  if not any? households OR (ticks >= 2000)
  [
    update-environment
    print (word "Total time elapsed: " round (timer / 60) " minutes.")
    stop
;    if (dm = "Self-Organization")[ file-close-all ]
    if (dm > 3)[ file-close-all ]
  ]

;  profiler:stop
;  if ticks mod 50 = 0 [
;    print (word "[" (3100 - ticks) " BCE] Settlements/Households: " count settlements "/" count households " --- ")
;    print profiler:report  ;; view the results
;  ]
;  profiler:reset         ;; clear the data
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN - TO GO DIVIDED ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go-all
    go-init
    go-update-environment 
    go-cultivate-harvest
    go-self-organization
    go-spatial-interaction
    go-agents-update
    go-selection-dynamics
    go-population-dynamics
    go-natural-disaster
    go-tick-end
end

to go-init
;  profiler:start
  let aqf "off"

;  ask settlements [
;    print (word population-size " - " sum [individuals] of households-list)
;    print (word households-cnt " - " count households-list)
;  ]

  if ap? [ set aqf "on" ]
  ;; Print current year
  print ""
  print (word "--- Year " (3100 - ticks) " BC")

  ;; Set known archaeological settlement sites locations and types
  get-current-sites ticks

  if (ticks > 0) [
    set nomdps 0 ; munber of mdps run at every time-step
    set nosts 0  ; number of states at every time-step

    ;; Migration process - Disabled for now
    ;consider-migration
  ]
end

to go-update-environment 
  ;; Environmental updates
  update-environment
end

to go-cultivate-harvest
  ;; Cultivate, harvest and calculate agents utility
  cultivate-harvest
end

to go-self-organization
;; If household agents evolute independently (dm = 1) do nothing
  ;; When dm = 2 or dm = 3 then egalitarian-like sharing of resources
  if (dm = 2 or dm = 3)[
    ; Equally distribute resources among household agents within settlement
    share-resources
  ]

  if (dm > 3) [ ;; Self-Organization
    ; Decision making / Adaptation / Re-organization

    ; Set relation changes
    set relationChangesFromAcqToAuth 0
    set relationChangesFromPeerToAuth 0
    set relationChangesFromAcqToPeer 0
    set relationChangesFromAuthToPeer 0
    set relationChangesFromAuthToAcq 0
    set relationChangesFromPeerToAcq 0

    ;; Watchdog variables
    set superiorAgentsLoad 0
    set subordinateAgentsLoad 0
    set peerAgentsLoad 0

    set superiorAgentsAllLoad 0
    set subordinateAgentsAllLoad 0
    set peerAgentsAllLoad 0

    set superiorAgentsTotalLoad 0
    set subordinateAgentsTotalLoad 0
    set peerAgentsTotalLoad 0

    set superiorAgentsAllTotalLoad 0
    set subordinateAgentsAllTotalLoad 0
    set peerAgentsAllTotalLoad 0

    set agentsLoad 0
    set agentsTotalLoad 0

    set superiorAgentsTasks 0
    set subordinateAgentsTasks 0
    set peerAgentsTasks 0

    set superiorAgentsAllTasks 0
    set subordinateAgentsAllTasks 0
    set peerAgentsAllTasks 0

    set superiorAgents 0
    set subordinateAgents 0
    set peerAgents 0

    set superiorAgentsUtil 0
    set subordinateAgentsUtil 0
    set peerAgentsUtil 0

    set superiorAgentsUtilIndiv 0
    set subordinateAgentsUtilIndiv 0
    set peerAgentsUtilIndiv 0

    set superiorAgentsAll 0
    set subordinateAgentsAll 0
    set peerAgentsAll 0

    set superiorAgentsAllUtil 0
    set subordinateAgentsAllUtil 0
    set peerAgentsAllUtil 0

    set superiorAgentsAllUtilIndiv 0
    set subordinateAgentsAllUtilIndiv 0
    set peerAgentsAllUtilIndiv 0

    set superiorAgentsStrg 0
    set subordinateAgentsStrg 0
    set peerAgentsStrg 0

    set superiorAgentsAllStrg 0
    set subordinateAgentsAllStrg 0
    set peerAgentsAllStrg 0

    ;; Agents interaction
    ;; Targeted resource distribution based on agent relations
    ifelse egt
    [ self-organization-strategic ] ; evolutionary game-theoretic approach (distribution game)
    [ self-organization ]           ; structural adaptation decision-making

    ;; Logging information, tasks, loads, for agents with unique relation types
    let loadList []
    let tloadList []
    let tskList []

    let supags households with [is-superior = true and is-subordinate = false and is-peer = false and [households-cnt] of settlement settlementId > 1 ]
    let subags households with [is-superior = false and is-subordinate = true and is-peer = false and [households-cnt] of settlement settlementId > 1 ]
    let peerags households with [is-superior = false and is-subordinate = false and is-peer = true and [households-cnt] of settlement settlementId > 1 ]

    let supagsAll households with [is-superior = true and [households-cnt] of settlement settlementId > 1 ]
    let subagsAll households with [is-subordinate = true and [households-cnt] of settlement settlementId > 1 ]
    let peeragsAll households with [is-peer = true and [households-cnt] of settlement settlementId > 1 ]


    ask settlements with [households-cnt > 1][
      set supags households-list with [is-superior = true and is-subordinate = false and is-peer = false ]
      if any? supags [
        set loadList lput (mean [sum [load] of my-in-links] of supags) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of supags) tloadList
        set tskList lput (mean [sum [assigned-tasks] of my-in-links] of supags) tskList
      ]
    ]

    if (not empty? loadList) [set superiorAgentsLoad mean loadList]
    if (not empty? tloadList) [set superiorAgentsTotalLoad mean tloadList]
    if (not empty? tskList) [set superiorAgentsTasks mean tskList]

    set loadList []
    set tloadList []
    set tskList []

    ask settlements with [households-cnt > 1] [
      set subags households-list with [is-superior = false and is-subordinate = true and is-peer = false ]
      if any? subags [
        set loadList lput (mean [sum [load] of my-in-links] of subags) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of subags) tloadList
        set tskList lput (mean [sum [assigned-tasks] of my-in-links] of subags) tskList
      ]
    ]

    if (not empty? loadList) [set subordinateAgentsLoad mean loadList]
    if (not empty? tloadList) [set subordinateAgentsTotalLoad mean tloadList]
    if (not empty? tskList) [set subordinateAgentsTasks mean tskList]

    set loadList []
    set tloadList []
    set tskList []

    ask settlements with [households-cnt > 1] [
      set peerags households-list with [is-superior = false and is-subordinate = false and is-peer = true ]
      if any? peerags [
        set loadList lput (mean [sum [load] of my-in-links] of peerags) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of peerags) tloadList
        set tskList lput (mean [sum [assigned-tasks] of my-in-links] of peerags) tskList
      ]
    ]

    if (not empty? loadList) [set peerAgentsLoad mean loadList]
    if (not empty? tloadList) [set peerAgentsTotalLoad mean tloadList]
    if (not empty? tskList) [set peerAgentsTasks mean tskList]


    ;; Logging information, tasks, loads, for agents with multiple relation types
    set loadList []
    set tloadList []
    set tskList []

    ask settlements with [households-cnt > 1] [
      set supagsAll households-list with [is-superior = true ]
      if any? supagsAll [
        set loadList lput (mean [sum [load] of my-in-links] of supagsAll) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of supagsAll) tloadList
        set tskList lput (mean [sum [assigned-tasks] of my-in-links] of supagsAll) tskList
      ]
    ]

    if (not empty? loadList) [set superiorAgentsAllLoad mean loadList]
    if (not empty? tloadList) [set superiorAgentsAllTotalLoad mean tloadList]
    if (not empty? tskList) [set superiorAgentsAllTasks mean tskList]

    set loadList []
    set tloadList []
    set tskList []

    ask settlements with [households-cnt > 1] [
      set subagsAll households-list with [is-subordinate = true ]
      if any? subagsAll [
        set loadList lput (mean [sum [load] of my-in-links] of subagsAll) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of subagsAll) tloadList
        set tskList lput (mean [sum [assigned-tasks] of my-in-links] of subagsAll) tskList
      ]
    ]

    if (not empty? loadList) [set subordinateAgentsAllLoad mean loadList]
    if (not empty? tloadList) [set subordinateAgentsAllTotalLoad mean tloadList]
    if (not empty? tskList) [set subordinateAgentsAllTasks mean tskList]

    set loadList []
    set tloadList []
    set tskList []

    ask settlements with [households-cnt > 1] [
      set peeragsAll households-list with [is-peer = true ]
      if any? peeragsAll [
        set loadList lput (mean [sum [load] of my-in-links] of peeragsAll) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of peeragsAll) tloadList
        set tskList lput (mean [sum [assigned-tasks] of my-in-links] of peeragsAll) tskList
      ]
    ]
    if (not empty? loadList) [set peerAgentsAllLoad mean loadList]
    if (not empty? tloadList) [set peerAgentsAllTotalLoad mean tloadList]
    if (not empty? tskList) [set peerAgentsAllTasks mean tskList]

    let ags households with [[households-cnt] of settlement settlementId > 1 ]

    set loadList []
    set tloadList []
    set tskList []

    ask settlements with [households-cnt > 1] [
      set ags households-list
      if any? ags [
        set loadList lput (mean [sum [load] of my-in-links] of ags) loadList
        set tloadList lput (mean [sum [load-total] of my-in-links] of ags) tloadList
      ]
    ]

    if (not empty? loadList) [set agentsLoad mean loadList]
    if (not empty? tloadList) [set agentsTotalLoad mean tloadList]

    let agntLdTmp []
    ask households with [[households-cnt] of settlement settlementId > 1 ] [ set agntLdTmp lput (sum [load] of my-in-links) agntLdTmp ]
    set agntLd agntLdTmp

    ;; Reorganization/adaptation
    ;; Evaluation of agent relations
    reorganization-adaptation

    ;; Update relation change histogram
    updt-relations-hist
  ]
end

to go-spatial-interaction
  ;; Enable across settlements spatial interaction model
  if sint != "Off" [ spatial-interaction ]
end

to go-agents-update
  ;; Agents update (storage, utility, time-steps, etc.)
  update-agents
end

to go-selection-dynamics
 ;; Selection dynamics
  if egt [
    set cagents count households with [strategy = 0]
    set dagents count households with [strategy = 1]
    set tftagents count households with [strategy = 2]
    ifelse count links > 0 [
      set cbehavior precision (count links with [behavior = 0] / count links) 2
      set dbehavior precision (count links with [behavior = 1] / count links) 2
    ][ set cbehavior 0 set dbehavior 0 ]

    selection-dynamics
  ]


  let agntStrgTmp []
  ask households [ set agntStrgTmp lput (sum storage) agntStrgTmp ]
  set agntStrg agntStrgTmp

  ;; Watchdog variables
;  if (dm = "Self-Organization") [
  if (dm > 3)[

    ;; Unique/uniform relation types
    let strgList []
    let uIndList []
    let uList []
    let aList []

    let supags households with [is-superior = true and is-subordinate = false and is-peer = false and [households-cnt] of settlement settlementId > 1  ]
    let subags households with [is-superior = false and is-subordinate = true and is-peer = false and [households-cnt] of settlement settlementId > 1  ]
    let peerags households with [is-superior = false and is-subordinate = false and is-peer = true and [households-cnt] of settlement settlementId > 1  ]

    let supagsAll households with [is-superior = true and [households-cnt] of settlement settlementId > 1  ]
    let subagsAll households with [is-subordinate = true and [households-cnt] of settlement settlementId > 1  ]
    let peeragsAll households with [is-peer = true and [households-cnt] of settlement settlementId > 1  ]


    ask settlements with [households-cnt > 1]  [
      set supags households-list with [is-superior = true and is-subordinate = false and is-peer = false ]
      if any? supags [
        set strgList lput (mean [sum storage] of supags) strgList
        set uIndList lput (mean [utility / individuals] of supags) uIndList
        set uList lput (mean [utility] of supags) uList
        set aList lput (count supags) aList
      ]
    ]

    if (not empty? strgList) [set superiorAgentsStrg mean strgList]
    if (not empty? uIndList) [set superiorAgentsUtilIndiv mean uIndList]
    if (not empty? uList) [set superiorAgentsUtil mean uList]
    if (not empty? aList) [set superiorAgents mean aList]

    set strgList []
    set uIndList []
    set uList []
    set aList []

    ask settlements with [households-cnt > 1]  [
      set subags households-list with [is-superior = false and is-subordinate = true and is-peer = false ]
      if any? subags [
        set strgList lput (mean [sum storage] of subags) strgList
        set uIndList lput (mean [utility / individuals] of subags) uIndList
        set uList lput (mean [utility] of subags) uList
        set aList lput (count subags) aList
      ]
    ]

    if (not empty? strgList) [set subordinateAgentsStrg mean strgList]
    if (not empty? uIndList) [set subordinateAgentsUtilIndiv mean uIndList]
    if (not empty? uList) [set subordinateAgentsUtil mean uList]
    if (not empty? aList) [set subordinateAgents mean aList]

    set strgList []
    set uIndList []
    set uList []
    set aList []

    ask settlements with [households-cnt > 1]  [
      set peerags households-list with [is-superior = false and is-subordinate = false and is-peer = true ]
      if any? peerags [
        set strgList lput (mean [sum storage] of peerags) strgList
        set uIndList lput (mean [utility / individuals] of peerags) uIndList
        set uList lput (mean [utility] of peerags) uList
        set aList lput (count peerags) aList
      ]
    ]

    if (not empty? strgList) [set peerAgentsStrg mean strgList]
    if (not empty? uIndList) [set peerAgentsUtilIndiv mean uIndList]
    if (not empty? uList) [set peerAgentsUtil mean uList]
    if (not empty? aList) [set peerAgents mean aList]


    ;; Multiple relation types
    set strgList []
    set uIndList []
    set uList []
    set aList []

    ask settlements with [households-cnt > 1]  [
      set supagsAll households-list with [is-superior = true ]
      if any? supagsAll [
        set strgList lput (mean [sum storage] of supagsAll) strgList
        set uIndList lput (mean [utility / individuals] of supagsAll) uIndList
        set uList lput (mean [utility] of supagsAll) uList
        set aList lput (count supagsAll) aList
      ]
    ]

    if (not empty? strgList) [set superiorAgentsAllStrg mean strgList]
    if (not empty? uIndList) [set superiorAgentsAllUtilIndiv mean uIndList]
    if (not empty? uList) [set superiorAgentsAllUtil mean uList]
    if (not empty? aList) [set superiorAgentsAll mean aList]

    set strgList []
    set uIndList []
    set uList []
    set aList []

    ask settlements with [households-cnt > 1]  [
      set subagsAll households-list with [is-subordinate = true ]
      if any? subagsAll [
        set strgList lput (mean [sum storage] of subagsAll) strgList
        set uIndList lput (mean [utility / individuals] of subagsAll) uIndList
        set uList lput (mean [utility] of subagsAll) uList
        set aList lput (count subagsAll) aList
      ]
    ]

    if (not empty? strgList) [set subordinateAgentsAllStrg mean strgList]
    if (not empty? uIndList) [set subordinateAgentsAllUtilIndiv mean uIndList]
    if (not empty? uList) [set subordinateAgentsAllUtil mean uList]
    if (not empty? aList) [set subordinateAgentsAll mean aList]

    set strgList []
    set uIndList []
    set uList []
    set aList []

    ask settlements with [households-cnt > 1]  [
      set peeragsAll households-list with [is-peer = true ]
      if any? peeragsAll [
        set strgList lput (mean [sum storage] of peeragsAll) strgList
        set uIndList lput (mean [utility / individuals] of peeragsAll) uIndList
        set uList lput (mean [utility] of peeragsAll) uList
        set aList lput (count peeragsAll) aList
      ]
    ]

    if (not empty? strgList) [set peerAgentsAllStrg mean strgList]
    if (not empty? uIndList) [set peerAgentsAllUtilIndiv mean uIndList]
    if (not empty? uList) [set peerAgentsAllUtil mean uList]
    if (not empty? aList) [set peerAgentsAll mean aList]

  ]

  set agents 0
  set agentsUtil 0
  set agentsUtilIndiv 0
  set agentsStrg 0
  let ags households

  let strgList []
  let uIndList []
  let uList []
  let aList []

  ask settlements with [households-cnt > 1]  [
    set ags households-list
    if any? ags [
      set strgList lput (mean [sum storage] of ags) strgList
      set uIndList lput (mean [utility / individuals] of ags) uIndList
      set uList lput (mean [utility] of ags) uList
      set aList lput (count ags) aList
    ]
  ]

  if (not empty? strgList) [set agentsStrg mean strgList]
  if (not empty? uIndList) [set agentsUtilIndiv mean uIndList]
  if (not empty? uList) [set agentsUtil mean uList]
  if (not empty? aList) [set agents mean aList]
end

to go-population-dynamics
;; Population dynamics
  population-dynamics

;  print (word ticks "\t" nomdps "\t" nosts ) ; munber of mdps solution runs and total states at current time-step
end

to go-natural-disaster
;; Run volcanic erupion model
  if ve = true [ run-natural-disaster ]
end

to go-tick-end
;; Advance time
  tick

;  if (dm = "Self-Organization" AND any? households)[
;    ;; Save social networks data
;    file-open (word "output/" dm "/" brn "/" sr "_" aqf "_social-networks-vertices.txt")
;    ask households [
;      file-type (word ticks " " settlementId " " individuals " " xcor "." who " " ycor "." who " " utility " " sum storage " " sum [load] of my-in-links " " sum [load-total] of my-in-links " " years-settled " " count my-in-superiors " " count my-in-subordinates " " count my-in-peers " " count my-in-acquaintances "\n")
;    ]
;
;    file-open (word "output/" dm "/" brn "/" sr "_" aqf "_social-networks-lines.txt")
;    ask links [
;      file-type (word ticks " " breed " " [who] of end1 " " [who] of end2 " " time-steps " " time-steps-in-lack " " time-steps-on-load " " load " " load-total " " assigned-tasks " " assigned-tasks-total "\n")
;    ]
;  ]

  ;; Check settlement and cultivation patterns after one 'n half milenium
;  if ticks > 1500 AND any? households AND rdL = 0.6
;    [
;      ; type (word "Storing settlement & land-use patterns")
;      set settlement-pattern gis:turtle-dataset households
;      gis:store-dataset settlement-pattern (word "output/" dm "/" brn "/" sr "_" aqf "_settlements_" (ticks - 1500))
;
;      ; ask land-patches [ if is-cultivated = false [ set agricultural-production 0 ] ]
;      set cultivation-pattern gis:patch-dataset agricultural-production
;      gis:store-dataset cultivation-pattern (word "output/" dm "/" brn "/" sr "_" aqf "_cultivation_" (ticks - 1500))
;      ; print (word " ...done.")
;
;;      ;; More exports here, interface, plots and output
;;      export-all-plots (word "output/" dm "/" brn "/_" sr "_" aqf "_plots.csv")
;      carefully
;      [
;        export-interface (word "output/" dm "/" brn "/_" sr "_" aqf "_interaface.png")
;;        export-output (word "output/" dm "/" brn "/_" sr "_" aqf "_output.txt")
;      ]
;      [ print (word "Current experiment runs in background. Cannot export Interface (png) files.") ]
;;      [ print (word "Current experiment runs in background. Cannot export Interface (png) and Output (txt) files.") ]
;    ]


  ;; Stop running the model if all households die or time advanced to 2000 years.
  if not any? households OR (ticks >= 2000)
  [
    update-environment
    print (word "Total time elapsed: " round (timer / 60) " minutes.")
    stop
;    if (dm = "Self-Organization")[ file-close-all ]
    if (dm > 3)[ file-close-all ]
  ]

;  profiler:stop
;  if ticks mod 50 = 0 [
;    print (word "[" (3100 - ticks) " BCE] Settlements/Households: " count settlements "/" count households " --- ")
;    print profiler:report  ;; view the results
;  ]
;  profiler:reset         ;; clear the data
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END - TO GO DIVIDED ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;--------------------------------------- MY REPORTERS ---------------------------------------
to-report settlement-elevation-stats
  let results []
  ask settlements [
    let my-households households with [ settlementId = [who] of myself ]
    let cultivated-patches patch-set [ cultivating-patches ] of my-households
    
    let avg-elev -9999
    let max-elev -9999
    let min-elev -9999
    
    if any? cultivated-patches [
      set avg-elev mean [ elevation ] of cultivated-patches
      set max-elev max [ elevation ] of cultivated-patches
      set min-elev min [ elevation ] of cultivated-patches
    ]
    
    set results lput (list who avg-elev max-elev min-elev) results
  ]
  report results
end

; we currently don't have coastline distance data for each patch sadly...
to-report settlement-coastline-stats
  let results []
  ask settlements [
    let my-households households with [ settlementId = [who] of myself ]
    let cultivated-patches patch-set [ cultivating-patches ] of my-households
    
    let avg-dist -9999
    let min-dist -9999
    let max-dist -9999
    
    if any? cultivated-patches [
      set avg-dist mean [ dt-coastline ] of cultivated-patches
      set min-dist min [ dt-coastline ] of cultivated-patches
      set max-dist max [ dt-coastline ] of cultivated-patches
    ]
    
    set results lput (list who avg-dist min-dist max-dist) results
  ]
  report results
end

to-report settlement-river-stats
  let results []
  ask settlements [
    let my-households households with [ settlementId = [who] of myself ]
    let cultivated-patches patch-set [ cultivating-patches ] of my-households
    
    let river-count 0
    if any? cultivated-patches [
      set river-count count cultivated-patches with [ has-river ]
    ]
    
    set results lput (list who river-count) results
  ]
  report results
end

to-report settlement-spring-stats
  let results []
  ask settlements [
    let my-households households with [ settlementId = [who] of myself ]
    let cultivated-patches patch-set [ cultivating-patches ] of my-households
    
    let spring-count 0
    if any? cultivated-patches [
      set spring-count count cultivated-patches with [ has-spring ]
    ]
    
    set results lput (list who spring-count) results
  ]
  report results
end

to-report settlement-populations
  report [ (list who population-size) ] of settlements
end

to-report settlement-households
  report [ (list who households-cnt) ] of settlements
end

to-report all-settlements-dt-coastline
  let results []
  ask settlements [
    set results lput (list who dt-coastline-settlement) results
  ]
  report results
end

to-report settlement-uThres-household-avg-stats
  let results []
  ask settlements [
    let my-households households with [ settlementId = [who] of myself ]
    let avg-uThres mean [ uThres ] of my-households
    set results lput (list who avg-uThres) results
  ]
  report results
end

to-report settlement-uThres-total-stats
  let results []
  ask settlements [
    let my-households households with [ settlementId = [who] of myself ]
    let total-uThres sum [ uThres ] of my-households
    set results lput (list who total-uThres) results
  ]
  report results
end

to-report settlement-total-utility
  let results []
  ask settlements [
    let my-households households with [ settlementId = [who] of myself ]
    let total-utility sum [ utility ] of my-households
    set results lput (list who total-utility) results
  ]
  report results
end

to-report settlements-tradable-resources
  let results []
  ask settlements [
    set results lput (list who tradable-resources) results
  ]
  report results
end

;--------------------------------------- MY REPORTERS ---------------------------------------

;; Strategic self-organization behavior - distribution game
to self-organization-strategic
  ask households [
    set reward 0
    ask my-out-links [ set assigned-tasks 0 set load 0 ]
  ]

  ask households [
    if count my-out-links > 0 [
      let pl_exchange round (utility / ( (count my-out-links) * (individuals + 1) )) ; player exchange
      let player self

      ;; Distribution game
      ask my-out-links [
        ;; Initialize relation parameters for the current time step (year)
        set assigned-tasks 0
        set load 0
        let pl_bhvr behavior ; strategic behavior of player
        let op_bhvr 0 ; strategic behavior of opponent
        let op_exchange 0; opponent exchange
        let opponent end2 ; opponent

        ask end2 [ ; opponent
                   ;; Check opponent agent strategy
          if (strategy != 0) [ ask my-out-links with [end2 = player] [ set op_bhvr behavior ] ]
          set op_exchange round (utility / ( (count my-out-links) * (individuals + 1) )) ; opponent exchange
        ]

        ;      print (word "Player " player ", exchange:" pl_exchange ", behavior:" pl_bhvr " -- Opponent " opponent ", exchange:" op_exchange ", behavior:" op_bhvr)

        ifelse (pl_bhvr = 0 and op_bhvr = 0)
        [ ;; both cooperative
          ask player [ set reward reward + (op_exchange - pl_exchange) ]
          ;; Check if positive reward, else load to agent
          if (op_exchange - pl_exchange) < 0 [
            set assigned-tasks assigned-tasks + 1
            set load load + (pl_exchange - op_exchange)
            set assigned-tasks-total assigned-tasks-total + 1
            set load-total load-total + (pl_exchange - op_exchange)
          ]
        ]
        [
          ifelse (pl_bhvr = 0 and op_bhvr = 1)
          [ ;; player cooperative
            ask player [ set reward reward - pl_exchange ]
            ;; load same as the exchange given
            set assigned-tasks assigned-tasks + 1
            set load load + pl_exchange
            set assigned-tasks-total assigned-tasks-total + 1
            set load-total load-total + pl_exchange
          ]
          [
            ifelse (pl_bhvr = 1 and op_bhvr = 0)
            [ ;; opponent cooperative
              ask player [ set reward reward + op_exchange ]
              ;; no load or assigned-tasks
            ]
            [ ;; both defective
              ;; zero reward, no load or assigned-tasks
            ]
          ]

        ]

        if assigned-tasks > 0 [ set time-steps-on-load time-steps-on-load + 1 ]
        set time-steps time-steps + 1
        ;      print (word "link (" [who] of end1 "-" [who] of end2 ") --> load:" load  ", total load:" load-total ", tasks:" assigned-tasks ", total tasks:" assigned-tasks-total ", time steps on load: " time-steps-on-load)
        ;      print ""
      ]
    ]
  ]

  let hshlds sort-on [who] households
  foreach hshlds [ ?1 ->
    ask ?1 [
      ;; Update utility, and behavior parameters
      let player self
;      let util utility
      set fitnessL lput precision (utility + reward) 3 fitnessL
      set utility utility + reward ; updated utility
;      print (word self "[" (length cultivating-patches) "]\tinhabitants\t" individuals "\tfitness list:\t" fitnessL "\tutility before:\t" util "\tutility after:\t" utility "\tuThres:\t" (individuals * mu) "\treward:;\t" reward "\tstorage:\t" sum storage "\tstrategy:\t" strategy)

      ask my-out-links [
        let op_bhvr 0 ; strategic behavior of opponent
        let opponent end2 ; opponent

        ask opponent [
          ;; Check opponent agent strategy
          if (strategy != 0) [
            ask my-out-links with [end2 = player] [ set op_bhvr behavior ]
            ask player [
              ;; if agent's strategy is TFT, change strategic behavior same as opponent's one
              if (strategy = 2) [ ask my-out-links with [end2 = opponent] [ set behavior op_bhvr ] ]
            ]
          ]
        ]
      ]

      ;; Update time steps in agents and their relations
      if (sum storage) = 0 AND utility < uThres
      [
        ;; Update the number of time-steps out of the total time that this relation exists that the source agent (end1) had storage level = 0 and U < uThres
        ask my-in-superiors [ set time-steps-in-lack time-steps-in-lack + 1 ]
        ask my-in-subordinates [ set time-steps-in-lack time-steps-in-lack + 1 ]
        ask my-in-peers [ set time-steps-in-lack time-steps-in-lack + 1 ]
      ]
    ]
  ]

end


;; Self-Organization behavior
to self-organization
  ;; Calculate agent emerging tasks
  ask households [

    ;; Initialize relation parameters for the current year
    ask my-in-superiors [
      set assigned-tasks 0
      set load 0
    ]
    ask my-in-peers [
      set assigned-tasks 0
      set load 0
    ]
    ask my-in-subordinates [
      set assigned-tasks 0
      set load 0
    ]

    ;; Find agents with tasks
    if utility < uThres AND sum storage > 0 [
      let dmtask (uThres - utility)
;      print (word self " Storage: " storage " Utility: " utility " uThres: " uThres " Task: " dmtask)
      let n 0
      let stopflag false ; when flag is true exit FOR loop
      foreach storage [ ?1 ->
        if stopflag = false [
          ifelse (dmtask - ?1) >= 0
          [
            set dmtask dmtask - ?1
            set storage replace-item n storage 0
            set n n + 1
          ]
          [
            set storage replace-item n storage (?1 - dmtask)
            set dmtask 0
            set stopflag true
          ]
        ]
      ]

      ; Update utility and task
      ifelse  dmtask > 0
      [ set utility uThres - dmtask ]
      [ set utility uThres ]
;      print (word self " Storage: " storage " Utility: " utility " uThres: " uThres " Task: " dmtask)
    ]
  ]

  ;; Update time steps for agents and their relations
  ask households [
    if (sum storage) = 0 AND utility < uThres
    [
      ; Update the number of time-steps out of the total time that this relation exists that the source agent (end1) had storage level = 0 and U < uThres
      ask my-in-superiors [ set time-steps-in-lack time-steps-in-lack + 1 ]
      ask my-in-subordinates [ set time-steps-in-lack time-steps-in-lack + 1 ]
      ask my-in-peers [ set time-steps-in-lack time-steps-in-lack + 1 ]
    ]
  ]

  let hshlds households ; random ordered
  ;; Enable implicit kinship or importance due to agent's history (lifetime),
  ;; so that a priority is given to older (existing) household agents in need within the community
  set hshlds sort-on [who] households

  foreach hshlds [ ?1 ->
    ask ?1 [
      ;; Find agents with tasks
;      print ""
;      print (word self " U: " utility " UT: " uThres)
;      print ""

      ;; Agents decision making: return a list [ remaining-task task-amount-agent-executed ]
      if utility < uThres [
        let dmtask (uThres - utility)
        set dmtask first decision-making dmtask self

        ;; Check if task or subtask was executed
        ifelse  dmtask > 0
        [ set utility uThres - dmtask ]
        [ set utility uThres ]
      ]

      ;; Set relation parameters for the current year
      ask my-in-superiors [
        if assigned-tasks > 0 [ set time-steps-on-load time-steps-on-load + 1 ]
        set time-steps time-steps + 1
      ]
      ask my-in-peers [
        if assigned-tasks > 0 [ set time-steps-on-load time-steps-on-load + 1 ]
        set time-steps time-steps + 1
      ]
      ask my-in-subordinates [
        if assigned-tasks > 0 [ set time-steps-on-load time-steps-on-load + 1 ]
        set time-steps time-steps + 1
      ]
    ]
  ]

end


to selection-dynamics
  ;; time rate for strategy review
  let trmod 8 ; 8 years default
  if tr = "16 years" [ set trmod 16 ]
  let minp 0
  let avgfitnesses []
  let avgfitness 0

  ;; replication dynamics
  ifelse sd != "None" [
    ifelse (sd = "Imitation within community" or sd = "Probabilistic within community") [
      ask households [
       if remainder years-settled trmod = 0 [
         let sid settlementId
         let str strategy
         let fitness last fitnessL

         ifelse (srv = "Avg reward of all strategies") [
           ask households with [settlementId = sid][ set avgfitnesses lput mean fitnessL avgfitnesses ]
         ]
         [ ;;"Avg reward of same strategy"
           ask households with [settlementId = sid and strategy = str][ set avgfitnesses lput mean fitnessL avgfitnesses ]
         ]
         set avgfitness precision mean avgfitnesses 3

         ifelse fitness - avgfitness < 0 [ ; change strategy
           ifelse (sd = "Imitation within community") [
             let crwd [] ; C strategy fitnesses
             let drwd [] ; D strategy fitnesses
             let trwd [] ; TFT strategy fitnesses
             let srwd [] ; strategies avg fitness

             ask households with [settlementId = sid and strategy = 0][ set crwd lput precision mean fitnessL 3 crwd ]
             ask households with [settlementId = sid and strategy = 1][ set drwd lput precision mean fitnessL 3 drwd ]
             ask households with [settlementId = sid and strategy = 2][ set trwd lput precision mean fitnessL 3 trwd ]
             ifelse not empty? crwd [ set srwd lput precision mean crwd 3 srwd ][ set srwd lput minp srwd ]
             ifelse not empty? drwd [ set srwd lput precision mean drwd 3 srwd ][ set srwd lput minp srwd ]
             ifelse not empty? trwd [ set srwd lput precision mean trwd 3 srwd ][ set srwd lput minp srwd ]
             let pst position (max srwd) srwd
             set strategy pst
;             print (word "Strategy review for " self ", current strategy:" str ", fitness: " precision fitness 3 ", avgfitness:" avgfitness ", strategy avg fitnesss:" srwd ", new strategy:" strategy)
           ]
           [ ;; stochastic
             let sprbs [] ; strategies frequency (percentage)
             let cagnts ( count households with [settlementId = sid and strategy = 0] / count households with [settlementId = sid] ) ; C strategic agents
             let dagnts ( count households with [settlementId = sid and strategy = 1] / count households with [settlementId = sid] ) ; D strategic agents
             let tagnts ( count households with [settlementId = sid and strategy = 2] / count households with [settlementId = sid] ) ; TFT strategic agents
             set sprbs lput precision cagnts 3 sprbs
             set sprbs lput precision dagnts 3 sprbs
             set sprbs lput precision tagnts 3 sprbs
             let cprb 0 ; cummulative probability
             let prob random-float 1
             let pst 0
             let flag true
             foreach sprbs
             [ ?1 ->
               if flag [
                 set cprb cprb + ?1
                 if prob <= cprb [
                   set pst position ?1 sprbs
                   set flag false
                 ]
               ]
             ]
             set strategy pst
;             print (word "Strategy review for " self ", current strategy:" str ", fitness: " fitness ", avgfitness:" avgfitness ", strategy probabilities:" sprbs ", new strategy:" strategy)
           ]
         ]
         [
;           print (word "Strategy review for " self ", current strategy:" str ", fitness: " fitness ", avgfitness:" avgfitness ", no need to change strategy.")
         ]
       ]
      ]
      ;; Re-initialize fitnessL and strategic behavior for the respective time window
      ask households [
        if remainder years-settled trmod = 0 [
          set fitnessL []
          ifelse strategy = 1
            [ ask my-out-links [set behavior 1] ]
            [ ask my-out-links [set behavior 0] ]
        ]
      ]
    ]
    [ ;"Imitation within society" or "Probabilistic within society"
      ask households [
       if remainder years-exist trmod = 0 [
         let str strategy
         let fitness last fitnessL

         ifelse (srv = "Avg reward of all strategies") [
           ask households [ set avgfitnesses lput mean fitnessL avgfitnesses ]
         ]
         [ ;;"Avg reward of same strategy"
           ask households with [strategy = str][ set avgfitnesses lput mean fitnessL avgfitnesses ]
         ]
         set avgfitness precision mean avgfitnesses 3

         ifelse fitness - avgfitness < 0 [ ; change strategy
           ifelse (sd = "Imitation within society") [
             let crwd [] ; C strategy fitnesses
             let drwd [] ; D strategy fitnesses
             let trwd [] ; TFT strategy fitnesses
             let srwd [] ; strategies avg fitness

             ask households with [strategy = 0][ set crwd lput precision mean fitnessL 3 crwd ]
             ask households with [strategy = 1][ set drwd lput precision mean fitnessL 3 drwd ]
             ask households with [strategy = 2][ set trwd lput precision mean fitnessL 3 trwd ]
             ifelse not empty? crwd [ set srwd lput precision mean crwd 3 srwd ][ set srwd lput minp srwd ]
             ifelse not empty? drwd [ set srwd lput precision mean drwd 3 srwd ][ set srwd lput minp srwd ]
             ifelse not empty? trwd [ set srwd lput precision mean trwd 3 srwd ][ set srwd lput minp srwd ]

             let pst position (max srwd) srwd
             set strategy pst
;             print (word "Strategy review for " self ", current strategy:" str ", fitness: " fitness ", avgfitness:" avgfitness ", strategy avg fitnesss:" srwd ", new strategy:" strategy)
           ]
           [ ;; stochastic
             let sprbs [] ; strategies frequency (percentage)
             let cagnts ( count households with [strategy = 0] / count households ) ; C strategic agents
             let dagnts ( count households with [strategy = 1] / count households ) ; D strategic agents
             let tagnts ( count households with [strategy = 2] / count households ) ; TFT strategic agents
             set sprbs lput precision cagnts 3 sprbs
             set sprbs lput precision dagnts 3 sprbs
             set sprbs lput precision tagnts 3 sprbs
             let cprb 0 ; cummulative probability
             let prob random-float 1
             let pst 0
             let flag true
             foreach sprbs
             [ ?1 ->
               if flag [
                 set cprb cprb + ?1
                 if prob <= cprb [
                   set pst position ?1 sprbs
                   set flag false
                 ]
               ]
             ]
             set strategy pst
;             print (word "Strategy review for " self ", current strategy:" str ", fitness: " fitness ", avgfitness:" avgfitness ", strategy probabilities:" sprbs ", new strategy:" strategy)
           ]
         ]
         [
;           print (word "Strategy review for " self ", current strategy:" str ", fitness: " fitness ", avgfitness:" avgfitness ", no need to change strategy.")
         ]
       ]
      ]
      ;; Re-initialize fitnessL for the respective time window
      ask households [
        if remainder years-settled trmod = 0 [
          set fitnessL []
          ifelse strategy = 1
            [ ask my-out-links [set behavior 1] ]
            [ ask my-out-links [set behavior 0] ]
        ]
      ]
    ]
  ]
  [
    ask households [ set fitnessL [] ]
  ]
end


to reorganization-adaptation
   if dm = 4 [
    ;; Agents reorganization/adaptation
    ask settlements [
;      print (word " ");
;      print (word " ");
;      print (word  "-- Reorganization/Adaptation for " self)
      ask households-list [

        ;; Check agent total load for the current time-step
        let mysps my-in-superiors
        let myprs my-in-peers
        let mysbs my-in-subordinates
        let myaqs my-in-acquaintances
;        print (word  self " Superiors: " count my-in-superiors ", Subordinates: " count my-in-subordinates ", Peers: " count my-in-peers ", Acquaintances: " count my-in-acquaintances ", TotalLoad: " precision (sum [load] of my-in-links) 2)

        ;; if agent total load is zero, check only related agents with total load greater than zero (avoid uneeded relation checks during evaluation for speedup)
        if sum [load] of my-in-links = 0 [
          set mysps my-in-superiors with [ [sum [load] of my-in-links] of end1 > 0]
          set myprs my-in-peers with [[sum [load] of my-in-links] of end1 > 0]
          set mysbs my-in-subordinates with [[sum [load] of my-in-links] of end1 > 0]
          set myaqs my-in-acquaintances with [[sum [load] of my-in-links] of end1 > 0]
;          print (word  "[Check] Superiors: " mysps ", Subordinates: " mysbs ", Peers: " myprs ", Acquaintances: " myaqs)
        ]

        ask mysps [
          ; Ax is a superior of Ay
;          print (word " ");
;          print (word  "---> " end1 " is a superior of " end2)
          let agentU []
          let rsxy rmv_auth end1 end2
          let fpxy form_peer end2 end1

          ; (i) rmv_authx,y
          set agentU lput rsxy agentU
;          print (word " -- expected utility for (i) rmv_authx,y is " last agentU)

          ; (ii) rmv_authx,y + form_peerx,y
          set agentU lput (rsxy + fpxy) agentU
;          print (word " -- expected utility for (ii) rmv_authx,y + form_peerx,y is " last agentU)

          ; (iii) no_action
          set agentU lput 0 agentU
;          print (word " -- expected utility for (iii) no_action is " last agentU)

          ; Check maximum expected utility of actions
          if max agentU > 0 [
            let pst position (max agentU) agentU
            let suprag end1
            let strgSupr [strategy] of suprag

            ; Action (i) selected
            if pst = 0 [
              ask end2 [
                let strg strategy
                ; Set new directed acquaintance relations
                create-acquaintance-to suprag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strg = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]
                create-acquaintance-from suprag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strgSupr = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                if count my-in-superiors = 1 [ set is-subordinate false ]
                ask suprag [ if count my-in-subordinates = 1 [ set is-superior false ] ]

                ; Remove subordnate directed relation 1 (rmv_authx,y)
                ask my-out-subordinates with [end2 = suprag][ die ]

                ; Set relation change + 1
                set relationChangesFromAuthToAcq (relationChangesFromAuthToAcq + 1)

              ]
              ; Remove superior directed relation 2 (rmv_authx,y)
;              type " -- Selected action (i). "
;              print (word end1 " and " end2 " are now acquaintances.")
              die
            ]
            ; Action (ii) selected
            if pst = 1 [
              ask end2 [
                let strg strategy
                ; Set new directed relations (form_peerx,y)
                create-peer-to suprag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strg = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                set is-peer true
                if count my-in-superiors = 1 [ set is-subordinate false ]

                create-peer-from suprag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strgSupr = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                ask suprag [
                  set is-peer true
                  if count my-in-subordinates = 1 [ set is-superior false ]
                ]

                ; Remove superior directed relation 1 (rmv_authx,y)
                ask my-out-subordinates with [end2 = suprag][ die ]

                ; Set relation change + 1
                set relationChangesFromAuthToPeer (relationChangesFromAuthToPeer + 1)
              ]
              ; Remove subordinate directed relation 2 (rmv_authx,y)
;              type " -- Selected action (ii). "
;              print (word end1 " and " end2 " are now peers.")
              die
            ]
          ]
        ]

        ; Check agent peers
        ask myprs [
          ; Ax is a peer of Ay
;          print (word " ");
;          print (word  "---> " end1 " is a peer of " end2)
          let agentU []
          ; (i) rmv_peerx,y
          let rpxy rmv_peer end1 end2
          set agentU lput rpxy agentU
;          print (word " -- expected utility for (i) rmv_peerx,y is " last agentU)

          ; (ii) rmv_peerx,y + form_authx,y
          let fsxy form_auth end1 end2
          set agentU lput (rpxy + fsxy) agentU
;          print (word " -- expected utility for (ii) rmv_peerx,y + form_authx,y is " last agentU)

          ; (iii) no_action
          set agentU lput 0 agentU
;          print (word " -- expected utility for (iii) no_action is " last agentU)

          ; Check maximum expected utility of actions
          if max agentU > 0 [
            let pst position (max agentU) agentU
            let peerag end1
            let strgPeer [strategy] of peerag

            ; Action (i) selected
            if pst = 0 [
              ask end2 [
                let strg strategy
                ; Set new directed acquaintance relations
                create-acquaintance-to peerag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strg = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                create-acquaintance-from peerag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strgPeer = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                if count my-in-peers = 1 [ set is-peer false ]
                ask peerag [ if count my-in-peers = 1 [ set is-peer false ] ]

                ; Remove peer directed relation 1 (rmv_peerx,y)
                ask my-out-peers with [end2 = peerag][ die ]

                ; Set relation change + 1
                set relationChangesFromPeerToAcq (relationChangesFromPeerToAcq + 1)

              ]
              ; Remove peer directed relation 2 (rmv_peery,x)
;              type " -- Selected action (i). "
;              print (word end1 " and " end2 " are now acquaintances.")
              die
            ]
            ; Action (ii) selected
            if pst = 1 [
              ask end2 [
                let strg strategy
                ; Set new directed relations (form_authx,y)
                create-superior-from peerag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strgPeer = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                set is-subordinate true

                create-subordinate-to peerag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strg = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                if count my-in-peers = 1 [ set is-peer false ]
                ask peerag [
                  set is-superior true
                  if count my-in-peers = 1 [ set is-peer false ]
                ]

                ; Remove peer directed relation 1 (rmv_peerx,y)
                ask my-out-peers with [end2 = peerag][ die ]

                ; Set relation change + 1
                set relationChangesFromPeerToAuth (relationChangesFromPeerToAuth + 1)

              ]
              ; Remove superior directed relation 2 (rmv_peerx,y)
              die
;              type " -- Selected action (ii). "
;              print (word end1 " is now a superior of " end2);
            ]
          ]
        ]

        ; Check agent subordinates
        ask mysbs [
          ; Ay is a subordinate of Ax
;          print (word " ");
;          print (word  "---> " end1 " is a subordinate of " end2)
          let agentU []
          ; (i) rmv_authx,y
          let rsxy rmv_auth end2 end1
          set agentU lput rsxy agentU
;          print (word " -- expected utility for (i) rmv_authx,y is " last agentU)

          ; (ii) rmv_authx,y + form_peerx,y
          let fpxy form_peer end2 end1
          set agentU lput (rsxy + fpxy) agentU
;          print (word " -- expected utility for (ii) rmv_authx,y + form_peerx,y is " last agentU)

          ; (iii) no_action
          set agentU lput 0 agentU
;          print (word " -- expected utility for (iii) no_action is " last agentU)

          ; Check maximum expected utility of actions
          if max agentU > 0 [
            let pst position (max agentU) agentU
            let subrag end1
            let strgSubr [strategy] of subrag

            ; Action (i) selected
            if pst = 0 [
              ask end2 [
                let strg strategy
                ; Set new directed acquaintance relations
                create-acquaintance-to subrag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strg = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]
                create-acquaintance-from subrag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strgSubr = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                if count my-in-subordinates = 1 [ set is-superior false ]
                ask subrag [ if count my-in-superiors = 1 [ set is-subordinate false ] ]

                ; Remove superior directed relation 1 (rmv_authx,y)
                ask my-out-superiors with [end2 = subrag][ die ]

                ; Set relation change + 1
                set relationChangesFromAuthToAcq (relationChangesFromAuthToAcq + 1)

              ]
              ; Remove subordinate directed relation 2 (rmv_authx,y)
;              type " -- Selected action (i). "
;              print (word end1 " and " end2 " are now acquaintances.")
              die
            ]
            ; Action (ii) selected
            if pst = 1 [
              ask end2 [
                let strg strategy
                ; Set new directed relations (form_peerx,y)
                create-peer-to subrag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strg = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                set is-peer true
                if count my-in-subordinates = 1 [ set is-superior false ]

                create-peer-from subrag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strgSubr = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                ask subrag [
                  set is-peer true
                  if count my-in-superiors = 1 [ set is-subordinate false ]
                ]

                ; Remove superior directed relation 1 (rmv_authx,y)
                ask my-out-superiors with [end2 = subrag][ die ]

                ; Set relation change + 1
                set relationChangesFromAuthToPeer (relationChangesFromAuthToPeer + 1)

              ]
              ; Remove subordinate directed relation 2 (rmv_authx,y)
;              type " -- Selected action (ii). "
;              print (word end1 " and " end2 " are now peers.")
              die
            ]
          ]
        ]
        ; Check agent acquaintances
        ask myaqs [
          ; Ay is a aquaintance of Ax
;          print (word " ")
;          print (word  "---> " end1 " is a acquaintance of " end2)
          let agentU []
          ; (i) form_peerx,y
          let fpxy form_peer end2 end1
          set agentU lput fpxy agentU
;          print (word " -- expected utility for (i) form_peerx,y is " last agentU)

          ; (ii) form_authy,x
          let fsyx form_auth end1 end2
          set agentU lput fsyx agentU
;          print (word " -- expected utility for (ii) form_authy,x is " last agentU)

          ; (iii) no_action
          set agentU lput 0 agentU
;          print (word " -- expected utility for (iii) no_action is " last agentU)

          ; Check maximum expected utility of actions
          if max agentU > 0 [
            let pst position (max agentU) agentU
            let acqag end1
            let strgAcq [strategy] of acqag

            ; Action (i) selected
            if pst = 0 [
              ask end2 [
                let strg strategy
                ; Set new directed relations (form_peerx,y)
                create-peer-to acqag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strg = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                set is-peer true

                create-peer-from acqag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strgAcq = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                ask acqag [ set is-peer true ]

                ; Remove acquaintance directed relation 1 (form_peerx,y)
                ask my-out-acquaintances with [end2 = acqag][ die ]

                ; Set relation change + 1
                set relationChangesFromAcqToPeer (relationChangesFromAcqToPeer + 1)

              ]
              ; Remove acquaintance directed relation 2 (form_peerx,y)
;              type " -- Selected action (i). "
;              print (word end1 " and " end2 " are now peers.")
              die
            ]
            ; Action (ii) selected
            if pst = 1 [
              ask end2 [
                let strg strategy
                ; Set new directed relations (form_authy,x)
                create-subordinate-to acqag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strg = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                set is-superior true

                create-superior-from acqag [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strgAcq = 1)
                  [ set behavior 1 ]
                  [ set behavior 0]
                ]

                ask acqag [ set is-superior true ]

                ; Remove acquaintance directed relation 1 (form_authy,x)
                ask my-out-acquaintances with [end2 = acqag][ die ]

                ; Set relation change + 1
                set relationChangesFromAcqToAuth (relationChangesFromAcqToAuth + 1)

              ]
              ; Remove acquaintance directed relation 2 (form_authx,y)
;              type " -- Selected action (ii). "
;              print (word end1 " is now a superior of " end2)
              die
            ]
          ]
        ]
      ]
    ]
  ]
end


;; Self-organization: Adaptation/Re-organization attribute function for the action of forming a subordinate relation
to-report form_peer [ ax ay ]
  let V -1 ; value function initialization
  let lx 0 ; load of ax
  let ly 0 ; load of ay
  let tx 0 ; tasks assigned to ax
  let ty 0 ; tasks assigned to ay

  ;; Set load/task for ax
  ask ax [
    ;; Check superiors
    ask my-in-superiors [ set lx lx + load set tx tx + assigned-tasks ]
    ;; Check peers
    ask my-in-peers [ set lx lx + load set tx tx + assigned-tasks ]
    ;; Check subordinates
    ask my-in-subordinates [ set lx lx + load set tx tx + assigned-tasks ]
  ]
;  type (word ax " load: " lx " assigned-tasks: " tx " -- ")

  ;; Set load/task for ay
  ask ay [
    ;; Check superiors
    ask my-in-superiors [ set ly ly + load set ty ty + assigned-tasks ]
    ;; Check peers
    ask my-in-peers [ set ly ly + load set tx ty + assigned-tasks ]
    ;; Check subordinates
    ask my-in-subordinates [ set ly ly + load set ty ty + assigned-tasks ]
  ]
;  type (word ay " load: " ly " assigned-tasks: " ty " -- ")

  let ltlist []
  set ltlist lput lx ltlist
  set ltlist lput ly ltlist

  if max ltlist != 0 [ set V rdL - (abs (first ltlist - last ltlist) / max ltlist ) ]
;  print (word " V: " V)
  report V
end


;; Self-organization: Adaptation/Re-organization attribute function for the action of removing a subordinate relation
to-report rmv_peer [ ax ay ]
  let V -1 ; value function initialization
  let lx 0 ; load of ax
  let ly 0 ; load of ay
  let tx 0 ; tasks assigned to ax
  let ty 0 ; tasks assigned to ay

  ;; Set load/task for ax
  ask ax [
    ;; Check relation
    ask my-in-peers with [ end1 = ay][ set lx load set tx assigned-tasks ]
  ]
;  type (word ax " load: " lx " assigned-tasks: " tx " -- ")

  ;; Set load/task for ay
  ask ay [
    ;; Check relation
    ask my-in-peers with [ end1 = ax][ set ly load set ty assigned-tasks ]
  ]
;  type (word ay " load: " ly " assigned-tasks: " ty " -- ")

  let ltlist []
  set ltlist lput lx ltlist
  set ltlist lput ly ltlist

  if max ltlist != 0 [ set V (abs (first ltlist - last ltlist) / max ltlist ) - rdL ]
;  print (word " V: " V)
  report V
end


;; Self-organization: Adaptation/Re-organization attribute function for the action of forming a subordinate relation
to-report form_auth [ ax ay ]
  let V -1 ; value function initialization
  let lx 0 ; load of ax
  let ly 0 ; load of ay
  let tx 0 ; tasks assigned to ax
  let ty 0 ; tasks assigned to ay

  ;; Set load/task for ax
  ask ax [
    ;; Check superiors
    ask my-in-superiors [ set lx lx + load set tx tx + assigned-tasks ]
    ;; Check peers
    ask my-in-peers [ set lx lx + load set tx tx + assigned-tasks ]
    ;; Check subordinates
    ask my-in-subordinates [ set lx lx + load set tx tx + assigned-tasks ]
  ]
;  type (word ax " load: " lx " assigned-tasks: " tx " -- ")

  ;; Set load/task for ay
  ask ay [
    ;; Check superiors
    ask my-in-superiors [ set ly ly + load set ty ty + assigned-tasks ]
    ;; Check peers
    ask my-in-peers [ set ly ly + load set tx ty + assigned-tasks ]
    ;; Check subordinates
    ask my-in-subordinates [ set ly ly + load set ty ty + assigned-tasks ]
  ]
;  type (word ay " load: " ly " assigned-tasks: " ty " -- ")

  let ltlist []
  set ltlist lput lx ltlist
  set ltlist lput ly ltlist

  if max ltlist != 0 [ set V (abs (first ltlist - last ltlist) / max ltlist ) - rdL ]
;  print (word " V: " V)
  report V
end


;; Self-organization: Adaptation/Re-organization attribute function for the action of removing a subordinate relation
to-report rmv_auth [ ax ay ]
  let V -1 ; value function initialization
  let lx 0 ; load of ax
  let ly 0 ; load of ay
  let tx 0 ; tasks assigned to ax
  let ty 0 ; tasks assigned to ay

  ;; Set load/task for ax
  ask ax [
    ;; Check relation
    ask my-in-subordinates with [ end1 = ay][ set lx load set tx assigned-tasks ]
  ]
;  type (word ax " load: " lx " assigned-tasks: " tx " -- ")

  ;; Set load/task for ay
  ask ay [
    ;; Check relation
    ask my-in-superiors with [ end1 = ax][ set ly load set ty assigned-tasks ]
  ]
;  type (word ay " load: " ly " assigned-tasks: " ty " -- ")

  let ltlist []
  set ltlist lput lx ltlist
  set ltlist lput ly ltlist

  if max ltlist != 0 [ set V rdL - (abs (first ltlist - last ltlist) ) / max ltlist ]
;  print (word " V: " V)
  report V
end


;; Self-organization: Agent decision making
to-report decision-making [ tsk agnt ]
  ;; Check if agent is capable of the task or subtask
  ;; Set result list
  let outputList []
  let origTsk tsk

  ask agnt [
    ;; Print agent state
;    print (word agnt " Storage: " storage " Task: " tsk)

    if (sum storage) > 0 [; agent is capable of the task or subtask
      let n 0
      let stopflag false ; when flag is true exit FOR loop
      foreach storage [ ?1 ->
        if stopflag = false [
          ifelse (tsk - ?1) >= 0
          [
            set tsk tsk - ?1
            set storage replace-item n storage 0
            set n n + 1
          ]
          [
            set storage replace-item n storage (?1 - tsk)
            set tsk 0
            set stopflag true
          ]
;          print (word agnt " Storage: " storage " Task: " tsk)
        ]
      ]
    ]

    set outputList fput (origTsk - tsk) outputList ; insert task resource amount that agent executed
    let capableAgents n-of 0 households ; empty agentset

    ;; Check capable superiors
    if tsk > 0
    [
      ask my-in-superiors [
;        print (word myself " superior: " end1 " Storage: " (sum [storage] of end1))
        ask end1 [
          if sum storage > 0 [
            set capableAgents (turtle-set capableAgents self)
;            print (word agnt " Capable superior: " self)
          ]
        ]
      ]

      if any? capableAgents [
        let stopflag false
        ask capableAgents [
;          let cbla self
          ; Recheck agent for capability due to recursion process
          if sum storage > 0 [
            if stopflag = false [
              ; Recursively make decision
              let resTsk []
              set resTsk decision-making tsk self
              let supld last resTsk

              ;; Set agents relation parameters
              if first resTsk != tsk [
;                ask agnt [
                  ask my-in-subordinates with [end1 = agnt][
                    set assigned-tasks assigned-tasks + 1
                    set load load + supld
                    set assigned-tasks-total assigned-tasks-total + 1
                    set load-total load-total + supld
;                    print (word end1 " subordinate of " end2 " asssigned task of load: " supld " loadTotal: " load)
                  ]
;                ]
              ]

              ;; Check if whole task or subtask was executed
              ifelse first resTsk > 0
              [
                ;; Agent executed subtask
                set capableAgents capableAgents with [self != myself] ; remove agent from agentset
              ;  print (word self " superior agent allocated and executed task of resource amount " supld)
              ]
              [
                ;; Agent executed the whole task
              ;  print (word self " superior agent allocated and executed task of resource amount " last resTsk)
                set stopflag true
              ]
              ;; Update current task amount
              set tsk first resTsk
            ]
          ]
        ]
      ]
    ]

    ;; Check capable peers
    if tsk > 0
    [
      ask my-in-peers [
;        print (word myself " Peer: " end1 " Storage: " (sum [storage] of end1))
        ask end1 [
          if sum storage > 0 [
            set capableAgents (turtle-set capableAgents self)
;            print (word agnt " Capable peer: " self)
          ]
        ]
      ]

      if any? capableAgents [
        let stopflag false
        ask capableAgents [
;          let cbla self
          ;; Recheck agent for capability due to recursion process
          if sum storage > 0 [
            if stopflag = false [
              ; Recursively make decision
              let resTsk []
              set resTsk decision-making tsk self
              let perld last resTsk

              ;; Set agents relation parameters
              if first resTsk != tsk [
;                ask agnt [
                  ask my-in-peers with [end1 = agnt][
                    set assigned-tasks assigned-tasks + 1
                    set load load + perld
                    set assigned-tasks-total assigned-tasks-total + 1
                    set load-total load-total + perld
;                    print (word end1 " peer of " end2 " asssigned task of load: " perld " loadTotal: " load)
                  ]
;                ]
              ]

              ;; Check if whole task or subtask was executed
              ifelse first resTsk > 0
              [
                ;; Agent executed subtask
                set capableAgents capableAgents with [self != myself] ; remove agent from agentset
              ;  print (word self " peer agent allocated and executed task of resource amount " perld)
              ]
              [
                ;; Agent executed the whole task
              ;  print (word self " peer agent allocated and executed task of resource amount " last resTsk)
                set stopflag true
              ]
              ;; Update current task amount
              set tsk first resTsk
            ]
          ]
        ]
      ]
    ]

    ;; Check capable subordinates
    if tsk > 0
    [
      ask my-in-subordinates [
;        print (word myself " Subordinate: " end1 " Storage: " (sum [storage] of end1))
        ask end1 [
          if sum storage > 0 [
            set capableAgents (turtle-set capableAgents self)
;            print (word agnt " Capable subordinate: " self)
          ]
        ]
      ]

      if any? capableAgents [
        let stopflag false
        ask capableAgents [
;          let cbla self
          ;; Recheck agent for capability due to recursion process
          if sum storage > 0 [
            if stopflag = false [
              ; Recursively make decision
              let resTsk []
              set resTsk decision-making tsk self
              let subld last resTsk

              ;; Set agents relation parameters
              if first resTsk != tsk [
;                ask agnt [
                  ask my-in-superiors with [end1 = agnt][
                    set assigned-tasks assigned-tasks + 1
                    set load load + subld
                    set assigned-tasks-total assigned-tasks-total + 1
                    set load-total load-total + subld
;                    print (word end1 " superior of " end2 " asssigned task of load: " subld " loadTotal: " load)
                  ]
;                ]
              ]

              ;; Check if whole task or subtask was executed
              ifelse first resTsk > 0
              [
                ;; Agent executed subtask
                set capableAgents capableAgents with [self != myself] ; remove agent from agentset
              ;  print (word self " subordinate agent allocated and executed task of resource amount " subld)
              ]
              [
                ;; Agent executed the whole task
              ;  print (word self " subordinate agent allocated and executed task of resource amount " last resTsk)
                set stopflag true
              ]
              ; Update current task amount
              set tsk first resTsk
            ]
          ]
        ]
      ]
    ]


    ;; Check capable acquaintances
    if tsk > 0
    [
      ask my-in-acquaintances [
        ;        print (word myself " Acquaintant: " end1 " Storage: " (sum [storage] of end1))
        ask end1 [
          if sum storage > 0 [
            set capableAgents (turtle-set capableAgents self)
;            print (word agnt " Capable acquaintant: " self)
          ]
        ]
      ]

      if any? capableAgents [
        let stopflag false
        ask capableAgents [
;          let cbla self
          ;; Recheck agent for capability due to recursion process
          if sum storage > 0 [
            if stopflag = false [
              ;; Form superior relation with agent in need
              create-superior-to agnt [
                set time-steps 0
                set time-steps-in-lack 0
                set time-steps-on-load 0
                set assigned-tasks 0
                set load 0
                set assigned-tasks-total 0
                set load-total 0
                set hidden? true
              ]
              ;; Form subordinate relation with acquaintance agent
              create-subordinate-from agnt [
                set time-steps 0
                set time-steps-in-lack 0
                set time-steps-on-load 0
                set assigned-tasks 0
                set load 0
                set assigned-tasks-total 0
                set load-total 0
                set hidden? true
              ]
              set relationChangesFromAcqToAuth (relationChangesFromAcqToAuth + 1)

              ;; Remove acquaintant relation
              ask my-in-acquaintances with [end1 = agnt][ die ]
              ask my-out-acquaintances with [end2 = agnt][ die ]


              ;; Recursively make decision
              let resTsk []
              set resTsk decision-making tsk self
              let supld last resTsk

              ;; Set agents relation parameters
              if first resTsk != tsk [
                  ask my-in-subordinates with [end1 = agnt][
                    set assigned-tasks assigned-tasks + 1
                    set load load + supld
                    set assigned-tasks-total assigned-tasks-total + 1
                    set load-total load-total + supld
;                    print (word end1 " (new) subordinate of " end2 " asssigned task of load: " supld " loadTotal: " load)
                  ]
                  ask agnt [ set is-subordinate true ]
                set is-superior true
              ]

              ;; Check if whole task or subtask was executed
              ifelse first resTsk > 0
              [
                ;; Agent executed subtask
              ;  print (word self " acquaintance agent (new superior) allocated and executed task of resource amount " supld)
              ]
              [
                ;; Agent executed the whole task
              ;  print (word self " acquaintance agent (new superior) allocated and executed task of resource amount " last resTsk)
                set stopflag true
              ]
              ;; Update current task amount
              set tsk first resTsk
            ]
          ]
        ]
      ]
    ]
  ]
  set outputList fput tsk outputList ; insert remaining task resource amount that agent could not allocate and execute
  report outputList
end


to share-resources
  ;; Calculate current year resources for each settlement
  ask settlements [
    let pool 0
    ask households-list [
      set pool pool + utility
      set utility 0
    ]

    ;; Distribute harvested resources based on the number of inhabitants in the community
    if dm = 2 [ ; "Egalitarian"
      let shAmount pool / population-size
      ask households-list [
        set utility utility + (individuals * shAmount)
      ]
    ]

    ;; Distribute harvested resources based on the number of households in the community (irrespective of household size)
    if dm = 3 [ ; "Sharing"
      ;; Distribute harvested resources equally among them
      let setlhhs count households-list
      ask households-list [
        set utility (pool / setlhhs)
      ]
    ]

  ]
end


to-report mdp-create-action-state-space [mn es nes hp cst stspc sts]
  ;; Create state-action space:
  ;; mn = maximum naumber of representing states per elevation state patches, es = starting elevetion state, nes = ending elevetion state (not included in calculation)
  ;; hp = number of "migration radius" distance hops away from current location, cst = current location state
  ;; stspc = state space of corresponding elevetion state (es), sts = total states (space) of corresponding hop (per elevation level)

  while [es != nes][
    let prob 1 ;.95
    let cn 0
;    type (word "Elevation states: " es "-" (nes - 1) " hop: " hp " prv loc: " cst " statespace: " stspc)
    let sttemp sort-on [(- avg-agricultural-production)] stspc with [elevation-state = es]
    ifelse not empty? sttemp [
      ;; mn maximum expected reward states
      let mers mn
      if mers > length sttemp [set mers length sttemp]
;      type (word "   ### Creating states: ")
      while [cn != mers] [
        ask (patch-set item 0 sttemp) [
          sprout-states 1 [
            set hop hp
            set class [elevation-state] of patch-here
            set stages []
            let aer [avg-agricultural-production] of patch-here

            create-action-from cst [
;              set R (aer + .001 * aer) * yos ; expected reward for yos years and rbirth - rdeath = 0.001 population growth
              set R aer
              set Pr prob
            ]
            set sts (patch-set sts patch-here)
;            type (word who " (" (aer * prob) "), ")
          ]
          set prob .025
          set cn cn + 1
          set sttemp remove-item 0 sttemp
        ]
      ]
    ]
    [
;      type (word "   ### NO available patches, ")
    ]
;    type (word "DONE. ###   ")
    set es es + 1
;    print (word " states:" sts)


  ]
  report sts
end


to-report mdp-policy [ agent mgr-cand-patches]

  let migrate-location no-patches

  ask agent [

    ;; if migration policy sequence not empty then follow the next state (location)
    ifelse (not empty? migration-patches) [
      set migrate-location item 0 migration-patches
      set migration-patches remove-item 0 migration-patches
    ]
    [ ;; Create an MDP of 3 stages-to-go for calculating optimal migration policy
      ;; Action-state space creation
      ask patch-here [

        let prvstate no-turtles
        sprout-states 1 [
          set hop 0
          set class [elevation-state] of patch-here
          set prvstate self
          set stages []
        ]

        ;; 3 hops (migration radius) in the MDP
        let states1 no-patches
        let states2 no-patches
        let states3 no-patches
;        let goalstates no-patches ; i.e. hop 4

        let stspace no-patches

        let stspace1 mgr-cand-patches in-radius (mr * 100 * cell-size)
        set stspace stspace1
;        print (word "Candidate states within migration radius: " count stspace1 " patches.")
;        ask stspace1 [
;          if (elevation-state = 0) [ set pcolor 74 ]
;          if (elevation-state = 1) [ set pcolor 76 ]
;          if (elevation-state >= 2) [ set pcolor 78 ]
;        ]

;        print (word "States in 1st hop...")

        if (elevation-state = 0) [ ; elevation level is low (0), thus, can transit to low (0) or medium (1)
          set states1 mdp-create-action-state-space 1 0 2 1 prvstate stspace1 states1
        ]

        if (elevation-state = 1) [ ; elevation level is medium (1), thus, can transit to low (0), medium (1) or high (2)
          set states1 mdp-create-action-state-space 1 0 3 1 prvstate stspace1 states1
        ]

        if (elevation-state = 2) [ ; elevation level is high (2), thus, can transit to medium (1) or high (2)
          set states1 mdp-create-action-state-space 1 1 3 1 prvstate stspace1 states1
        ]

;        print (word "States in 2nd hop...")

        ask states1 [
          set prvstate one-of states-here ; since it is only one

          let stspace2 mgr-cand-patches in-radius (mr * 100 * cell-size) with [not member? self stspace]
;          ask stspace2 [
;            if (elevation-state = 0) [ set pcolor 84 ]
;            if (elevation-state = 1) [ set pcolor 86 ]
;            if (elevation-state >= 2) [ set pcolor 88 ]
;          ]

          if (elevation-state = 0) [ ; elevation level is low (0), thus, can transit to low (0) or medium (1)
            set states2 mdp-create-action-state-space 1 0 2 2 prvstate stspace2 states2
          ]

          if (elevation-state = 1) [ ; elevation level is medium (1), thus, can transit to low (0), medium (1) or high (2)
            set states2 mdp-create-action-state-space 1 0 3 2 prvstate stspace2 states2
          ]

          if (elevation-state = 2) [ ; elevation level is high (2), thus, can transit to medium (1) or high (2)
            set states2 mdp-create-action-state-space 1 1 3 2 prvstate stspace2 states2
          ]
          set stspace (patch-set stspace stspace2)
        ]

;        print (word "States in 3rd hop...")

        ask states2 [

          set prvstate one-of states-here

          let stspace3 mgr-cand-patches in-radius (mr * 100 * cell-size) with [not member? self stspace]
;          ask stspace3 [
;            if (elevation-state = 0) [ set pcolor 94 ]
;            if (elevation-state = 1) [ set pcolor 96 ]
;            if (elevation-state >= 2) [ set pcolor 98 ]
;          ]

          if (elevation-state = 0) [ ; elevation level is low (0), thus, can transit to low (0) or medium (1)
            set states3 mdp-create-action-state-space 1 0 2 3 prvstate stspace3 states3
          ]

          if (elevation-state = 1) [ ; elevation level is medium (0), thus, can transit to low (0), medium (1) or high (2)
            set states3 mdp-create-action-state-space 1 0 3 3 prvstate stspace3 states3
          ]

          if (elevation-state = 2) [ ; elevation level is high (2), thus, can transit to medium (1) or high (2)
            set states3 mdp-create-action-state-space 1 1 3 3 prvstate stspace3 states3
          ]
          set stspace (patch-set stspace stspace3)
        ]

        let pstates (patch-set states1 states2 states3)
;        ask pstates [set pcolor 14]
;        ask actions [set color 3 set hidden? false]
;        set pcolor 45
;        print (word "Number of states: " count pstates)

        set nomdps nomdps + 1 ; munber of mdps run at every time-step
        set nosts nosts + count pstates  ; number of states at every time-step

      ]

      ;; Solve the MDP and assing the optimal migration policy for the agent (3-hop states)
      set migration-patches mdp-value-iteration

;      ask states with [hop = 4][ set color [pcolor] of patch-here ;]
;      print (word "Total time elapsed: " round (timer) " sec.")
      ask states [die] ; actions die along with states

      set migrate-location item 0 migration-patches
      set migration-patches remove-item 0 migration-patches
    ]
  ]

  report migrate-location

end


to-report mdp-value-iteration
  ;; Deterministic state transitions with finite horizon of stages k = 3
  ;; All terminal states (k-steps-to-go) have (already) V0(s,a) = 0
  ask states [ ; k = 0
    set stages lput 0 stages

;    ifelse hop = 0 [
;      set color yellow
;    ]
;    [ set color red ]
;    set size 3
;    set shape "circle"
  ]

  let k 1 ;; k-stages-to-go
  while [k < 4][ ; up to 3 stages
    ask states [

      ; initialize Q*sa for all aεΑ, maximum of 3 different (elevation) actions, i.e.  migration, plus 1 of self-transition, i.e. settlement
      let Q*sa [0 0 0 0]
      let clstate class

      ask my-out-actions [
        let Prsas' Pr
        let Rsas' R
        ask end2 [ ; Set Q*k(s,a) of (migration) actions per state class
          let V*k-1s' item (k - 1) stages
          if class = 0 [ set Q*sa replace-item 0 Q*sa (item 0 Q*sa + Prsas' * ( Rsas' + V*k-1s')) ] ; sum
          if class = 1 [ set Q*sa replace-item 1 Q*sa (item 1 Q*sa + Prsas' * ( Rsas' + V*k-1s')) ] ; sum
          if class = 2 [ set Q*sa replace-item 2 Q*sa (item 2 Q*sa + Prsas' * ( Rsas' + V*k-1s')) ] ; sum
        ]
      ]

      ;; Add self-transition (settlement) action to Q*sa
      let V*s' item (k - 1) stages
      let Prself 1
      let Rw [avg-agricultural-production] of patch-here
;      set Rw (Rw + .001 * Rw) * yos ; expected reward for yos years and rbirth - rdeath = 0.001 population growth
      set Q*sa replace-item 3 Q*sa (Prself * (Rw + V*s'))

      ;; "backup" (store) state's optimal value
      set V*s max Q*sa
      set stages lput V*s stages
;      print (word "State (" who ")\thop = " hop "\tk = " k "\tV*' = " V*s)
    ]
    set k k + 1
  ]


  ;; Find optimal migration policy for agent
;  foreach sort states [
;    ask ? [
;      set label who
;      set label-color black
;      set color red
;;      print (word "State (" who ")\thop = " hop "\tV*' = " int (item 3 stages))
;    ]
;  ]

  ;; Store optimal migration policy for agent
  let mp []
  ask states with [hop = 0 ][

;    set color yellow

    let states1 (turtle-set self [end2] of my-out-links)
    let st1 max-one-of states1 [V*s]
;    ask my-out-links with [end2 = st1][set color black]

    ask st1 [ ; hop = 1
;      set color 69
      set mp lput patch-here mp
      let states2 (turtle-set self [end2] of my-out-links)
      let st2 max-one-of states2 [V*s]
;      ask my-out-links with [end2 = st2][set color black]

      ask st2 [ ; hop = 2
;        set color 69
        set mp lput patch-here mp
        let states3 (turtle-set self [end2] of my-out-links)
        let st3 max-one-of states3 [V*s]
;        ask my-out-links with [end2 = st3][set color black]

        ask st3 [ ; hop = 3
;          set color 69
          set mp lput patch-here mp
        ]
      ]
    ]
  ]

;  type (word "Optimal policy states are: ")
;  foreach mp [ ask ? [ type (word "(State "[who] of states-here ") ") ] ]
;  print ""

  set migration-patches mp

  ;; Output optimal policy π(V)* for the agent
  report mp
end


to consider-migration
  let migrations-now 0
  let migration-candidate-patches land-patches

  ;; Set candidate migration locations to known habitation sites by archaeological survey/evidence,
  ;; if settlements were not randomly initialized in the modeling area.
  if (ris = false) [ set migration-candidate-patches land-patches with [has-site = true] ]

  ask migration-candidate-patches [ set is-checked false ]
  ask migration-candidate-patches [
    ;; We assume an area of 2 hectares (cells) radius between new settlements
    if (has-settlement = true) [
      ask land-patches in-radius 3 [ set is-checked true ] ;; When is-checked is true, the location is not available for migration
    ]
    ;; Otherwise the agent may migrate to the respective settlement
    if (has-settlement = true AND is-cultivated = true) [ set is-cultivated false ]
    if (has-settlement = true) [ set is-checked false ]
  ]

  let mgh count households with [migrate = true]
;  if (mgh > 0) [ type (word "Year " (3200 - ticks) " BCE: " mgh " household agents considers migrating with U = " [utility] of households with [migrate = true] " and Uthres = " [uThres] of households with [migrate = true] ", where only ") ]

  ask households with [migrate = true] [
;    type (word self " (settlement " sid ") considers migrating...")

    let ch self
    let hindivs individuals
    let sid settlementId
    let cph sensory-range
    set migrate false
    set migration-candidate-patches migration-candidate-patches with [is-cultivated = false AND is-checked = false]

    let lcp 1
    if (length cultivating-patches > 1) [ set lcp length cultivating-patches ]

    ;; Household's current utility from cultivating the lands, normalized per cultivating cell
    let cau int (utility / lcp)

    ;; Set expected utility for each of the candidate migration patches
    ask migration-candidate-patches [
      ifelse is-ts-affected or is-va-affected ;; Check if the natural disaster model is enabled
      [ set agricultural-production resources ]
      [ set agricultural-production int (land-suitability * ( (((2 * sr * land-productivity) - (4 * sr)) / (mnoipc ^ 2)) * hindivs ^ 2 + ((((4 * sr) - 3 * sr * land-productivity)) / (mnoipc)) * hindivs +  sr * land-productivity) ) ]
    ]

    ;; Check if aquifer proximity on migration is enabled
    if ap? [ ask migration-candidate-patches [set avg-agricultural-production (avg-agricultural-production * aquifer-utility)] ]

    ;; Check if resettling cost is enabled.
    ;; Ressetling cost is modeled as a decay of the expected utility of the migrate location with increasing distance.
    ;; The distance needs to be in km, thus is divided by 10, sicne 1 hectare cell is .1 km.
    ;; Migration distance is also multiplied by .005 so as to model a cost in the expected utility of about 20% of resources at a migrate location 40km away.
    if rc? [ ask migration-candidate-patches [set agricultural-production agricultural-production * (exp (- ((distance ch) / 10) * .005))] ]

    ;; Set expected utility for any of the candidate cells as the average of its neighbors
    ask migration-candidate-patches [
      set avg-agricultural-production int (mean [agricultural-production] of neighbors)
    ]

    ;; Consider also migrating to another settlement
    let migration-settlements (settlements-on migration-candidate-patches) with [count households-list > 0]
    ask migration-settlements with [who != sid] [
      let estutil 0
;      print (word "Candidate migration settlement " self "[" count households-list "] in " patch-here)
      ask households-list [
        ; Calculate average utility per cell for a household agent
        set estutil estutil + (utility / sensory-range)
      ]
      ; Set expected utility for a settlement location as the average utility of household agents within
      set estutil int (estutil / count households-list)

      ask patch-here [
        set avg-agricultural-production estutil
      ]
    ]

    let mpatch max-one-of migration-candidate-patches [avg-agricultural-production]
    let mpx round (max-pxcor * cell-size) ; width of the environmental grid in cells
    let mpy round (max-pycor * cell-size) ; height of the environmental grid in cells

    if (mr < (max list mpx mpy)) ;; Check if household agent enviromental view (perception) is less than the full environmental area
    [set mpatch  max-one-of migration-candidate-patches in-radius (mr * 100 * cell-size) [avg-agricultural-production] ]

    if (mdp) [
      let mcpatches no-patches
      let prvpatches no-patches ; do not include previous location pacthes
      ifelse previous-location != nobody [
        ask previous-location [ set prvpatches land-patches in-radius (mr * 100 * cell-size) ]
        ; candidate (migration) cells within migration radius
        set mcpatches migration-candidate-patches in-radius (mr * 100 * cell-size) with [not member? self prvpatches]
      ]
      [ set mcpatches migration-candidate-patches in-radius (mr * 100 * cell-size) ]

      let cpatches no-patches ; candidate (migration) cells per elevation (state) area. low = 0, middle = 1, high = 2
      ask patch-here [
        if (elevation-state = 0) [ set cpatches (patch-set max-one-of mcpatches with [elevation-state = 0][avg-agricultural-production] max-one-of mcpatches with [elevation-state = 1][avg-agricultural-production]) ]
        if (elevation-state = 1) [ set cpatches (patch-set max-one-of mcpatches with [elevation-state = 0][avg-agricultural-production] max-one-of mcpatches with [elevation-state = 1][avg-agricultural-production] max-one-of mcpatches with [elevation-state = 2][avg-agricultural-production]) ]
        if (elevation-state = 2) [ set cpatches (patch-set max-one-of mcpatches with [elevation-state = 1][avg-agricultural-production] max-one-of mcpatches with [elevation-state = 2][avg-agricultural-production]) ]
      ]

      set mpatch max-one-of cpatches [avg-agricultural-production]
      ;    print (word "Best Migration patch for " ch " (patch " [xcor] of self " " [ycor] of self "), U: " cau " is " mpatch ", U: " [avg-agricultural-production] of mpatch)
    ]

    ;; Agent migration plan (create and solve MDP)
    if (mdp) [ set mpatch mdp-policy self  migration-candidate-patches ]

    if ([avg-agricultural-production] of mpatch > cau AND mpatch != patch-here AND mpatch != nobody) [ ;; Ready to migrate
;    if (mpatch != patch-here and mpatch != nobody) [ ;; Ready to migrate
      print (word self " considering migation to " mpatch " from " patch-here)

      ;; Check if Self-Organization
;        if (dm = "Self-Organization")[
      if (dm > 3) [
        ;; Remove Relationships
        ask my-in-superiors [die]
        ask my-in-subordinates [die]
        ask my-in-peers [die]
        ask my-in-acquaintances [die]
        ask my-out-superiors [die]
        ask my-out-subordinates [die]
        ask my-out-peers [die]
        ask my-out-acquaintances [die]
        set is-superior false
        set is-subordinate false
        set is-peer false
      ]

      set migrations-now migrations-now + 1
      set previous-location patch-here

      let msid sid
      let mph one-of households-on mpatch
      if mph != nobody [ ask mph [ set msid settlementId ] ]
      move-to mpatch

      set years-settled 0
      set years-to-migrate 0

      ;; Change id of household
      hatch 1 [
        let chn self
        ;; fitness list is re-initialized for the new settlement game
        if egt [ set fitnessL [] ]

        ;; Consider the new location if it is has a settlement
        ifelse ([has-settlement] of mpatch = true AND count households-on mpatch > 1) [
          ;; Update settlement
          set settlementId msid
          ask settlement msid [
            ;; Update population
            set population-size (population-size + hindivs)
            ;; Update households-list
            set households-list households with [ settlementId = msid ]
            set households-cnt count households-list
            print (word ch " [" [individuals] of ch "]["sid"] migrated to (settlement " msid ") [" population-size "] with new household id: " [who] of chn)
          ]

          ;; Check location for number of households restriction
          if (sum [individuals] of households-on mpatch) > mnoipc [
            ;; Move migrating household agent to a neighbor cell
            let mp patch-here
            ask mpatch [
              set mp min-one-of land-patches with [(sum [individuals] of households-here) < mnoipc] [distance myself]
;              set mp max-one-of neighbors with [ (sum [individuals] of households-here) < mnoipc ][(sum [individuals] of households-here)]
            ]
            move-to mp
            set mpatch mp
            ask mpatch [
              set has-settlement true
              set is-cultivated false
              set is-checked false
              set site-id msid
            ]
          ]

          ;; Set relationships for self-organization
;            if (dm = "Self-Organization")[
          if (dm > 3)[
            let isb false
;              let ipr false


            ;; Find superior agents in settlement cell
            let setlmnt-superiors n-of 0 households ; empty agentset
;              let setlmnt-subordinates n-of 0 households
            let setlmnt-rest n-of 0 households
;            ask settlements with [who = msid] [
;            ask settlements-on mpatch [
              set setlmnt-superiors households-here with [is-superior = true AND who != [who] of chn];
              set setlmnt-rest households-here with [ not member? self setlmnt-superiors AND who != [who] of chn]
;              set setlmnt-superiors households-list with [is-superior = true AND who != [who] of chn]
;              set setlmnt-rest households-list with [ not member? self setlmnt-superiors AND who != [who] of chn]
;            ]

            let agntStg [strategy] of chn

            ;; Create subordinate relation with superior agents
            ask setlmnt-superiors [
              let strg strategy
              create-superior-to chn [
                set time-steps 0
                set time-steps-in-lack 0
                set time-steps-on-load 0
                set assigned-tasks 0
                set load 0
                set assigned-tasks-total 0
                set load-total 0
                set hidden? true
                ifelse (strg = 1)
                [ set behavior 1 ]
                [ set behavior 0 ]
              ]

              create-subordinate-from chn [
                set time-steps 0
                set time-steps-in-lack 0
                set time-steps-on-load 0
                set assigned-tasks 0
                set load 0
                set assigned-tasks-total 0
                set load-total 0
                set hidden? true
                ifelse (agntStg = 1)
                [ set behavior 1 ]
                [ set behavior 0 ]
              ]
              set isb true
            ]

            ifelse dm = 5 [
              ;; Create peer relation with all the other agents in settlement cell
              ask setlmnt-rest [
                let strg strategy
                create-peer-from chn [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (agntStg = 1)
                  [ set behavior 1 ]
                  [ set behavior 0 ]
                ]

                create-peer-to chn [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strg = 1)
                  [ set behavior 1 ]
                  [ set behavior 0 ]
                ]
                set is-peer true
              ]
              set is-peer true
            ]
            [
              ;; Create aquaintance relation with all the other agents in the settlement
              ask setlmnt-rest [
                let strg strategy
                create-acquaintance-from chn [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (agntStg = 1)
                  [ set behavior 1 ]
                  [ set behavior 0 ]
                ]

                create-acquaintance-to chn [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set hidden? true
                  ifelse (strg = 1)
                  [ set behavior 1 ]
                  [ set behavior 0 ]
                ]
              ]
              set is-peer false
            ]

            set is-superior false
            set is-subordinate isb
          ]
        ]
        [
          ask mpatch [
            set has-settlement true
            set is-checked false
            set is-cultivated false
            sprout-settlements 1 [
              set msid who
              set color 135 ;yellow
              set shape "circle"
;              set size 2
;              set set hidden? true
              set years-exist 0
              set population-size hindivs
              set households-list households-here
              set households-cnt count households-list
              ask households-here [ if dm > 3 [set is-superior true ] ]
              print (word ch " [" [individuals] of ch "][" sid "] migrated to a new location (new household id: " [who] of chn "). New (settlement " who ") [" population-size "] is created.")
            ]
            set site-id msid

            ;; Define an area of 2 hectares (cells) radius for the new settlement
            ask land-patches in-radius 3 [ set is-checked true ]
          ]
          set settlementId msid
        ]
      ]

      ;; Update old settlement
      ask settlements with [who = sid] [
        ;; Update population
        set population-size (population-size - hindivs)
        set candidate-area (candidate-area - lcp)
        set households-list households with [settlementId = sid]
        set households-cnt count households-list
;        print (word self " Updated population: " population-size " without " myself)

        ifelse (count households-list > 1)
        [
          ;; Update households-list
          set households-list households with [ settlementId = sid ]
;          set households-list households in-radius 1.5 with [ settlementId = sid ]
          set households-cnt count households-list
        ]
        [
          ask patch-here [ set has-settlement false set is-cultivated false set site-id -1]
          print (word self " does not exist anymore. Last agent migrated.")
          die
        ]
      ]

      die ; remove old household, since it migrated.
    ]
  ]

  set migrations migrations-now
  set mgrtns mgrtns + migrations
end


to update-agents
;  show-elevation
  ask households [
    set uThres (individuals * mu)
    set years-to-migrate years-to-migrate + 1
    set years-settled years-settled + 1
    set years-exist years-exist + 1

    ;; Update utility and storage
    ifelse utility >= uThres
    [
      set storage lput (utility - uThres) storage
      set utility uThres
    ]
    [
      ifelse (sum storage) > 0
      [
        let rneed uThres - utility
        let n 0
        let stopflag false ; when flag is true exit FOR loop
        foreach storage [ ?1 ->
          if stopflag = false [
            ifelse (rneed - ?1) >= 0
            [
              set rneed rneed - ?1
              set storage replace-item n storage 0
              set n n + 1
            ]
            [
              set storage replace-item n storage (?1 - rneed)
              set rneed 0
              set stopflag true
            ]
          ]
        ]
        set utility uThres - rneed
      ]
      [
        ;; Agent considers migrating after Y years in a row (storage length) with U < uThres
        if years-to-migrate >= yos [
          set migrate true
          set years-to-migrate 0

          if years-settled > (2 * yos) [
           set migration-patches []
          ]

        ]
;          print (word self " considers migrating.")
      ]
      ;; No more than minimum resource required is harvested this year
      set storage lput 0 storage
    ]

    ;; Remove latest year resources
    set storage remove-item 0 storage
;    set pen-mode "down"


    if utility < uThres [ set years-in-lack years-in-lack + 1]
  ]

  ;; Recolor setllements
  ;; dark yellow:  households with avg utility < uThres
  ;; light yellow: households with avg utility >= uThres

  if sint = "Off" or (display-territories? = false and display-indg-nw? = false and display-outdg-nw? = false and display-btw-nw? = false and display-lv-con? = false) [
  ask settlements [
    set years-exist years-exist + 1
    let util []
    let utilThres []

    let alone false
    if count households-list = 1 [ set alone true ]

    ask households-list [
      if alone = true and dm > 3 [set is-superior true set is-subordinate false set is-peer false ]
      set util fput utility util
      set utilThres fput uThres utilThres

      ;; Color cultivating pathes with a shade of purple from lighter (high agent utility) to darker (low agent utility)
      foreach cultivating-patches [ ??1 -> ask ??1 [
        ifelse ([utility] of myself >= [uThres] of myself)
        [ set pcolor 135 ]
        [
          ifelse ([utility] of myself >= ([uThres] of myself / 2))
          [ set pcolor 133 ]
          [ set pcolor 131 ]
        ]
        ]
      ]
    ]

    ;; Color settlement locations with a shade of yellow from lighter (high settlement avg utility) to darker (low settlement avg utility)
    ifelse (mean util >= mean utilthres)
    [ set color 45 ]
    [
      ifelse (mean util >= (mean utilthres) / 2)
      [ set color 43 ]
      [ set color 41 ]
    ]
;    set size 3 * sqrt (candidate-area / pi)

;    set label-color white
;    set label count households-list
  ]
  ]
end


to population-dynamics
  ;; Compute population growth based on birth and death rates,
  ;; given household agent utility for the current year
  let rBirth .003 ; initialize birth rate
  let rDeath .002 ; initialize death rate

  ask settlements [
    let pop population-size
    let swho who
    let hhl households-list
    let spatch patch-here
    let dieflagSettlement false

    ;; Check households within settlements
    ask households-list [
      let dieflagHousehold false
      let parent self
      let counter 1
      let birthDeaths 0


      if (dieflagHousehold = false) [
;        print (word self " Utility: " utility " Storage: " storage " Natural growth resource: " uThres)

        if (utility = 0 and (sum storage = 0)) [
          set birthDeaths birthDeaths - 1
        ]

        while [counter != individuals] [
          ;; Check if an agent is going to die with respect to current utility
          if random-float 1.0 < rDeath [ set birthDeaths birthDeaths - 1 ]

          ;; Check if an agent is going to be borned
          if random-float 1.0 < rBirth * ( utility / uThres ) [ set birthDeaths birthDeaths + 1 ]

          set counter counter + 1
        ]

        ;; Check if an inhabitant is ONLY going to die
        while [birthDeaths < 0] [
          ;; Check individuals.
          ifelse (individuals + birthDeaths) > 0 [
            set pop (pop - 1)
            set individuals individuals - 1
            set birthDeaths birthDeaths + 1
              print (word "(settlement " swho ") [" pop "]: " self " [" individuals "]: " "inhabitant died.")
          ]
          [
            set dieFlagHousehold true
            set pop (pop - individuals)
            set birthDeaths 0
              print (word "(settlement " swho ") [" pop "]: " self ": " "Household agent died.")
          ]
        ]

        ;; Check if an agent is only going to be borned
        while [birthDeaths > 0] [
          ;; Add a new born inhabitant to the household
          set individuals individuals + 1
          set pop (pop + 1)
          set birthDeaths birthDeaths - 1

          ;; Check population in comparison with max population per cell
          ifelse (individuals) <= mnoiph [
            print (word "(settlement " swho ") [" pop "]: " self " [" individuals "]: " "Inhabitant borned.")
          ]
          [
            ;; Split household when too manny inhabitans (new household agent)
            let indivs individuals
            let indsnew random mnoiph

            while [indsnew < 2 ]
            [ set indsnew random (mnoiph) ]

            set individuals (individuals - indsnew)

            let n 0
            foreach storage [ ??1 ->
              set storage replace-item n storage (??1 / 2)
              set n n + 1
            ]
            let id 0

            hatch-households 1 [
;              set settlementId [settlementId] of parent
              set individuals indsnew
              set cultivating-patches []
              set years-to-migrate 0
              set years-settled 0
              set years-exist 0

              ;; Check strategic behaviour when evolutionary dynamics are enabled
              let bhvr 0
              ifelse egt [
;                  type (word "(settlement " swho ") [" pop "]: " parent " [" indivs "]->[" [individuals] of parent "]: Inhabitant borned. " self " created with " individuals " inabitants and strategy " strategy)
                if (strategy = 1) [ set bhvr 1 ]
                set fitnessL []
              ]
              [
                  type (word "(settlement " swho ") [" pop "]: " parent " [" indivs "]->[" [individuals] of parent "]: Inhabitant borned. " self " created with " individuals " inabitants")
              ]

              let mp patch-here

              ;; Check if curret cell area (hectare) has more than the allowed population.
              ifelse ((sum [individuals] of households-here) + individuals) > mnoipc [
                ; Move newly created household agent to a neighbor cell of the settlement
                ask spatch [
                  set mp min-one-of land-patches with [(sum [individuals] of households-here) < mnoipc] [distance myself]
                ]
                move-to mp
                ask mp [ set has-settlement true set site-id swho ]
                type (word self " ...and settled in a neighbor cell " mp ".\n")
              ]
              [
                print (".")
              ]

              ;; Set relations when self-organization social behaviour is enabled
;                if (dm = "Self-Organization") [
              if (dm > 3)[
                ;; Create peer relation with subordinates of parent agent
                let psbrs n-of 0 turtles ; empty agentset
                let samecell false ; same cell with parent household
                ask parent [
                  if (patch-here = mp) [
                    set samecell true
                    ask my-in-subordinates [
                      set psbrs (turtle-set psbrs end1)
                    ]
                  ]
                ]

                ask psbrs [
                  create-peer-from myself [
                    set time-steps 0
                    set time-steps-in-lack 0
                    set time-steps-on-load 0
                    set assigned-tasks 0
                    set load 0
                    set assigned-tasks-total 0
                    set load-total 0
                    set behavior bhvr
                    set hidden? true
                  ]

                  let oppbhvr 0
                  ask my-out-peers with [end2 = parent] [ set oppbhvr behavior ]

                  create-peer-to myself [
                    set time-steps 0
                    set time-steps-in-lack 0
                    set time-steps-on-load 0
                    set assigned-tasks 0
                    set load 0
                    set assigned-tasks-total 0
                    set load-total 0
                    set behavior oppbhvr
                    set hidden? true
                  ]
                  set is-peer true
                ]

                ;; Create subordinate relation with parent agent
                if samecell [
                  create-superior-from parent [
                    set time-steps 0
                    set time-steps-in-lack 0
                    set time-steps-on-load 0
                    set assigned-tasks 0
                    set load 0
                    set assigned-tasks-total 0
                    set load-total 0
                    set behavior bhvr
                    set hidden? true
                  ]
                  create-subordinate-to parent [
                    set time-steps 0
                    set time-steps-in-lack 0
                    set time-steps-on-load 0
                    set assigned-tasks 0
                    set load 0
                    set assigned-tasks-total 0
                    set load-total 0
                    set behavior bhvr
                    set hidden? true
                  ]
                  ask parent [ set is-superior true ]
                ]

                ;; Create aquaintance relation with all the other agents in the settlement
                set hhl households-here with [self != myself]
                let others hhl with [who != [who] of parent AND not member? self psbrs]

                create-acquaintances-from others [
                  let acbhvr 0
                  ask end1 [ if (strategy = 1) [ set acbhvr 1 ] ]

                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set behavior acbhvr
                  set hidden? true
                ]
                create-acquaintances-to others [
                  set time-steps 0
                  set time-steps-in-lack 0
                  set time-steps-on-load 0
                  set assigned-tasks 0
                  set load 0
                  set assigned-tasks-total 0
                  set load-total 0
                  set behavior bhvr
                  set hidden? true
                ]

                set is-superior false
                set is-subordinate true
                set is-peer true
              ]
;              print (word patch-here " --> " (sum [individuals] of households-here))
            ]
          ]
        ]
      ]

      if (dieFlagHousehold) [
        foreach cultivating-patches [ ??1 -> ask ??1 [ set is-cultivated false ] ]
        ; Check if it was the only household agent in settlement
        ask patch-here [
          if count households-here = 0 [
            set has-settlement false
            set is-cultivated false
            set site-id -1
          ]
        ]
        die
      ]
    ]

    ifelse pop > 0 AND count households-list > 0 [
      ;; Update household agents list
      set households-list households with [ settlementId = swho ]
      set households-cnt count households-list
      set population-size pop
    ]
    [
      print (word self " does not exist anymore. Last agent died.")
      die
    ]

;    ;; Check if directed links among pair of household agents within settlement are more than 2.
;    ask households-list [
;      let tmpId who
;      let tmphhl hhl with [who != tmpId]
;      let tmlh self
;      let tmpSetId settlementId
;      foreach sort tmphhl [ ?1 ->
;        ask ?1 [
;          let tmp count my-in-links with [end1 = tmlh]
;          if tmp > 1 [
;;            print (word "--- Year: " ticks " - " tmlh " of settlement " tmpSetId " has " tmp " links with " ?)
;          ]
;        ]
;      ]
;    ]
  ]
end


to cultivate-harvest
  ask land-patches [
    set is-checked false
    set is-cultivated false
  ]

  ;; Set/Update farming area for household agents
  ask settlements [
    let candarea candidate-area
    let hhl [] ; temporary households list
    let pop population-size
;    print (word self " (" pop "):")

    ;; When the self-organization social paradigm is employed, we assume a priority queue in the selection of nearby fields for cultivation,
    ;; based on agent (authority) relation types, thus enabling agents to cultivate similar, if not the same fields in terms of land productivity.
    ifelse (dm > 3) [
      ask households-list [
        ;; Priority to (available) superiors in the settlement
        ifelse is-superior = true
        [ set hhl fput self hhl ]
        [ set hhl lput self hhl ]
      ]
    ]
    [ set hhl (list households-list) ]

    ;; Set candidate area for cultivation
    let spatches min-n-of candarea land-patches with [has-settlement = false AND is-cultivated = false][distance myself]

    ;; Check households cultivating patches
    foreach hhl [ ??1 ->
      ask ??1 [
        let u 0
        let clp []
        let cellpop sum [individuals] of households-here

        ;; We assume that candidate patches are nearby cells with maximum expected utility, based on agent's sensory range
        let cpatches max-n-of sensory-range spatches with [is-cultivated = false][agricultural-production]

;        print (word self "Candidate patches left: " count spatches " Needed patches: " count cpatches)
        ask cpatches [
          ;; Update candidate area patches to exclude selected ones
          set spatches spatches with [self != myself]

          ;; Set estimated utility of candidate area patches
          set agricultural-production int (land-suitability * ( (((2 * sr * land-productivity) - (4 * sr)) / (mnoipc ^ 2)) * cellpop ^ 2 + ((((4 * sr) - 3 * sr * land-productivity)) / (mnoipc)) * cellpop +  sr * land-productivity) )

          ;; Check
          if ((is-ts-affected or is-va-affected) and ticks >= veyr and ve = true)
          [
            ifelse init-resources > 0
            [ set agricultural-production resources * agricultural-production / init-resources  ]
            [ set agricultural-production 0  ]
        	]

          ;; When population size is more than max population, utility is negative,
          ;; thus estimated utility is zero (just in case that such an event occurs)
          if (agricultural-production < 0) [
;            print (word "WARNING: Estimated utility for patch (" pxcor ", " pycor ") is " agricultural-production ". Settlement size is " avgpop " individuals")
            set agricultural-production 0
          ]

          set clp lput self clp
          set u (u + agricultural-production)
          set is-cultivated true
        ]

        set utility u
        set cultivating-patches clp
        set candarea candarea - sensory-range
      ]
    ]
  ]
end


to update-environment
  ask land-patches [ set is-checked false ]

  ask settlements [
    let candarea 0
    let pop population-size

    ;; Update agents potential cultivation area (sensory-range), based on the number of its inhabitants and agricultural practice employed
    ask households-list [
      set sensory-range ceiling (uThres / sr) ;; Minimum perceived needs, uThres has been already updated based on the number of household inhabitants
      if (sensory-range = 0) [ set sensory-range 1 ] ;; Set sensory-range for cultivation to at least one patch (ha)
      set candarea candarea + sensory-range
    ]

    ;; Set/Update potential cultivation area for the settlement
    set candidate-area candarea
  ]

  ;; Update agricultural production (reward) to initial resources
  ask land-patches [
    set agricultural-production resources; int (land-suitability * sr * land-productivity)
    set is-checked true
  ]
end


to initialize-settlements-households
 ;; Calculate a maximum number of households/cell for initialization
  let maxhouseholds# (mnoipc / mnoiph) ; maximum number of households/cell

  ;; Setup settlements and household agents within
  let n nos ; temp variable for the user defined number of settlements
  get-known-sites
  get-current-sites 0

  ifelse (ris = true) [
    while [n != 0][
      ;; Get list of empty land patches
      let empty-patches land-patches with [ not any? settlements-here ]
      let sid 0
      create-settlements 1 [
        set color 135 ;yellow
        set shape "circle"
;        set size 2
        let settlement-patch one-of empty-patches
        let x [pxcor] of settlement-patch
        let y [pycor] of settlement-patch
        setxy x y
        set sid who
        ;set set hidden? true
        ask settlement-patch [
          set has-settlement true
          set site-id sid
        ]
      ]
      set n (n - 1)
    ]
  ]
  [ ;; Create settlements based on archaeological evidence/survey on the Pediada region area
    ask land-patches with [has-site = true] [
      let sid 0
      let sc site-importance * 10
      sprout-settlements 1 [
        set color 135 ; yellow
        set shape "circle"
        set size 2 ;sc
        set sid who
        ;set set hidden? true
      ]

      set has-settlement true
      set site-id sid

      ;; Change settlement catchment size based on site category
      if site-category = "Settlement/Village/Site"
      [ ;; Catchment size is from 1 to 3.5 ha (cells)
        ask min-n-of random-range 1 3.5 land-patches [distance myself] [
          set has-settlement true
          set site-id sid
        ]
      ]

      if site-category = "City"
      [ ;; Catchment size is from 10 to 25 ha (cells), since City is considered a large town
        ask min-n-of random-range 10 25 land-patches [distance myself] [
          set has-settlement true
          set site-id sid
        ]
      ]
    ]
  ]
;  ask land-patches with [ has-settlement = true ][ set pcolor gray ]

  set n count land-patches with [ has-settlement = true ]
  ;; Create households
  while [n != 0] [
    let settlement-patches patches with [ has-settlement = true AND not any? households-here]
    let mh random maxhouseholds#
    if mh = 0 [ set mh 1 ]
    let household-patch one-of settlement-patches
    let people 0
    let sid [site-id] of household-patch
    let strg 1

    while [mh != 0] [
      create-households 1 [
        set color 135 ;yellow
        set shape "circle"
        set size 0
        let x [pxcor] of household-patch
        let y [pycor] of household-patch
        setxy x y
        set settlementId sid

        ;; Set household variables
        set individuals (2 + random (mnoiph - 2))
        let indivs individuals
        set people (people + individuals)
        set uThres (individuals * mu)
        set storage n-values yos [0]
        set migrate false
        set years-to-migrate 0
        set years-settled 0
        set years-exist 0
        set is-superior false
        set is-peer false
        set is-subordinate false

        set cultivating-patches []
        set migration-patches []
        set previous-location no-patches

        ;; Initialize strategic behavior
        ;; Distribute strategies uniformly in the settlement (serial way)
        ifelse egt [
          if (strg = -1) [ set strg 2 ]
          set strategy strg
          set strg (strg - 1)

          type (word  self " created with " individuals " individuals, playing strategy ")
          ifelse (strategy = 0)
          [ type "Cooperate" ]
          [
            ifelse (strategy = 1)
            [ type "Defect" ]
            [ type "Tif-for-tat" ]
          ]
          set reward 0
          set fitnessL []
          print ""
        ]
        [
          print (word  self " created with " individuals " individuals, belonging to settlment " settlementId)
          set strategy 0
        ]


        ]
      set mh (mh - 1)
    ]
    set n (n - 1)
  ]

  ask settlements [
    ;; Set settlement variables
    let sid who
    set households-list households with [settlementId = sid]
    set households-cnt count households-list
    set population-size sum [individuals] of households-list
    set years-exist 0
    set payoff 0
    set in-dgr-nrm 0
    set out-dgr-nrm 0
    set btw-nrm 0

    let catchment count land-patches with [site-id = sid]
    print (word "(settlement " sid ") created with " population-size " inhabitants, " households-cnt " households and catchment size " catchment " ha.")
  ]

  ;; Initialize settlements weight of importance Ws based on P (population ratio) and K (existance ratio)
  ask settlements [
    let P population-size / (sum [population-size] of settlements)
    let K 1
    set ws (sqrt P) * (sqrt K)
  ]
end


to initialize-relationships
  foreach sort settlements [ ?1 ->
    ask ?1 [
      let n 0
;      print (word "(Settlement "who ") relations: ")
      foreach sort households-list [ ??1 ->
        ask ??1 [
          let sp [who] of min-one-of households-here [who]
;          let sp [who] of min-one-of households-list [who]
;          print (word "sp: " sp)

          ifelse (who = sp) [
            create-superiors-to other households-here
            [
              set hidden? true
              ifelse ([strategy] of end1 = 0)
              [ set behavior 0 ] ; type (word end1 " shows cooperative behavior to " end2)
              [
                ifelse ([strategy] of end1 = 1)
                [ set behavior 1 ] ; type (word end1 " shows defective behavior to " end2)
                [ set behavior 0 ] ; type (word end1 " shows cooperative behavior to " end2)
              ]
;              print ""
            ]
            create-subordinates-from other households-here
            [
              set hidden? true
              ifelse ([strategy] of end1 = 0)
              [ set behavior 0 ] ; type (word end1 " shows cooperative behavior to " end2)
              [
                ifelse ([strategy] of end1 = 1)
                [ set behavior 1 ] ; type (word end1 " shows defective behavior to " end2)
                [ set behavior 0 ] ; type (word end1 " shows cooperative behavior to " end2)
              ]
;              print ""
            ]
            set is-superior true
          ]
          [
            create-peers-to other households-here with [who != sp]
            [
              set hidden? true
              ifelse ([strategy] of end1 = 0)
              [ set behavior 0 ] ; type (word end1 " shows cooperative behavior to " end2)
              [
                ifelse ([strategy] of end1 = 1)
                [ set behavior 1 ] ; type (word end1 " shows defective behavior to " end2)
                [ set behavior 0 ] ; type (word end1 " shows cooperative behavior to " end2)
              ]
;              print ""
            ]
            create-peers-from other households-here with [who != sp]
            [
              set hidden? true
              ifelse ([strategy] of end1 = 0)
              [ set behavior 0 ] ; type (word end1 " shows cooperative behavior to " end2)
              [
                ifelse ([strategy] of end1 = 1)
                [ set behavior 1 ] ; type (word end1 " shows defective behavior to " end2)
                [ set behavior 0 ] ; type (word end1 " shows cooperative behavior to "
              ]
;              print ""
            ]
            set is-peer true
            set is-subordinate true
          ]
;          print (word self " Superiors: " count my-in-superiors ", Subordinates: " count my-in-subordinates ", Peers: " count my-in-peers ", Acquaintances: " count my-in-acquaintances ", TotalLoad: " precision (sum [load] of my-in-links) 2)
        ]
      ]
    ]
  ]
end


to set-land-productivity
  ;; Set land productivity [0-1] based on samples from several distributions
  ifelse Resources-distribution-function = "Poisson" [
    ask land-patches [ set land-productivity random-poisson Distribution-mean ]
  ]
  [
    ifelse Resources-distribution-function = "Exponential" [
      ask land-patches [ set land-productivity random-exponential Distribution-mean ]
    ]
    [
      ifelse Resources-distribution-function = "Gamma" [
        let alpha Distribution-mean * Distribution-mean / (Distribution-stdev * Distribution-stdev)
        let lambda 1 / ((Distribution-stdev * Distribution-stdev) / Distribution-mean)
        ask land-patches [ set land-productivity random-gamma alpha lambda ]
      ]
      [
        ifelse Resources-distribution-function = "Uniform" [
          ask land-patches [ set land-productivity random-float 1 ]
        ]
        [
          ask land-patches [ set land-productivity random-normal Distribution-mean Distribution-stdev ]
        ]
      ]
    ]
  ]

  ;; Feature scaling to [0 1]
  let pmax max [land-productivity] of land-patches
  let pmin min [land-productivity] of land-patches
  let psum pmax - pmin
  ask land-patches [ set land-productivity ((land-productivity - pmin) / psum) ]
  if Resources-distribution-function = "Exponential" [
      ask land-patches [ set land-productivity 1 - land-productivity ]
  ]

;  print (word "Pmax: " pmax " Pmin: " pmin " Psum (+): " psum " p2min (-): " p2min " p2max (/): " p2max )
;  print count land-patches
end


to set-land-suitability
  ;; Set land suitability [0-1] as a decay with increasing slope
  ask land-patches [ set land-suitability gis:raster-value slope-raster pxcor (max-pycor - pycor) ]
 ask land-patches [ set land-suitability (exp (- land-suitability / 20)) ]
end


to set-aquifer-utility
  ;; Set aquifer utility [0-1] of the environmental patches
  ask land-patches [ set aquifer-utility gis:raster-value aquifer-raster pxcor (max-pycor - pycor) ]
  let maq max [aquifer-utility] of land-patches
 ask land-patches [ set aquifer-utility (aquifer-utility / maq) ]
end


to set-natural-disaster
  ;; Set volcanic eruption environmental impact (tsunami waves sudden-onset disaster)
  ask patches with [has-sea = true and count neighbors with [has-sea = false] > 1] [
    ask patches with [ distance myself <= (inund / (1000 * cell-size)) ] [
      if (has-sea = false and elevation <= slr )
      [
        set is-ts-affected true
        set ve-impact 0
      ]
    ]
  ]
  ;; Set volcanic eruption environmental impact (volcanic ash slow-onset disaster)
  let me max [elevation] of land-patches
  ask land-patches with [is-ts-affected = false] [
    set is-va-affected true
    set ve-impact (precision (elevation / me) 2)
  ]

  ask land-patches [
    set init-resources resources
;    if (is-ts-affected) [ set pcolor cyan ]
  ]
end


to run-natural-disaster
  ;; Check if the currrent time step is the time of the natural disaster event
  if (ticks = veyr) [
    set veyr ticks

    ask settlements [
      let pop population-size
      let swho who
      let hhl households-list
      let spatch patch-here
;      let dtcl [dt-coastline] of spatch
      let dieflagSettlement false

      ;; Check mortality of households within settlements
      ask households-list [
        let dieflagHousehold false
        let counter 0 ;; consider households with at least a number of "counter" individuals only
        let deaths 0

        ;; Check inhabitant mortality probability
        while [counter != individuals] [
          ;; Set volcanic eruption mortality provoked by earthquake destruction and burning
          let vedthres fprb / 100;
          ;; Set volcanic eruption mortality provoked by tsunamis based on the distance 2 coastline
;          if ([is-ts-affected] of patch-here) [
;            set vedthres (.8 / dtcl)
;          ]

            if random-float 1.0 < vedthres [
              set deaths deaths + 1
            ]
            set counter counter + 1
          ]
;          if (deaths != 0) [ print (word self " Deaths: " deaths) ]

          ;; Update household inhabitants
          while [deaths > 0] [
            ;; Check individuals.
            ifelse (individuals - deaths) > 0 [
              set pop (pop - 1)
              set individuals individuals - 1
              set deaths deaths - 1
              print (word "(settlement " swho ") [" pop "]: " self " [" individuals "]: " "inhabitant died by the impact of the natural disaster.")
            ]
            [
              set dieFlagHousehold true
              set pop (pop - individuals)
              print (word "(settlement " swho ") [" pop "]: " self " [" individuals "]: " "Household agent died by the impact of the natural disaster")
              set deaths 0
            ]
          ]

          if (dieFlagHousehold) [
            foreach cultivating-patches [ ??1 -> ask ??1 [ set is-cultivated false ] ]
            ;; Check if it was the only household agent in the settlement
            ask patch-here [
              if count households-here = 0 [
                set has-settlement false
                set is-cultivated false
              ]
            ]
            die
          ]
      ]

      ifelse pop > 0 AND count households-list > 0 [
        ;; Update household agents list
        set households-list households with [ settlementId = swho ]
        set households-cnt count households-list
        set population-size pop
      ]
      [
        print (word self " does not exist anymore. Last agent died.")
        die
      ]
    ]
  ]

  ;; Update tsunami affected areas
  ask land-patches with [is-ts-affected = true] [
    if ticks >= veyr and ticks < (veyr + tyrs)
    [ set resources (ve-impact * init-resources) ]

    if ticks >= (veyr + tyrs)
    [
      set is-ts-affected false
      set resources init-resources
    ]
  ]

  ;; Update volcanic ash affected cell areas
  ask land-patches with [is-va-affected = true] [
    if ticks >= veyr and ticks < (veyr + vayrs)
    [
      ;; Restore volcanic ash environmental impact based on time that pass by
      ifelse ve-impact = 0
      [ set resources 0 ]
      [ set resources ( (ve-impact * init-resources) * (1 / ve-impact) ^ ((ticks - veyr) / vayrs) ) ]
    ]

    if ticks >= (veyr + vayrs)
    [
      set is-va-affected false
      set resources init-resources
    ]
  ]
end


to spatial-interaction
  set in-dgr-avg 0
  set in-dgr-std 0
  set in-dgr-cfv 0
  set out-dgr-avg 0
  set out-dgr-std 0
  set out-dgr-cfv 0
  set btw-avg 0
  set btw-std 0
  set btw-cfv 0

  set in-dgr-index 0
  set out-dgr-index 0
  set btw-index 0

  set avg-cluster-cfv 0
  set louvain-con 0

  let spop sum [population-size] of settlements
  ask interactions [ die ]

  ask settlements [
    set payoff 0
    set in-dgr-nrm 0
    set out-dgr-nrm 0
    set btw-nrm 0

    let sid who

    ifelse simp = "Simulation"
    [ ;; Set settlements weight of importance Ws based on P (population ratio) and K (history/existance ratio)
      if ticks > 0 [
        let P population-size / spop
        let K years-exist / ticks
        set ws precision ((sqrt P) * (sqrt K)) 2
      ]
    ]
    [ ;; Set settlements weight of importance Ws considering archaeological evidence
      let imp [site-importance] of patch-here
      set ws precision imp 2
    ]
  ]

  ask settlements [
    ;; Set trading resources S for the settlement to be exchanged
    let S sum [(sum storage * hst)] of households-list
    print (word " ---- " self " trading resources S: " precision S 2 " / Ws: " ws " ---- \n") ; / SI: " sint " ---- ")

    if S > 0 [
      ;; Remove hst (percent of) resources from each household storage
      ask households-list [
;        type (word self " storage before: " storage)

        let rmres sum storage * hst
        let n 0
        let stopflag false ;; when flag is true exit checking storage process
        foreach storage [ ?1 ->
          if stopflag = false [
            ifelse (rmres - ?1) >= 0
            [
              set rmres rmres - ?1
              set storage replace-item n storage 0
              set n n + 1
            ]
            [
              set storage replace-item n storage (?1 - rmres)
              set rmres 0
              set stopflag true
            ]
          ]
        ]
;        type (word " and storage after: " storage "\n")
      ]

      let smx 0
      let smn 0
      let sumI 0

      ifelse sint = "XTENT model"
      [
        ask max-one-of other settlements [( ws ^ beta - m * distance myself)][ set smx ( ws ^ beta - m * distance myself) ]
        ask min-one-of other settlements [( ws ^ beta - m * distance myself)][ set smn ( ws ^ beta - m * distance myself) ]
      ]
      [ ;; Gravity model
        ask max-one-of other settlements [( ws / (distance myself) ^ lamda)][ set smx ( ws / (distance myself) ^ lamda) ]
        ask min-one-of other settlements [( ws / (distance myself) ^ lamda)][ set smn ( ws / (distance myself) ^ lamda) ]
      ]

      if smx = smn [ set smx 1 set smn 0 ]

      ask other settlements [
        ;; Set probability of interaction based on other settlements "atrractiveness"
        let prob 0
        ifelse sint = "XTENT model"
        [ set prob precision (((ws ^ beta - m * distance myself) - smn) / (smx - smn)) 2 ] ; XTENT model
        [ set prob precision ((( ws / (distance myself) ^ lamda) - smn) / (smx - smn)) 2 ] ; Gravity model
        type (word "Attractiveness with " self ": " prob )

        ifelse random-float 1.0 < prob [
          create-interaction-from myself [
            set attractiveness prob
            if display-territories? = false and display-indg-nw? = false and display-outdg-nw? = false and display-btw-nw? = false and display-lv-con? = false
            [set hidden? true]
          ]
          set sumI precision (sumI + prob) 2
          type (word " and decided to interact with\n" ); (SumI: " sumI ")\n" )
        ]
        [
          type (word "\n" )
        ]
      ]
      print (word " ")

      ask my-out-interactions [
        let sat attractiveness
        let dres sat
        if sumI > 0 [set dres precision (sat / sumI) 2 ]
        let sres precision (dres * S) 2

        ask end2 [
          ;; Update interacting settlement payoff based on amount of resources exchanged
          set payoff payoff + sres
;          print (word "Distributing " round (dres * 100)  "% of resources, i.e. " sres " amount of resources to " self   )
        ]
      ]
    ]
;    print (word "\n")
  ]

  let nds count settlements ;; number of nodes in the current trading network
  let ni count settlements with [count my-in-interactions > 0] ;; number of nodes in the current trading network with incoming interactions
  let no count settlements with [count my-out-interactions > 0] ;; number of nodes in the current trading network with outgoing interactions
  let ns count settlements with [count my-in-interactions > 0 and count my-out-interactions > 0] ;; number of nodes in the current trading network with reciprocated interactions
;  print (word "Ni: " ni ", No: " no ", Ns: " ns ", N: " nds)

  ask settlements [
    ;; Distribute payoff from exchanges to settlement's households (based on the number of each household inhabitants)
;    print (word " ---- " self " Distributing payoff: " precision payoff 2 " / Population: " population-size " ---- ")
    let damount payoff / population-size
    ask households-list [
;      type (word self " storage before: " storage)
      let hdamount individuals * damount ;; Payoff amount analogy per inhabitant
      let cyres last storage ;; current year's resources
      set storage replace-item (length storage - 1) storage (cyres + hdamount) ;; replace current year stored surplus with additional payoff
;      type (word " and storage after: " storage "\n")
    ]

    ;; Set settlement (node) network indices/measures
    if ( nds > 1 and ((ni - 1) * (no - 1) - (ns - 1)) > 0) [
      set in-dgr-nrm precision (count my-in-interactions / (nds - 1)) 2 ; normalized in-degree
      set out-dgr-nrm precision (count my-out-interactions / (nds - 1)) 2 ; normalized out-degree
      set btw-nrm precision (nw:betweenness-centrality / ((ni - 1) * (no - 1) - (ns - 1))) 2 ; normalized betweenness
    ]
  ]


  ;; Set general trading network indices/measures
  set in-dgr-avg precision mean [in-dgr-nrm] of settlements 2
  set in-dgr-std precision standard-deviation [in-dgr-nrm] of settlements 2
  if in-dgr-avg > 0 [ set in-dgr-cfv precision (in-dgr-std / in-dgr-avg) 2 ]

  set out-dgr-avg precision mean [out-dgr-nrm] of settlements 2
  set out-dgr-std precision standard-deviation [out-dgr-nrm] of settlements 2
  if out-dgr-avg > 0 [ set out-dgr-cfv precision (out-dgr-std / out-dgr-avg) 2 ]

  set btw-avg precision mean [btw-nrm] of settlements 2
  set btw-std precision standard-deviation [btw-nrm] of settlements 2
  if btw-avg > 0 [ set btw-cfv precision (btw-std / btw-avg) 2 ]


  let maxindgr max [in-dgr-nrm] of settlements
  if nds > 1 [set in-dgr-index precision ((sum [maxindgr - in-dgr-nrm] of settlements) / (nds - 2)) 2 ]

  let maxoutdgr max [out-dgr-nrm] of settlements
  if nds > 1 [ set out-dgr-index precision ((sum [maxoutdgr - out-dgr-nrm] of settlements) / (nds - 2)) 2 ]

  let maxbtw max [btw-nrm] of settlements
  if nds > 1 [ set btw-index precision ((sum [maxbtw - btw-nrm] of settlements) / (nds - 1)) 2 ]

  set avg-cluster-cfv mean [nw:clustering-coefficient] of settlements
  set louvain-con length nw:louvain-communities
;  print (word "In-Degree: [AVG] " in-dgr-avg ", [STD] " in-dgr-std ", [COEF] " in-dgr-cfv ", [GRAPH] " in-dgr-index)
;  print (word "Out-Degree: [AVG] " out-dgr-avg ", [STD] " out-dgr-std ", [COEF] " out-dgr-cfv ", [GRAPH] " out-dgr-index)
;  print (word "Betweenness: [AVG] " btw-avg ", [STD] " btw-std ", [COEF] " btw-cfv ", [GRAPH] " btw-index)
;  print (word "Clustering Coefficient [AVG] " avg-cluster-cfv ", Louvain communities: " louvain-con)

  ;; Visualize settlement trading network based on parameters
  ifelse display-territories?
  [
    set display-territories? false
    show-territories
  ]
  [ ifelse display-indg-nw?
    [
      set display-indg-nw? false
      show-in-degree-network
    ]
    [
      ifelse display-outdg-nw?
      [
        set display-outdg-nw? false
        show-out-degree-network
      ]
      [
        ifelse display-btw-nw?
        [
          set display-btw-nw? false
          show-betweenness-network
        ]
        [
          if display-lv-con?
          [
            set display-lv-con? false
            show-louvain-communities
          ]
        ]
      ]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;; BEGIN SPATIAL INTERACTIONS DIVIDED ;;;;;;;;;;;;;;;;;;;;;;;;;;
to spatial-interaction-all
  spatial-interaction-init
  spatial-interaction-calculate-importance
  spatial-interaction-calculate-trade-targets
end

to spatial-interaction-init
  set in-dgr-avg 0
  set in-dgr-std 0
  set in-dgr-cfv 0
  set out-dgr-avg 0
  set out-dgr-std 0
  set out-dgr-cfv 0
  set btw-avg 0
  set btw-std 0
  set btw-cfv 0

  set in-dgr-index 0
  set out-dgr-index 0
  set btw-index 0

  set avg-cluster-cfv 0
  set louvain-con 0

  ask interactions [ die ]

  ask settlements [
    set tradable-resources 0
  ]
end

to spatial-interaction-calculate-importance
  let spop sum [population-size] of settlements

  ask settlements [
    set payoff 0
    set in-dgr-nrm 0
    set out-dgr-nrm 0
    set btw-nrm 0

    let sid who

    ifelse simp = "Simulation"
    [ ;; Set settlements weight of importance Ws based on P (population ratio) and K (history/existance ratio)
      if ticks > 0 [
        let P population-size / spop
        let K years-exist / ticks
        set ws precision ((sqrt P) * (sqrt K)) 2
      ]
    ]
    [ ;; Set settlements weight of importance Ws considering archaeological evidence
      let imp [site-importance] of patch-here
      set ws precision imp 2
    ]
  ]
end

to spatial-interaction-calculate-trade-targets
    ask settlements [
    ;; Set trading resources S for the settlement to be exchanged
    let S sum [(sum storage * hst)] of households-list
    set tradable-resources S
    print (word " ---- " self " trading resources S: " precision S 2 " / Ws: " ws " ---- \n") ; / SI: " sint " ---- ")

    if S > 0 [
      ;; Remove hst (percent of) resources from each household storage
      ask households-list [
;        type (word self " storage before: " storage)

        let rmres sum storage * hst
        let n 0
        let stopflag false ;; when flag is true exit checking storage process
        foreach storage [ ?1 ->
          if stopflag = false [
            ifelse (rmres - ?1) >= 0
            [
              set rmres rmres - ?1
              set storage replace-item n storage 0
              set n n + 1
            ]
            [
              set storage replace-item n storage (?1 - rmres)
              set rmres 0
              set stopflag true
            ]
          ]
        ]
;        type (word " and storage after: " storage "\n")
      ]

      let smx 0
      let smn 0
      let sumI 0

      ifelse sint = "XTENT model"
      [
        ask max-one-of other settlements [( ws ^ beta - m * distance myself)][ set smx ( ws ^ beta - m * distance myself) ]
        ask min-one-of other settlements [( ws ^ beta - m * distance myself)][ set smn ( ws ^ beta - m * distance myself) ]
      ]
      [ ;; Gravity model
        ask max-one-of other settlements [( ws / (distance myself) ^ lamda)][ set smx ( ws / (distance myself) ^ lamda) ]
        ask min-one-of other settlements [( ws / (distance myself) ^ lamda)][ set smn ( ws / (distance myself) ^ lamda) ]
      ]

      if smx = smn [ set smx 1 set smn 0 ]

      ask other settlements [
        ;; Set probability of interaction based on other settlements "atrractiveness"
        let prob 0
        ifelse sint = "XTENT model"
        [ set prob precision (((ws ^ beta - m * distance myself) - smn) / (smx - smn)) 2 ] ; XTENT model
        [ set prob precision ((( ws / (distance myself) ^ lamda) - smn) / (smx - smn)) 2 ] ; Gravity model
        type (word "Attractiveness with " self ": " prob )

        ifelse random-float 1.0 < prob [
          create-interaction-from myself [
            set attractiveness prob
            if display-territories? = false and display-indg-nw? = false and display-outdg-nw? = false and display-btw-nw? = false and display-lv-con? = false
            [set hidden? true]
          ]
          set sumI precision (sumI + prob) 2
          type (word " and decided to interact with\n" ); (SumI: " sumI ")\n" )
        ]
        [
          type (word "\n" )
        ]
      ]
      print (word " ")
  ]
]
end

to-report get-all-settlement-out-interaction-pairs
  let result []
  ask settlements [
    let source-who who
    ask my-out-interactions [
      set result lput (list source-who [who] of end2) result
    ]
  ]
  if empty? result [
    report [[-1 -1]]
  ]
  report result
end

to spatial-interaction-payoff-cleanup
  ask settlements [
    set payoff payoff + tradable-resources
    set tradable-resources 0
  ]
end

to spatial-interaction-distribute-payoff-and-Update-network
  let nds count settlements ;; number of nodes in the current trading network
  let ni count settlements with [count my-in-interactions > 0] ;; number of nodes in the current trading network with incoming interactions
  let no count settlements with [count my-out-interactions > 0] ;; number of nodes in the current trading network with outgoing interactions
  let ns count settlements with [count my-in-interactions > 0 and count my-out-interactions > 0] ;; number of nodes in the current trading network with reciprocated interactions
;  print (word "Ni: " ni ", No: " no ", Ns: " ns ", N: " nds)

  ask settlements [
    ;; Distribute payoff from exchanges to settlement's households (based on the number of each household inhabitants)
;    print (word " ---- " self " Distributing payoff: " precision payoff 2 " / Population: " population-size " ---- ")
    let damount payoff / population-size
    ask households-list [
;      type (word self " storage before: " storage)
      let hdamount individuals * damount ;; Payoff amount analogy per inhabitant
      let cyres last storage ;; current year's resources
      set storage replace-item (length storage - 1) storage (cyres + hdamount) ;; replace current year stored surplus with additional payoff
;      type (word " and storage after: " storage "\n")
    ]

    ;; Set settlement (node) network indices/measures
    if ( nds > 1 and ((ni - 1) * (no - 1) - (ns - 1)) > 0) [
      set in-dgr-nrm precision (count my-in-interactions / (nds - 1)) 2 ; normalized in-degree
      set out-dgr-nrm precision (count my-out-interactions / (nds - 1)) 2 ; normalized out-degree
      set btw-nrm precision (nw:betweenness-centrality / ((ni - 1) * (no - 1) - (ns - 1))) 2 ; normalized betweenness
    ]
  ] 

  ;; Set general trading network indices/measures
  set in-dgr-avg precision mean [in-dgr-nrm] of settlements 2
  set in-dgr-std precision standard-deviation [in-dgr-nrm] of settlements 2
  if in-dgr-avg > 0 [ set in-dgr-cfv precision (in-dgr-std / in-dgr-avg) 2 ]

  set out-dgr-avg precision mean [out-dgr-nrm] of settlements 2
  set out-dgr-std precision standard-deviation [out-dgr-nrm] of settlements 2
  if out-dgr-avg > 0 [ set out-dgr-cfv precision (out-dgr-std / out-dgr-avg) 2 ]

  set btw-avg precision mean [btw-nrm] of settlements 2
  set btw-std precision standard-deviation [btw-nrm] of settlements 2
  if btw-avg > 0 [ set btw-cfv precision (btw-std / btw-avg) 2 ]


  let maxindgr max [in-dgr-nrm] of settlements
  if nds > 1 [set in-dgr-index precision ((sum [maxindgr - in-dgr-nrm] of settlements) / (nds - 2)) 2 ]

  let maxoutdgr max [out-dgr-nrm] of settlements
  if nds > 1 [ set out-dgr-index precision ((sum [maxoutdgr - out-dgr-nrm] of settlements) / (nds - 2)) 2 ]

  let maxbtw max [btw-nrm] of settlements
  if nds > 1 [ set btw-index precision ((sum [maxbtw - btw-nrm] of settlements) / (nds - 1)) 2 ]

  set avg-cluster-cfv mean [nw:clustering-coefficient] of settlements
  set louvain-con length nw:louvain-communities
;  print (word "In-Degree: [AVG] " in-dgr-avg ", [STD] " in-dgr-std ", [COEF] " in-dgr-cfv ", [GRAPH] " in-dgr-index)
;  print (word "Out-Degree: [AVG] " out-dgr-avg ", [STD] " out-dgr-std ", [COEF] " out-dgr-cfv ", [GRAPH] " out-dgr-index)
;  print (word "Betweenness: [AVG] " btw-avg ", [STD] " btw-std ", [COEF] " btw-cfv ", [GRAPH] " btw-index)
;  print (word "Clustering Coefficient [AVG] " avg-cluster-cfv ", Louvain communities: " louvain-con)

  ;; Visualize settlement trading network based on parameters
  ifelse display-territories?
  [
    set display-territories? false
    show-territories
  ]
  [ ifelse display-indg-nw?
    [
      set display-indg-nw? false
      show-in-degree-network
    ]
    [
      ifelse display-outdg-nw?
      [
        set display-outdg-nw? false
        show-out-degree-network
      ]
      [
        ifelse display-btw-nw?
        [
          set display-btw-nw? false
          show-betweenness-network
        ]
        [
          if display-lv-con?
          [
            set display-lv-con? false
            show-louvain-communities
          ]
        ]
      ]
    ]
  ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;; END SPATIAL INTERACTIONS DIVIDED ;;;;;;;;;;;;;;;;;;;;;;;;;;

to updt-relations-hist
  let cntRC 0
  while[cntRC != relationChangesFromAcqToAuth] [ set relChanges lput 1 relChanges set cntRC cntRC + 1]
  set cntRC 0
  while[cntRC != relationChangesFromPeerToAuth] [ set relChanges lput 2 relChanges set cntRC cntRC + 1]
  set cntRC 0
  while[cntRC != relationChangesFromAcqToPeer] [ set relChanges lput 3 relChanges set cntRC cntRC + 1]
  set cntRC 0
  while[cntRC != relationChangesFromAuthToPeer] [ set relChanges lput 4 relChanges set cntRC cntRC + 1]
  set cntRC 0
  while[cntRC != relationChangesFromAuthToAcq] [ set relChanges lput 5 relChanges set cntRC cntRC + 1]
  set cntRC 0
  while[cntRC != relationChangesFromPeerToAcq] [ set relChanges lput 6 relChanges set cntRC cntRC + 1]

end


to show-cultivation
  let max-elevation gis:maximum-of elevation-raster
  let min-elevation gis:minimum-of elevation-raster
;  print (word "max-elevation: " max-elevation ", min elevation: " min-elevation)

  ask land-patches
  [
    let el gis:raster-sample elevation-raster self
    if ((el <= 0) or (el >= 0)) [ set pcolor scale-color black elevation min-elevation max-elevation ]
  ]


  if display-rivers? = true [ ask patches gis:intersecting rivers-dataset [ set pcolor blue ] ]
  if display-springs? = true [ ask patches gis:intersecting springs-dataset [ set pcolor cyan ] ]
  if display-sites? = true [ ask patches gis:intersecting sites-dataset [ set pcolor red ] ]

;  ask land-patches with [is-cultivated = true] [ set pcolor scale-color green agricultural-production sr 0 ]
  ask land-patches with [is-cultivated = true] [
    ifelse (agricultural-production < round (sr / 4) ) [set pcolor 59]
    [ ifelse (agricultural-production < round (sr / 2) ) [set pcolor 57]
      [ ifelse (agricultural-production < round (3 * sr / 4) ) [set pcolor 55]
        [set pcolor 53]
      ]
    ]
  ]
end


to show-elevation
  set display-elevation? true
  set display-slope? false
  set display-aquifer? false
  set display-resources? false
  let max-elevation gis:maximum-of elevation-raster
  let min-elevation gis:minimum-of elevation-raster
;  print (word "max-elevation: " max-elevation ", min elevation: " min-elevation)

  ask patches
  [
    let el gis:raster-sample elevation-raster self
;    ifelse ((el <= 0) or (el >= 0))
    ifelse (el > 0)
    ;[ set pcolor scale-color black elevation min-elevation max-elevation ]
    [ set pcolor palette:scale-gradient
      [[252 141 89][255 255 191][0 104 55]] elevation max-elevation min-elevation ]; scheme-colors "Divergent" "BrBG" 10 elevation max-elevation min-elevation ]
    [ set pcolor blue ]
  ]

end


to show-slope
  set display-elevation? false
  set display-slope? true
  set display-aquifer? false
  set display-resources? false
  let max-slope gis:maximum-of slope-raster
  let min-slope gis:minimum-of slope-raster
;  print (word "max-slope: " max-slope ", min slope: " min-slope)

  ask land-patches
  [
    let sl gis:raster-sample slope-raster self
    ifelse ((sl <= 0) or (sl >= 0))
    [ set pcolor scale-color black slope min-slope max-slope ]
    [ set pcolor blue ]
  ]

end


to show-aquifer
  set display-aquifer? true
  set display-elevation? false
  set display-slope? false
  set display-resources? false
;  print (word "max-aquifer: " max-aquifer ", min aquifer: " min-aquifer)

  ask land-patches
  [
    let al gis:raster-sample aquifer-raster self
    ifelse ((al <= 0) or (al >= 0))
    [ set pcolor scale-color cyan aquifer-utility 1 0]
    [ set pcolor blue ]
  ]

end


to show-resources
  set display-aquifer? false
  set display-elevation? false
  set display-slope? false
  set display-resources? true

  ask land-patches [ set pcolor scale-color black resources sr 0 ]
end


to show-rivers
  if display-elevation? = true [show-elevation]
  if display-slope? = true [show-slope]
  if display-aquifer? = true [show-aquifer]
  if display-resources? = true [show-resources]
  if display-springs? = true [ ask patches gis:intersecting springs-dataset [ set pcolor cyan ] ]
  if display-sites? = true [ ask patches gis:intersecting sites-dataset [ set pcolor red ] ]

  ifelse display-rivers? = false
  [
    ask land-patches gis:intersecting rivers-dataset [ set pcolor blue ]
    set display-rivers? true
  ]
  [ set display-rivers? false ]
end


to show-springs
  if display-elevation? = true [show-elevation]
  if display-slope? = true [show-slope]
  if display-aquifer? = true [show-aquifer]
  if display-resources? = true [show-resources]
  if display-rivers? = true [ ask patches gis:intersecting rivers-dataset [ set pcolor blue ] ]
  if display-sites? = true [ ask patches gis:intersecting sites-dataset [ set pcolor red ] ]

  ifelse display-springs? = false
  [
    ask land-patches gis:intersecting springs-dataset [ set pcolor cyan ]
    set display-springs? true
  ]
  [ set display-springs? false ]
end


to show-sites
  ifelse display-sites? = false
  [
    ask land-patches with [has-site = true] [
      sprout 1 [
        set color red
        set shape "circle"
        set size 3
      ]
    ]
    set display-sites? true
  ]
  [
    set display-sites? false
    ask turtles with [color = red] [ die ]
  ]
end


to show-territories
  if sint != "Off" [ ; Check if spatial interaction across settlements is enabled
    ifelse display-territories? = false
    [
      ;; Coloring settlement territorries; too dark and too light are hard to distinguish from each other, so only use 13-17, 23-27, ..., 133-137
      let available-colors shuffle filter [ c ->
        (c mod 10 >= 3) and (c mod 10 <= 7)
      ] n-values 140 [ n -> n ]

      ask settlements [
        set shape "circle 3"
        set size 30 * ws
        set color first available-colors
        set available-colors butfirst available-colors
      ]

      ask interactions [ set hidden? true ]

      ifelse sint = "XTENT model"
      [ ask land-patches with [has-settlement = false][ set pcolor [color] of max-one-of settlements [ws ^ beta - m * distance myself] ] ]
      [ ask land-patches with [has-settlement = false][ set pcolor [color] of max-one-of settlements [ws / (distance myself) ^ lamda] ] ] ;; Gravity model
      set display-territories? true
      set display-indg-nw? false
      set display-outdg-nw? false
      set display-btw-nw? false
      set display-lv-con? false
    ]
    [
      set display-territories? false
      show-settlements-util
    ]
  ]
end


to show-in-degree-network
  if sint != "Off" [ ; Check if spatial interaction across settlements is enabled
    ifelse display-indg-nw? = false
    [
      ask settlements [
        set shape "circle 3"
        ifelse in-dgr-nrm > 0
        [ set size 30 * in-dgr-nrm ]
        [set size 3 ]
        set color scale-color black in-dgr-nrm 1 0
      ]
      ask interactions [ set hidden? false ]
      set display-territories? false
      set display-indg-nw? true
      set display-outdg-nw? false
      set display-btw-nw? false
      set display-lv-con? false
    ]
    [
      set display-indg-nw? false
      show-settlements-util
    ]
  ]
end


to show-out-degree-network
  if sint != "Off" [ ; Check if spatial interaction across settlements is enabled
    ifelse display-outdg-nw? = false
    [
      ask settlements [
        set shape "circle 3"
        ifelse out-dgr-nrm > 0
        [ set size 30 * out-dgr-nrm ]
        [set size 3 ]
        set color scale-color black out-dgr-nrm 1 0
      ]
      ask interactions [ set hidden? false ]
      set display-territories? false
      set display-indg-nw? false
      set display-outdg-nw? true
      set display-btw-nw? false
      set display-lv-con? false
    ]
    [
      set display-outdg-nw? false
      show-settlements-util
    ]
  ]
end


to show-betweenness-network
  if sint != "Off" [ ; Check if spatial interaction across settlements is enabled
    ifelse display-btw-nw? = false
    [
      ask settlements [
        set shape "circle 3"
        ifelse btw-nrm > 0
        [ set size 30 * btw-nrm ]
        [set size 3 ]
        set color scale-color black btw-nrm 1 0
      ]
      ask interactions [ set hidden? false ]
      set display-territories? false
      set display-indg-nw? false
      set display-outdg-nw? false
      set display-btw-nw? true
      set display-lv-con? false
    ]
    [
      set display-btw-nw? false
      show-settlements-util
    ]
  ]
end


to show-louvain-communities
  let communities nw:louvain-communities
  if sint != "Off" and length communities > 0 and length communities < 14 [ ; Check if spatial interaction across settlements is enabled
    ifelse display-lv-con? = false
    [
      let colors n-of (length communities) base-colors
      (foreach communities colors [ [community col] ->
        ask community [ set color col ]
      ])

      ask settlements [
        set shape "circle 3"
        set size 30 * ws
      ]

      ask interactions [ set hidden? false ]
      set display-territories? false
      set display-indg-nw? false
      set display-outdg-nw? false
      set display-btw-nw? false
      set display-lv-con? true
    ]
    [
      set display-lv-con? false
      show-settlements-util
    ]
  ]
end


to show-settlements-util
  ask settlements [
    let util []
    let utilThres []

    ask households-list [
      set util fput utility util
      set utilThres fput uThres utilThres
    ]
    ;; Color settlement locations with a shade of yellow from lighter (high settlement avg utility) to darker (low settlement avg utility)
    ifelse (mean util >= mean utilthres)
    [ set color 45 ]
    [
      ifelse (mean util >= (mean utilthres) / 2)
      [ set color 43 ]
      [ set color 41 ]
    ]
    set shape "circle"
    set size 2
  ]
  ask interactions [ set hidden? true ]
  if display-territories? = false and display-indg-nw? = false and display-outdg-nw? = false and display-btw-nw? = false and display-lv-con? = false
  [ show-elevation ]
end


to get-known-sites
  let valid false

  foreach gis:property-names sites-dataset [
    property-name ->
    if (property-name = "CATEGORY")[ set valid true ]
;    print property-name
  ]

  foreach gis:feature-list-of sites-dataset [
    vector-feature ->
    let coord-tuple gis:location-of (first (first (gis:vertex-lists-of vector-feature)))
    let long item 0 coord-tuple
    let lat item 1 coord-tuple
    ifelse (valid)[
      let pvcat gis:property-value vector-feature "category"
      let pvts gis:property-value vector-feature "TimeStart"
      let pvte gis:property-value vector-feature "TimeEnd"

      create-sites 1 [
        set category pvcat
        set timeStart pvts
        set timeEnd pvte
        setxy long lat
        set size 0
      ]
    ]
    [
      create-sites 1 [
        set name who
        set category "Settlement/Village/Site"
        set timeStart 0
        set timeEnd 1999
        setxy long lat
        set size 0
      ]
    ]
  ]
end


to get-current-sites [ year ]
  ask land-patches [
    set has-site false
    set site-category ""
    set site-importance 0
  ]
;  print (word "Current known habitation sites: " count sites with [timeStart <= year and timeEnd >= year])

  ask sites with [timeStart <= year and timeEnd >= year][
    ask patch-here [
      set has-site true
      set site-category [category] of myself
      ifelse site-category = "Villa"
      [ set site-importance 0.1 ]
      [
        ifelse site-category = "House/Houses"
        [ set site-importance 0.2 ]
        [ ifelse site-category = "Settlement/Village/Site"
          [ set site-importance 0.5 ]
          [ ifelse site-category = "City"
            [ set site-importance 0.7 ]
            [ set site-importance 0.9 ]
          ]
        ]
      ]
    ]
  ]
end


to-report random-range [ a b ]
    report a + random (b - a)
end


to calculate-aquifer-utility
  print "Calculating aquifer density..."
  let ar Aquifer-density-radius / cell-size
  let sumDensR count land-patches with [has-river or is-coastline] ; rvalue = 1
  ask land-patches with [has-river or is-coastline][
    ask land-patches in-radius ar [
      let density (1 / (ar ^ 2)) * ((3 / pi) * (1 - ((distance myself) / ar) ^ 2) ^ 2)
;      print (word "("pxcor "," pycor  ") " value)
      set rvalue rvalue + (density * sumDensR)
    ]
  ]

  let sumDensS count land-patches with [has-spring] ; svalue = 1
  ask land-patches with [has-spring][
    ask land-patches in-radius ar [
      let density (1 / (ar ^ 2)) * ((3 / pi) * (1 - ((distance myself) / ar) ^ 2) ^ 2)
;      print (word "("pxcor "," pycor  ") " value)
      set svalue svalue + (density * sumDensS)
    ]
  ]

  let maxrv max [rvalue] of land-patches
  let maxsv max [svalue] of land-patches

  set aquifer-raster gis:create-raster gis:width-of elevation-raster gis:height-of elevation-raster gis:envelope-of elevation-raster
  ask land-patches [
    set rvalue precision (rvalue / maxrv) 2
    set svalue precision (svalue / maxsv) 2
    gis:set-raster-value aquifer-raster pxcor (max-pycor - pycor) max list rvalue svalue
  ]
end


to calculate-slope-aspect
  print "Calculating slope and aspect topgraphical data values..."
  gis:set-world-envelope gis:envelope-of elevation-raster
  ;set elevation-raster gis:patch-dataset elevation
  let horizontal-gradient gis:convolve elevation-raster 3 3 [ 1 0 -1 2 0 -2 1 0 -1 ] 1 1
  let vertical-gradient gis:convolve elevation-raster 3 3 [ 1 2 1 0 0 0 -1 -2 -1 ] 1 1

  set slope-raster gis:create-raster gis:width-of elevation-raster gis:height-of elevation-raster gis:envelope-of elevation-raster
;  set aspect-raster gis:create-raster gis:width-of elevation-raster gis:height-of elevation-raster gis:envelope-of elevation-raster

  let x 0
  repeat (gis:width-of elevation-raster)
  [
    let y 0
    repeat (gis:height-of elevation-raster)
    [
      let gx gis:raster-value horizontal-gradient x y
      let gy gis:raster-value vertical-gradient x y
      if ((gx <= 0) or (gx >= 0)) and ((gy <= 0) or (gy >= 0))
      [
        set gx gx / (8 * cell-size * 1000)
        set gy gy / (8 * cell-size * 1000)
        gis:set-raster-value slope-raster x y atan (sqrt ((gx * gx) + (gy * gy))) 1
;        ifelse (gx != 0) or (gy != 0)
;        [ gis:set-raster-value aspect-raster x y atan gy gx ]
;        [ gis:set-raster-value aspect-raster x y gis:raster-value elevation-raster x y ]
      ]
;      [
;        gis:set-raster-value slope-raster x y gis:raster-value elevation-raster x y
;      ]
      set y y + 1
    ]
    set x x + 1
  ]
  gis:set-sampling-method slope-raster "bilinear"
  ask patches [
    set slope gis:raster-value slope-raster pxcor (max-pycor - pycor)
;    set aspect gis:raster-value aspect-raster pxcor (max-pycor - pycor)
  ]
end


to set-coordinate-system
  ; Setting the coordinate system while all of our datasets use the same coordinate system.
  gis:load-coordinate-system (word "/data/WGS84.prj")
  set coordsys? true
end
@#$#@#$#@
GRAPHICS-WINDOW
538
10
1274
549
-1
-1
1.8088737201365188
1
1
1
1
1
0
0
0
1
0
402
0
292
0
0
1
Year
30.0

BUTTON
144
12
213
46
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
219
12
293
46
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
415
10
523
45
Display Slope
show-slope
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
303
10
413
44
Display Elevation
show-elevation
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
12
120
295
153
Max-number-of-inhabitants/cell
Max-number-of-inhabitants/cell
20
400
250.0
10
1
NIL
HORIZONTAL

BUTTON
303
116
409
150
Display/Hide Rivers
show-rivers
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
411
116
523
150
Display/Hide Springs
show-springs
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
12
154
295
187
Max-number-of-inhabitants/household
Max-number-of-inhabitants/household
4
30
10.0
1
1
NIL
HORIZONTAL

PLOT
305
402
526
522
Land productivity
NIL
Patches
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"Probability" 0.04 0 -16777216 true "" "histogram [land-productivity] of land-patches"

CHOOSER
144
404
297
449
Subsistence-regime
Subsistence-regime
"Extensive agriculture" "Intensive agriculture"
1

SLIDER
13
273
296
306
Household-migration-radius
Household-migration-radius
2
50
40.0
1
1
Km
HORIZONTAL

SLIDER
12
369
126
402
Years-of-storage
Years-of-storage
1
10
5.0
1
1
NIL
HORIZONTAL

SWITCH
13
305
296
338
Aquifer-proximity-on-migration
Aquifer-proximity-on-migration
0
1
-1000

BUTTON
303
46
523
79
Display Aquifer Density
show-aquifer
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
303
152
523
185
Display/Hide Known Arcaeological Sites
show-sites
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
12
86
295
119
Number-of-initial-settlements
Number-of-initial-settlements
1
40
4.0
1
1
NIL
HORIZONTAL

CHOOSER
12
403
145
448
Social-behavior
Social-behavior
"Independent" "Egalitarian" "Sharing" "Self-Organized (SO)" "Hierarchical (static)"
3

PLOT
305
527
526
647
Land suitability
NIL
Patches
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"default" 0.04 0 -16777216 true "" "histogram [land-suitability] of land-patches"

BUTTON
303
81
523
115
Display Environmental Resources
show-resources
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
379
654
456
699
Households
count households
0
1
11

MONITOR
455
654
528
699
Individuals
sum ([population-size] of settlements)
17
1
11

MONITOR
305
654
379
699
Settlements
count settlements
17
1
11

SLIDER
124
369
297
402
Min-resources-person
Min-resources-person
100
500
250.0
10
1
Kg
HORIZONTAL

SLIDER
13
447
296
480
SO-authority-relation-relative-difference
SO-authority-relation-relative-difference
10
90
60.0
10
1
%
HORIZONTAL

PLOT
1290
12
1650
134
Agents per settlement
NIL
NIL
0.0
10.0
0.0
5.0
true
true
"" ""
PENS
"Superiors" 1.0 0 -13345367 true "" "plot superiorAgentsAll"
"Subordinates" 1.0 0 -8630108 true "" "plot subordinateAgentsAll"
"Peers" 1.0 0 -10899396 true "" "plot peerAgentsAll"
"Agents" 1.0 0 -4539718 true "" "plot agents"

PLOT
1289
259
1647
393
Agents utility per settlement
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Superiors" 1.0 0 -13345367 true "" "plot superiorAgentsAllUtil"
"Subordinates" 1.0 0 -8630108 true "" "plot subordinateAgentsAllUtil"
"Peers" 1.0 0 -10899396 true "" "plot peerAgentsAllUtil"
"Agents" 1.0 0 -4539718 true "" "plot agentsUtil"

PLOT
1290
396
1649
533
Agents storage per settlement
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Superiors" 1.0 0 -13345367 true "" "plot superiorAgentsAllStrg"
"Subordinates" 1.0 0 -8630108 true "" "plot subordinateAgentsAllStrg"
"Peers" 1.0 0 -10899396 true "" "plot peerAgentsAllStrg"
"Agents" 1.0 0 -4539718 true "" "plot agentsStrg"

PLOT
1290
535
1649
672
Agents load per settlement
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Superiors" 1.0 0 -13345367 true "" "plot superiorAgentsAllLoad"
"Subordinates" 1.0 0 -8630108 true "" "plot subordinateAgentsAllLoad"
"Peers" 1.0 0 -10899396 true "" "plot peerAgentsAllLoad"
"Agents" 1.0 0 -4539718 true "" "plot agentsLoad"

SWITCH
12
54
295
87
Random-initial-settlements
Random-initial-settlements
1
1
-1000

SWITCH
136
479
296
512
MDP-decision-making
MDP-decision-making
1
1
-1000

MONITOR
377
702
461
747
Storage (avg)
mean agntStrg
3
1
11

MONITOR
463
703
531
748
Load (avg)
mean agntLd
3
1
11

MONITOR
305
702
376
747
Utility (avg)
mean [utility] of households
3
1
11

MONITOR
407
751
529
796
Migrations/year (avg)
mgrtns / ticks
3
1
11

MONITOR
306
752
408
797
Individuals (avg)
mean [individuals] of households
3
1
11

PLOT
1290
677
1650
797
Accumulated relations changed
NIL
NIL
1.0
6.0
0.0
10.0
true
true
"" ""
PENS
"Relations changed" 1.0 1 -16777216 true "" "histogram relChanges"

TEXTBOX
1550
712
1649
795
1. Acq  -> Auth\n2. Peer -> Auth\n3. Acq  -> Peer\n4. Auth -> Peer\n5. Auth -> Acq\n6. Peer -> Acq
10
0.0
1

SWITCH
10
593
294
626
Evolutionary-selection-dynamics
Evolutionary-selection-dynamics
1
1
-1000

PLOT
1030
677
1277
797
Strategy
NIL
NIL
0.0
3.0
0.0
1.0
true
true
"" ""
PENS
"Strategies" 1.0 1 -16777216 true "" "histogram [strategy] of households"

TEXTBOX
1213
719
1275
762
1. Cooperate\n2. Defect\n3. Tit-for-tat
10
0.0
1

PLOT
1656
137
2006
257
Strategic behavior (%)
NIL
NIL
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"Cooperative" 1.0 0 -13840069 true "" "plot cbehavior"
"Defective" 1.0 0 -2674135 true "" "plot dbehavior"

PLOT
1656
12
2005
132
Agents strategy
NIL
NIL
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"Cooperate" 1.0 0 -13840069 true "" "plot cagents"
"Defect" 1.0 0 -2674135 true "" "plot dagents"
"Tit-for-tat" 1.0 0 -13345367 true "" "plot tftagents"

PLOT
538
552
700
672
Households
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"Households" 1.0 0 -5207188 true "" "plot count households"

CHOOSER
10
626
294
671
Replicator-dynamics
Replicator-dynamics
"None" "Imitation within community" "Imitation within society" "Probabilistic within community" "Probabilistic within society"
3

CHOOSER
200
668
295
713
Time-rate
Time-rate
"8 years" "16 years"
0

PLOT
1657
259
2007
394
Agents utility
NIL
NIL
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"Superiors" 1.0 0 -13345367 true "" "ifelse (count households with [is-superior = true] > 0)\n[ plot mean [utility] of households with [is-superior = true] ]\n[ plot 0 ]"
"Subordinates" 1.0 0 -8630108 true "" "ifelse (count households with [is-subordinate = true] > 0)\n[ plot mean [utility] of households with [is-subordinate = true] ]\n[ plot 0 ]"
"Peers" 1.0 0 -10899396 true "" "ifelse (count households with [is-peer = true] > 0)\n[ plot mean [utility] of households with [is-peer = true] ]\n[ plot 0 ]"
"Agents" 1.0 0 -4539718 true "" "plot mean [utility] of households"

PLOT
1656
396
2008
534
Agents storage
NIL
NIL
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"Superiors" 1.0 0 -13345367 true "" "ifelse (count households with [is-superior = true] > 0)\n[ plot mean [sum storage] of households with [is-superior = true] ]\n[ plot 0 ]"
"Subordinates" 1.0 0 -8630108 true "" "ifelse (count households with [is-subordinate = true] > 0)\n[ plot mean [sum storage] of households with [is-subordinate = true] ]\n[ plot 0 ]"
"Peers" 1.0 0 -10899396 true "" "ifelse (count households with [is-peer = true] > 0)\n[ plot mean [sum storage] of households with [is-peer = true] ]\n[ plot 0 ]"
"Agents" 1.0 0 -4539718 true "" "plot mean [sum storage] of households"

PLOT
1290
138
1649
258
Agent movements
NIL
NIL
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"Migrations   " 1.0 1 -16777216 true "" "plot migrations"

PLOT
1657
537
2007
673
Agents total load per settlement
NIL
NIL
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"Superiors" 1.0 0 -13345367 true "" "plot superiorAgentsAllTotalLoad"
"Subordinates" 1.0 0 -8630108 true "" "plot subordinateAgentsAllTotalLoad"
"Peers" 1.0 0 -10899396 true "" "plot peerAgentsAllTotalLoad"
"Agents" 1.0 0 -4539718 true "" "plot agentsTotalLoad"

CHOOSER
10
668
203
713
Strategy-review
Strategy-review
"Avg reward of all strategies" "Avg reward of same strategy"
1

PLOT
1027
554
1277
674
Hunger level (%)
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (count households with [utility < uThres] / count households)"

SWITCH
13
519
162
552
Volcanic-Eruption
Volcanic-Eruption
1
1
-1000

SLIDER
162
519
296
552
VE-mortality
VE-mortality
0
100
15.0
1
1
%
HORIZONTAL

SWITCH
13
479
136
512
Resettling-cost
Resettling-cost
0
1
-1000

PLOT
700
552
860
672
Setlements
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"Settlements" 1.0 0 -4079321 true "" "plot count settlements"

PLOT
862
552
1022
672
Population
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"Individuals" 1.0 0 -7500403 true "" "plot sum [individuals] of households"

CHOOSER
9
717
133
762
Settlement-interaction
Settlement-interaction
"Off" "XTENT model" "Gravity model"
2

SLIDER
9
761
295
794
Household-surplus-pooled-for-trading
Household-surplus-pooled-for-trading
0
100
20.0
1
1
%
HORIZONTAL

CHOOSER
133
717
295
762
Settlement-importance
Settlement-importance
"Simulation" "Evidence"
1

BUTTON
303
247
525
281
Display/Hide In-Deegree Centrality NW
show-in-degree-network
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
305
322
528
356
Display/Hide Betweeness Centrality NW
show-betweenness-network
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
304
285
527
319
Display/Hide Out-Degree Centrality NW
show-out-degree-network
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
303
358
526
391
Display/Hide Louvain Communities
show-louvain-communities
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
539
676
652
749
Year (BCE)
3100 - ticks
0
1
18

BUTTON
303
205
525
240
Display/Hide Settlement Territorries
show-territories
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
12
186
295
231
Resources-distribution-function
Resources-distribution-function
"Normal" "Uniform" "Exponential" "Gamma" "Poisson"
0

SLIDER
12
232
152
265
Distribution-mean
Distribution-mean
0.1
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
149
232
295
265
Distribution-stdev
Distribution-stdev
0.01
1
0.2
0.01
1
NIL
HORIZONTAL

PLOT
654
677
1029
797
Trading network relative centrality frequencies
NIL
NIL
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"In-degree" 0.05 1 -10899396 true "" "histogram [in-dgr-nrm] of settlements"
"Out-degree" 0.05 1 -13345367 true "" "histogram [out-dgr-nrm] of settlements"
"Betweenness" 0.05 1 -6459832 true "" "histogram [btw-nrm] of settlements"

MONITOR
539
756
652
797
Louvain Communities
louvain-con
2
1
10

PLOT
1659
677
2009
797
Trading network centralization
NIL
NIL
0.0
1.0
0.0
0.1
true
true
"" ""
PENS
"In-degree" 1.0 0 -10899396 true "" "plot in-dgr-index"
"Out-degree" 1.0 0 -13345367 true "" "plot out-dgr-index"
"Betweenness" 1.0 0 -6459832 true "" "plot btw-index"
"Clustering" 1.0 0 -10141563 true "" "plot avg-cluster-cfv"

SLIDER
13
337
297
370
Aquifer-density-radius
Aquifer-density-radius
1
5
2.25
.05
1
Km
HORIZONTAL

SLIDER
13
553
188
586
Water-inundation-inland
Water-inundation-inland
0
500
300.0
20
1
m
HORIZONTAL

SLIDER
184
553
297
586
Sea-level-rise
Sea-level-rise
2
30
30.0
1
1
m
HORIZONTAL

BUTTON
11
13
82
46
NIL
go-all
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## CREDITS AND REFERENCES
<p>
<b>A. Chliaoutakis, G. Chalkiadakis</b>, <i><a href="https://link.springer.com/chapter/10.1007/978-3-030-24209-1_21">AncientS-ABM: A Novel Tool for Simulating Ancient Societies</a></i>, In: Demazeau Y., Matson E., Corchado J., De la Prieta F. (eds) Advances in Practical Applications of Survivable Agents and Multi-Agent Systems: The PAAMS Collection. PAAMS 2019. Lecture Notes in Computer Science, vol 11523. Springer
</p>

<p>
<b>A. Chliaoutakis, G. Chalkiadakis and A. Sarris</b>, <i><a href="http://www.intelligence.tuc.gr/~gehalk/Papers/ccsMinoanABMTheranEruption-CAA-GR-2018.pdf">Employing Agent-based Modeling to Study the Impact of the Theran Eruption on Minoan Society</a></i>, In Proceedings of the 3rd Conference on Computer Applications and Quantitative Methods in Archaeology - Creece (CAA-GR'18), Spreading Excellence in Computer Applications for Archaeology and Cultural Heritage, Limassol, Cyprus, pp. 139-148, June 2018
</p>

<p>
<b>Angelos Chliaoutakis and Georgios Chalkiadakis</b>, <i><a href="https://www.mitpressjournals.org/doi/abs/10.1162/isal_a_020">Evolutionary Game-theoretic Modeling of Past Societies' Social Organization</a></i>, In Proc. of the 14th European Conference on Artificial Life (ECAL-2017), Lyon, France, pp. 98-105, September 2017
</p>

<p>
<b>Angelos Chliaoutakis and Georgios Chalkiadakis</b>, <i><a href="http://link.springer.com/article/10.1007/s10458-016-9325-9">Agent-Based Modeling of Ancient Societies and their Organization Structure</a></i>, Journal of Autonomous Agents and Multi-Agent Systems (JAAMAS), 2016, Volume 30, Issue 6, pp. 1072-1116
</p>

<p>
<b>A. Chliaoutakis, G. Chalkiadakis and A. Sarris</b>, <i><a href="http://www.archaeopress.com/Public/displayProductDetail.asp?id=%7B27710CAF-069B-43D3-A53B-4BB1A293F456%7D">An Application of Agent-Based Modelling and GIS in Minoan Crete</a></i>, In Proceedings of the 43rd Annual Conference on Computer Applications and Quantitative Methods in Archaeology, pp. 479-489, March - April 2015
</p>
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

campsite
false
0
Polygon -7500403 true true 150 11 30 221 270 221
Polygon -16777216 true false 151 90 92 221 212 221
Line -7500403 true 150 30 150 225

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

circle 3
false
0
Circle -16777216 true false 0 0 300
Circle -7500403 true true 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
setup
repeat 20 [ go ]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="GridTUC-Trading" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>brn</metric>
    <metric>in-dgr-avg</metric>
    <metric>in-dgr-std</metric>
    <metric>in-dgr-cfv</metric>
    <metric>out-dgr-avg</metric>
    <metric>out-dgr-std</metric>
    <metric>out-dgr-cfv</metric>
    <metric>btw-avg</metric>
    <metric>btw-std</metric>
    <metric>btw-cfv</metric>
    <metric>in-dgr-index</metric>
    <metric>out-dgr-index</metric>
    <metric>btw-index</metric>
    <metric>avg-cluster-cfv</metric>
    <metric>louvain-con</metric>
    <metric>sum [individuals] of households</metric>
    <metric>count households</metric>
    <metric>count households with [utility &lt; uThres]</metric>
    <metric>count settlements</metric>
    <metric>mean [households-cnt] of settlements</metric>
    <metric>mean [utility] of households</metric>
    <metric>mean [sum storage] of households</metric>
    <metric>migrations</metric>
    <metric>agentsUtil</metric>
    <metric>agents</metric>
    <metric>agentsStrg</metric>
    <metric>agentsLoad</metric>
    <metric>relationChangesFromAcqToAuth</metric>
    <metric>relationChangesFromPeerToAuth</metric>
    <metric>relationChangesFromAcqToPeer</metric>
    <metric>relationChangesFromAuthToPeer</metric>
    <metric>relationChangesFromAuthToAcq</metric>
    <metric>relationChangesFromPeerToAcq</metric>
    <metric>superiorAgents</metric>
    <metric>subordinateAgents</metric>
    <metric>peerAgents</metric>
    <metric>superiorAgentsAll</metric>
    <metric>subordinateAgentsAll</metric>
    <metric>peerAgentsAll</metric>
    <metric>superiorAgentsStrg</metric>
    <metric>subordinateAgentsStrg</metric>
    <metric>peerAgentsStrg</metric>
    <metric>superiorAgentsAllStrg</metric>
    <metric>subordinateAgentsAllStrg</metric>
    <metric>peerAgentsAllStrg</metric>
    <enumeratedValueSet variable="Random-initial-settlements">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-initial-settlements">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Max-number-of-inhabitants/cell">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Max-number-of-inhabitants/household">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Resources-distribution-function">
      <value value="&quot;Normal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Distribution-mean">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Distribution-stdev">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Household-migration-radius">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Aquifer-proximity-on-migration">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Years-of-storage">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Min-resources-person">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Social-behavior">
      <value value="&quot;Self-Organized (SO)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Subsistence-regime">
      <value value="&quot;Intensive agriculture&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SO-authority-relation-relative-difference">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Resettling-cost">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MDP-Decision-making">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Volcanic-Eruption">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VE-mortality">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Evolutionary-selection-dynamics">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Replicator-dynamics">
      <value value="&quot;Probabilistic within community&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Strategy-review">
      <value value="&quot;Avg reward of same strategy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Time-rate">
      <value value="&quot;8 years&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Settlement-interaction">
      <value value="&quot;XTENT model&quot;"/>
      <value value="&quot;Gravity model&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Settlement-importance">
      <value value="&quot;Simulation&quot;"/>
      <value value="&quot;Evidence&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Household-surplus-pooled-for-trading">
      <value value="20"/>
      <value value="80"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
