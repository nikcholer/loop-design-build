
# AGENTS.md

## Project Overview

This is an MVP for a browser-based RSS reader app. Users enter an RSS XML URL, which the app fetches, parses, and displays as a list of titles with clickable links. Built with a modern frontend stack for simplicity and performance.

## Tech Stack

-   **Build Tool**: Vite (for fast development and production builds).
-   **Framework**: React (using hooks for state and effects).
-   **Language**: TypeScript (for type safety, especially in data parsing).
-   **Styling**: Tailwind CSS (utility-first for rapid, responsive UI).
-   **Dependencies**:
    -   Core: React, React DOM.
    -   Parsing: Use native browser APIs like fetch and DOMParser for RSS XML. Optionally add rss-parser if needed for complex feeds.
    -   Dev Tools: Tailwind plugins, TypeScript, ESLint (with React/TS plugins).

## Setup Instructions

1.  Clone the repo and navigate to the root.
2.  Install dependencies: npm install (or pnpm install if preferred).
3.  Start dev server: npm run dev (opens at [http://localhost:5173](http://localhost:5173)).
4.  Build for production: npm run build.
5.  Preview build: npm run preview.
6.  For Tailwind: Ensure tailwind.config.js and postcss.config.js are set up; run npx tailwindcss init -p if missing.

## Coding Guidelines

-   **Language/Types**: Use TypeScript everywhere. Define interfaces for RSS data (e.g., interface RssItem { title: string; link: string; description?: string; }).
-   **Components**: Functional components with hooks. Keep them small and reusable (e.g., FeedList.tsx, UrlInput.tsx).
-   **State Management**: Use useState and useEffect for fetching and parsing. No external libraries for MVP.
-   **Error Handling**: Implement try-catch for fetch/parse; show user messages (e.g., "Invalid RSS URL").
-   **Styling**: Apply Tailwind classes inline. Aim for responsive design (mobile-first).
-   **Accessibility**: Add basic ARIA attributes (e.g., aria-label on inputs, role="listitem" on feed items). Use semantic HTML.
-   **Performance**: Lazy-load if feeds grow; handle CORS via dev proxy if needed (add to vite.config.ts).
-   **Folder Structure**:
    -   src/: Main source.
        -   components/: Reusable UI (e.g., FeedItem.tsx).
        -   utils/: Helpers (e.g., parseRss.ts).
        -   App.tsx: Root component.
        -   main.tsx: Entry point.
    -   public/: Static assets.
    -   index.html: Vite template.
-   **Naming**: PascalCase for components, camelCase for variables/functions. Descriptive names (e.g., handleFetchRss).

## Testing

-   Use Vitest for unit/integration tests: npm run test.
-   Focus on: Parsing function, component renders, error states.
-   Example: Test parseRss with mock XML data.

## Dos and Don'ts

-   **Do**: Keep code modular; commit often with descriptive messages (e.g., "feat: add RSS parsing").
-   **Do**: Handle edge cases like malformed XML or empty feeds.
-   **Don't**: Add backend oYou said

Is there a good source of dummy data for app dev practice? Could be something like large data set of survey or census data from anywhere in the world or maybe a repo of synthetic stuff for this exact purpose?

## Gemini said

Finding good dummy data is a rite of passage for every developer. Fortunately, the ecosystem has exploded with resources tailored specifically for this, ranging from quick REST endpoints to massive, realistic datasets.

Here is a breakdown of the best sources depending on how you need to consume the data:

### 1. Custom Synthetic Data Generators (The "Build Your Own" Approach)

If you need data to fit a very specific database schema, these tools let you define exactly what you want and spit out thousands of rows.

-   **Mockaroo:** This is arguably the holy grail for developers. You can visually construct your data schema (e.g., id, first_name, email, IP_address, crypto_wallet_address) and download it as JSON, CSV, Excel, or even raw SQL `INSERT` statements. The free tier lets you generate up to 1,000 rows at a time.
    
-   **Faker (Libraries):** If you prefer code, the Faker libraries (available in JavaScript/TypeScript via `Faker.js`, Python via `faker`, PHP, etc.) allow you to write quick scripts to seed your databases with millions of rows of highly realistic fake names, addresses, credit cards, and dates.
    
-   **SDV (Synthetic Data Vault):** An open-source ecosystem that uses machine learning to learn the distribution of a small dataset you provide, and then generates massive amounts of synthetic data that mathematically mirrors the original without exposing real personal info.
    

### 2. Ready-to-Use Mock APIs (For Frontend & Network Practice)

If you don't want to host a database and just need an API to hit so you can practice fetching, state management, and UI rendering, use these:

-   **DummyJSON:** A fantastic, modern placeholder API. It comes pre-loaded with interconnected relational data like products, carts, users, posts, and comments. It even supports simulating authentication tokens and search queries.
    
-   **DummyAPI.io:** Similar to DummyJSON, but specifically rich in social-media-style data (users, posts, pictures, tags, comments).
    
-   **JSONPlaceholder:** The classic, bare-bones REST API. It’s perfect for simple `GET`, `POST`, `PUT`, and `DELETE` requests, though the data itself is a bit generic (standard Latin "lorem ipsum" text).
    

### 3. Massive Real-World Datasets (For Heavy-Duty Processing)

If you want real-world messiness to practice data pipelines, pagination, or heavy queries, public data is the way to go.

-   **Kaggle Datasets:** The ultimate repository for large datasets. You can find everything from "Global YouTube Statistics" to detailed census data and massive user surveys. You can easily download these as CSVs to dump into your own database.
    
-   **Data.gov (and other Gov Portals):** The U.S. government’s open data portal is incredible for census, economic, health, and geographic data. Most countries have an equivalent (like `data.gov.uk`). It’s perfect for practicing map integrations or charting/graphing libraries.
    
-   **AWS Public Datasets:** Amazon hosts a registry of massive datasets (we're talking terabytes of data, like the Enron email corpus or global weather data). It's great if you are practicing backend architecture or big data processing.
    

What kind of app are you building? For instance, do you just need an active REST API to ping from a frontend, or are you looking for a massive CSV file to seed a local database?

You said

It's to showcase agentic coding, phased dev defining boundaries/contracts/TDD followed by sequential tier implementation. The subject matter is less important than its medium complexity, in a way! The data will drive the app requirement, which is actually somewhat realistic for large public datasets that are generated by existing activity rather than in service of software

## Gemini said

That is a brilliant approach. Letting the data dictate the domain constraints perfectly mimics enterprise software development, where you rarely get a greenfield project without legacy data shaping the requirements.

For an agentic coding showcase where you want to highlight strict boundary definition (interfaces/DTOs), Test-Driven Development (TDD), and a tiered rollout (Database -> Data Access Layer -> API -> UI), you need datasets that are **relational, logically sound, but complex enough to require real architectural decisions**.

Here are the best "medium complexity" public datasets that are perfect for letting the data drive the app design:

### 1. The Ergast Formula 1 Dataset (The Relational Goldmine)

This is historical data of all Formula 1 races from 1950 to the present.

-   **Why it’s perfect for your showcase:** It consists of about 14 highly interconnected CSV files (Drivers, Constructors, Circuits, Races, Results, Lap Times, Pit Stops).
    
-   **The Agentic Flex:** The relational depth is exactly "medium." An AI agent will have to define clear foreign-key constraints and complex API contracts (e.g., fetching a specific driver's lap times for a specific race requires joining three tables). It’s ideal for generating strict TypeScript interfaces or OpenAPI specs first, then writing the tests, and finally implementing the logic.
    

### 2. Olist Brazilian E-Commerce Dataset (The Realistic Enterprise)

Available on Kaggle, this dataset contains real (anonymized) commercial data from 100,000 orders made at multiple marketplaces in Brazil.

-   **Why it’s perfect for your showcase:** It has tables for Orders, Customers, Products, Reviews, Geolocation, and Payments. It represents the exact kind of data an ERP or storefront dashboard would consume.
    
-   **The Agentic Flex:** It includes natural edge cases (e.g., cancelled orders, missing delivery dates) that the agent will have to account for when defining business logic and writing TDD edge-case tests. It forces the agent to define boundaries around different domains (e.g., separating the "Billing" contracts from the "Shipping" contracts).
    

### 3. NYC Citi Bike or TLC Taxi Trip Data (The Time-Series / Geospatial Flex)

These are massive, continuously updated datasets provided by New York City detailing millions of taxi rides or bike rentals.

-   **Why it’s perfect for your showcase:** The schema is relatively flat (Trips, Stations/Zones), but the data volume and types (timestamps, latitude/longitude, pricing) are rich.
    
-   **The Agentic Flex:** It naturally drives a different kind of app requirement—like an analytics dashboard or an aggregation service. The agentic workflow would need to focus heavily on data ingestion boundaries, writing tests for data transformation/aggregation logic (e.g., grouping rides by hour and neighborhood), and setting up caching tiers.
    

### 4. The "Sakila" or "Northwind" Classics

These are sample databases originally created by MySQL and Microsoft, respectively, to demonstrate database features.

-   **Why it’s perfect for your showcase:** Sakila models a Blockbuster-style DVD rental store (Actors, Films, Inventory, Rentals, Payments). Northwind models a global import/export company.
    
-   **The Agentic Flex:** Because these schemas are industry standards for tutorials, LLMs are incredibly familiar with them. If your primary goal is to showcase the _process_ (the phasing, the TDD, the agent's ability to stick to the contract) rather than the novelty of the app itself, using a universally understood schema ensures the agent won't hallucinate structural relationships and can focus purely on generating high-quality, tiered code.
    

Are you driving this agentic process using a specific orchestration framework (like LangGraph or AutoGen), or are you building a custom prompt loop to manage the TDD hand-offs?

You said

Custom loop is the key concept, using a Skill to enforce backlog management, git discipline and handover doc generation for seamless breaks between sessions.

## Gemini said

That is exactly how you solve the context window amnesia problem. Relying on a continuous, infinitely expanding prompt is a trap; forcing the agent to serialize its state, commit its work, and write its own "shift change" documentation is how you build reliable, resilient AI workflows.

When you pair this custom state-management loop with a data-driven approach (like the Olist or Ergast datasets), the dataset essentially becomes the project manager.

Here is how your three-pillar Skill system perfectly aligns with a phased, data-first TDD methodology:

### 1. The Backlog Management Skill (Data as the Epic Generator)

Because the app's requirements are driven by an existing relational dataset, the backlog practically writes itself. Your Skill can instruct the agent to inspect the data schema and generate an execution plan.

-   **Phase 1 (The Contracts):** The backlog dictates that the agent must first read the CSV headers or SQL dumps and generate strict DTOs/Interfaces (e.g., `OrderDTO`, `CustomerDTO`).
    
-   **Phase 2 (The TDD Boundary):** The backlog creates tickets to write the mock data generators and the failing unit tests for the API routes based on those interfaces.
    
-   **Phase 3 (The Implementation):** Only then does the backlog allow the agent to write the actual business logic to make the tests pass.
    

### 2. Git Discipline (Enforcing the TDD Loop)

Git isn't just for version control here; it's the enforcement mechanism for the agent's behavior.

-   By strictly requiring the agent to commit in atomic chunks, you prevent it from hallucinating massive, unverified rewrites.
    
-   A successful loop enforces a rhythm: `commit (failing test)` -> `commit (implementation)` -> `commit (refactor)`.
    
-   If a session crashes or an implementation goes off the rails, you don't have to decipher a massive broken file; you just `git reset --hard` to the last green test state and restart the loop.
    

### 3. Handover Doc Generation (The Context Bridge)

This is the most critical piece for seamless session breaks. When an agent spins down, it needs to leave a high-density "you are here" map for the next instance that spins up. A great handover doc for this kind of tiered development should include:

-   **Current Tier Focus:** (e.g., "Currently implementing Data Access Layer for the Orders domain").
    
-   **State of the TDD Loop:** "Test `should_fail_when_order_date_is_missing` is currently RED."
    
-   **Active Constraints:** "Must adhere to `IOrder` interface; do not modify the schema."
    
-   **Next Steps:** Popped directly from the Backlog Skill.
    

This setup strips away the novelty of the UI/UX and focuses entirely on the rigorous engineering mechanics of AI agents respecting contracts, tests, and state.

Are you standardizing the handover documents in a machine-readable format like JSON/YAML for strict parsing, or are you sticking to structured Markdown so it's easily readable by both the LLM context window and yourself?

You said

I think Markdown, since the content will be largely natural language it seems a bit contrived to structure it for deterministic parsing, no?

## Gemini said

You are spot on. Forcing paragraphs of natural language into JSON string values is a recipe for escape-character nightmares, token bloat, and brittle parsing.

Markdown is quite literally the native tongue of modern LLMs. Because their training data is so heavily weighted with markdown-formatted documentation and repositories, they inherently understand its semantic hierarchy without needing a deterministic parser.r auth for MVP—client-side only.
-   **Don't**: Over-style; stick to Tailwind basics for speed.
-   **Don't**: Use heavy libs unless necessary (e.g., avoid Axios if fetch suffices).

## Additional Notes

-   For persistence (e.g., saving URLs): Use localStorage simply if expanding beyond MVP.
-   Deployment: Target Vercel/Netlify; add scripts if needed.
-   Update this file as the project evolves for better agent guidance.