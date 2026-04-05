# Project Monarch: Monopoly-Style Vertical Slice

A mobile game development project designed to demonstrate **Release Management** best practices, build orchestration, and live-ops scalability.

## 🛠 Tech Stack
| Component | Tool |
| :--- | :--- |
| **Engine** | Godot 4 (Mobile Renderer) |
| **Hardware** | Mac mini & iPad |
| **CI/CD** | GitHub Actions |
| **Assistant** | Claude Code (Pro) |

## 🚀 Release Strategy
* **Main Branch:** Production-ready "Gold Master" builds.
* **Develop Branch:** Integration branch for new feature "Pods."
* **Feature Flags:** Core systems are decoupled from content to allow for "Go/No-Go" decisions at the toggle level.

## ✅ Go/No-Go Checklist
- [ ] **Build Stability:** Does the project export to `.aab` (Android) and Xcode without errors?
- [ ] **Smoke Test:** Does the player move and wrap around the board correctly?
- [ ] **Risk Assessment:** Are there any known "crashes" in the current build tag?
