sequenceDiagram
  participant Engine
  participant Bot1
  participant Bot2
  participant Bot3

  Note right of Engine:Introduce yourself
  Engine->>+Bot1:GET /name
  Engine->>+Bot2:GET /name
  Engine->>+Bot3:GET /name
  Bot1-->>-Engine:bot1's name
  Bot3-->>-Engine:bot3's name
  Bot2-->>-Engine:bot2's name

  Note right of Engine:Start game
  Engine->>+Bot1:POST /{gameId}/startGame
  Bot1-->>-Engine:OK
  Engine->>+Bot2:POST /{gameId}/startGame
  Bot2-->>-Engine:OK
  Engine->>+Bot3:POST /{gameId}/startGame
  Bot3-->>-Engine:OK

  Note right of Engine:Find the murderer
  Note right of Engine:Round 1, Bot1's turn
  Engine->>+Bot1:POST /{gameId}/askQuestion
  Bot1-->>-Engine:Question (Suspect, Weapon, Room)
  Engine->>+Bot2:POST /{gameId}/giveAnswer
  Bot2-->>-Engine:Suspect or Weapon or Room or Nothing
  Engine->>+Bot3:POST /{gameId}/observe
  Bot3-->>-Engine:OK

  Note right of Engine:Round 2, Bot2's turn
  Engine->>+Bot2:POST /{gameId}/askQuestion
  Bot2-->>-Engine:Question (Suspect, Weapon, Room)
  Engine->>+Bot3:POST /{gameId}/giveAnswer
  Bot3-->>-Engine:Suspect or Weapon or Room or Nothing
  Engine->>+Bot1:POST /{gameId}/observe
  Bot1-->>-Engine:OK

  Note right of Engine:Round 3, Bot3's turn
  Engine->>+Bot3:POST /{gameId}/askQuestion
  Bot3-->>-Engine:Question (Suspect, Weapon, Room)
  Engine->>+Bot1:POST /{gameId}/giveAnswer
  Bot1-->>-Engine:Suspect or Weapon or Room or Nothing
  Engine->>+Bot2:POST /{gameId}/observe
  Bot2-->>-Engine:OK

  Note right of Engine:...
  Note right of Engine:Round N, Bot2's turn, Bot2 accuse
  Engine->>+Bot2:POST /{gameId}/askQuestion
  Bot2-->>-Engine:Accusation (Suspect, Weapon, Room)
  Engine->>+Bot2:POST /{gameId}/observe
  Bot2-->>-Engine:OK
  Engine->>+Bot3:POST /{gameId}/observe
  Bot3-->>-Engine:OK
  Engine->>+Bot1:POST /{gameId}/observe
  Bot1-->>-Engine:OK
