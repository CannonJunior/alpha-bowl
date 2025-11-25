# Alpha Bowl - Task List

**Project Start Date**: 2025-11-23

---

## Active Tasks

### Foundation Setup
- [ ] Initialize Flutter project structure (2025-11-23)
- [ ] Port Warchief core rendering system (2025-11-23)
- [ ] Port camera system with football-specific modes (2025-11-23)
- [ ] Port input manager with football controls (2025-11-23)
- [ ] Set up WebGL renderer integration (2025-11-23)

### Data Models
- [ ] Create Player entity model (2025-11-23)
- [ ] Create Ball entity model (2025-11-23)
- [ ] Create Team entity model (2025-11-23)
- [ ] Create Play data model (2025-11-23)
- [ ] Create Formation data model (2025-11-23)
- [ ] Create GameState model (2025-11-23)

### Core Systems
- [ ] Implement PhysicsSystem for ball dynamics (2025-11-23)
- [ ] Implement PlaySystem for play execution (2025-11-23)
- [ ] Implement PlayerAISystem for AI behaviors (2025-11-23)
- [ ] Implement GameplaySystem for tackles/catches (2025-11-23)
- [ ] Implement ProgressionSystem for RPG mechanics (2025-11-23)

### Field & Rendering
- [ ] Create football field mesh (100 yards + end zones) (2025-11-23)
- [ ] Add yard line markers (2025-11-23)
- [ ] Add hash marks (2025-11-23)
- [ ] Create football mesh (2025-11-23)
- [ ] Create player mesh with jersey numbers (2025-11-23)

### Game Mechanics
- [ ] Implement basic player movement (2025-11-23)
- [ ] Implement ball throwing mechanics (2025-11-23)
- [ ] Implement ball catching mechanics (2025-11-23)
- [ ] Implement tackle mechanics (2025-11-23)
- [ ] Implement fumble mechanics (2025-11-23)
- [ ] Implement scoring system (2025-11-23)

### AI Behaviors
- [ ] Implement route running AI (2025-11-23)
- [ ] Implement defensive pursuit AI (2025-11-23)
- [ ] Implement blocking AI (2025-11-23)
- [ ] Implement coverage AI (man-to-man) (2025-11-23)
- [ ] Implement coverage AI (zone) (2025-11-23)

### UI Components
- [ ] Create scoreboard widget (2025-11-23)
- [ ] Create play selection HUD (2025-11-23)
- [ ] Create formation selector (2025-11-23)
- [ ] Create player stats panel (2025-11-23)
- [ ] Create minimap widget (2025-11-23)
- [ ] Create pause menu (2025-11-23)

### RPG Features
- [ ] Implement player attributes system (2025-11-23)
- [ ] Implement XP gain from gameplay (2025-11-23)
- [ ] Implement skill tree structure (2025-11-23)
- [ ] Implement special abilities (2025-11-23)
- [ ] Implement player progression UI (2025-11-23)

### Configuration
- [ ] Create game_config.dart (2025-11-23)
- [ ] Create plays_config.dart with initial playbook (2025-11-23)
- [ ] Create formations_config.dart (2025-11-23)
- [ ] Create attributes_config.dart (2025-11-23)
- [ ] Create progression_config.dart (2025-11-23)

### Testing
- [ ] Write unit tests for PhysicsSystem (2025-11-23)
- [ ] Write unit tests for GameplaySystem (2025-11-23)
- [ ] Write unit tests for PlayerAI (2025-11-23)
- [ ] Write integration tests for play execution (2025-11-23)
- [ ] Performance testing (60 FPS with 22 players) (2025-11-23)

---

## Completed Tasks

_None yet - project just started_

---

## Discovered During Work

_Tasks discovered during development will be added here_

---

## Future Enhancements (Post-MVP)

- [ ] Add gamepad/controller support
- [ ] Add sound effects and music
- [ ] Add advanced animations (running, tackling, celebrating)
- [ ] Add weather effects (rain, snow, wind)
- [ ] Add replay system
- [ ] Add multiplayer support
- [ ] Add franchise mode
- [ ] Add custom team creation
- [ ] Add player editor
- [ ] Add achievement system

---

## Notes

- **Priority**: Focus on MVP (single play mode) first
- **Port Policy**: Maximum code reuse from Warchief where applicable
- **Configuration**: All values in config files, never hardcoded
- **Port**: Application runs on port 9009
- **Testing**: Unit tests required for all new systems

---

**Last Updated**: 2025-11-23
