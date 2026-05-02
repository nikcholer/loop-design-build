# Detailed Case Study: Database Strategy Blocker

This case study demonstrates the "Stop Rather Than Guess" mechanic in action during the development of the [Sample-NYCTraffic-Refresh](https://github.com/nikcholer/Sample-NYCTraffic-Refresh) project.

## The Scenario
The agent was tasked with defining the database schema for collision storage. However, the project was in its early stages, and the specific technology stack for persistence (ORM and Database engine) had not yet been codified in the project's standards or planning documents.

---

## 1. The Blocker (`docs/state/tbd.md`)
**Timestamp:** 2026-04-09 17:10:10

The agent analyzed the task and the environment, recognized the missing information, and generated the following report:

> **Agent Encountered Blocker:** Undefined Database/ORM Technology
> 
> I am assigned to the task "Data Persistence Contracts: Define the Database Schema/ORM Models for collision storage (e.g., SQLite or Postgres)." 
> 
> However, `package.json` does not include any database or ORM dependencies, and `docs/planning.md` does not specify which database technology or ORM should be used.
> 
> ### Potential Options for the Human
> 1. **Option A:** Use SQLite with Prisma (I will install Prisma and configure a local SQLite DB).
> 2. **Option B:** Use SQLite with better-sqlite3 (raw SQL/lightweight).
> 3. **Option C:** Use PostgreSQL with TypeORM or Prisma (requires external DB setup).

---

## 2. The Resolution (`docs/state/tbd-response.md`)
**Timestamp:** 2026-04-09 17:15:22

The human operator reviewed the options and provided the following decision:

> ## Decision
> Please proceed with **Option A**: Use SQLite with Prisma. 
> 
> ## Instructions for Agent
> - Update `docs/planning.md` to formally reflect that the application's data persistence layer leverages Prisma ORM backed by a local SQLite database file.
> - Follow the architectural TDD flow as normal. Begin the red-phase test mapping for Prisma DB schemas on this run.

---

## 3. The Outcome
Following the resolution, the agent:
1. Updated the project's permanent documentation (`planning.md`).
2. Installed the necessary dependencies.
3. Implemented the first "Red" tests for the database model.
4. Committed all changes as a single atomic unit of work with the message: `feat(db): initialize prisma schema for collision data`.

## Why this is a "Portfolio Win"
This sequence demonstrates that the agent is **safety-aware**. Instead of choosing PostgreSQL (which might have added unwanted infrastructure complexity) or raw SQL (which might have violated team preferences for an ORM), the agent paused and asked for a strategic decision. 

This level of auditability and control is essential for deploying AI agents in commercial environments.
