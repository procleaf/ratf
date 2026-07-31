# RATF — Ruby Automation Test Framework

A full-featured web application for managing, executing, and analyzing automated tests. Built with **Ruby on Rails 8.1** and **SQLite3**.

## Overview

RATF provides a complete platform for test automation teams:

- **Test Case Management** — Create, edit, import/export, and clone test suites and test cases
- **Live Test Execution** — Run shell commands, Selenium browser tests, Appium mobile tests, and natural-language tests
- **Job Scheduling** — Cron-based scheduling with queue management
- **Worker Management** — Register and monitor distributed test workers
- **Issue Tracker** — Full bug tracking with status workflow, comments, and emoji reactions
- **Knowledge Base** — Team wiki for documentation
- **Role-Based Access Control** — Admin, manager, and user roles
- **Internationalization** — English and Chinese (中文) support
- **Dark/Light Theme** — System-aware theme with manual toggle
- **REST API** — JWT-authenticated API for CI/CD integration
- **Cloud Provider Management** — Provision and monitor cloud instances

## Tech Stack

| Component | Technology |
|---|---|
| **Framework** | Ruby on Rails 8.1.3 |
| **Ruby** | 3.4.9 |
| **Database** | SQLite3 |
| **Frontend** | Hotwire (Turbo + Stimulus), Chart.js, vanilla JS |
| **CSS** | Custom CSS with CSS variables (light/dark themes) |
| **Auth** | BCrypt + session-based + RBAC |
| **Queue** | SolidQueue |
| **Cache** | SolidCache |
| **Testing** | Minitest (240 model tests, 200+ controller/integration tests) |
| **Selenium** | selenium-webdriver (browser automation) |
| **Appium** | appium_lib (mobile automation) |
| **CLI** | Thor-based CLI (`bin/ratf`) |

## Quick Start

```bash
# Clone and setup
cd ratf/webui
bundle install
bin/rails db:setup

# Seed demo data (users, test cases, jobs, etc.)
bin/rails db:seed

# Start the server
bin/rails server

# Open in browser
open http://localhost:3000
```

Default login after seeding: `admin@ratf.local` / `password123`

## Project Structure

```
ratf/webui/
├── app/
│   ├── controllers/       # 41 controllers (REST, API, nested)
│   ├── models/            # 34 models with validations, scopes, callbacks
│   ├── views/             # 129 ERB templates
│   ├── services/          # Test runners (shell, Selenium, Appium, NL)
│   ├── javascript/        # Stimulus controllers (8 controllers)
│   └── assets/            # CSS with dark/light theme
├── config/
│   ├── routes.rb          # 132 lines, RESTful + nested + API
│   └── locales/           # en.yml (267 keys) + zh.yml (267 keys)
├── db/
│   ├── migrate/           # 33 migrations
│   └── seeds.rb           # Demo data: 6 users, 8 suites, 34 cases, etc.
├── lib/
│   ├── ratf_cli.rb        # Thor CLI (18 commands)
│   └── ratf_cli/          # CLI formatting helpers
├── test/                  # 54 test files (fixtures, models, controllers, integration)
└── bin/
    ├── rails              # Rails commands
    └── ratf               # CLI entry point
```

## Features

### Test Case Manager
- **Write test cases online** — Steps, preconditions, expected results as structured data
- **Batch edit** — Edit all cases in a suite on one page
- **Import/Export YAML** — Paste YAML to import, download YAML to export
- **Clone suites** — Duplicate a suite with all test cases
- **Favorites** — Star test cases for quick access with toggle button

### Test Execution
- **Shell commands** — `echo`, `hostname`, `whoami`, etc. (with security whitelist)
- **Selenium WebDriver** — Browser automation with Chrome, Firefox, Safari
- **Appium** — Mobile app automation for Android and iOS
- **Natural Language** — Write tests in plain English ("Click the login button")
- **Live output** — Logs saved and viewable in terminal-style viewer with line numbers

### Dashboard
- **Stats summary** — Total jobs, running, queued, workers, success rate, avg duration
- **Distribution cards** — Test results, job status, worker status with colored badges
- **Recent activity** — Last 8 job runs with status and duration
- **Flaky test detection** — Tests with ≥5 runs and <90% pass rate
- **Slowest tests** — Top 10 slowest test runs

### Jobs & Scheduling
- **Job management** — Create, queue, run, monitor jobs
- **Job runs** — Track execution history with timing
- **Cron scheduling** — Schedule recurring jobs with cron expressions
- **Agents** — Distributed test execution workers
- **Artifacts** — Upload and manage job output files

### Issues (Bug Tracker)
- **Full workflow** — Open → In Progress → Resolved → Closed → Reopened
- **Severity & urgency** — Prioritize with 5 severity levels + 4 urgency levels
- **Comments** — Threaded comments with Markdown support
- **Emoji reactions** — 👍 😄 🎉 🚀 👀 💯 on comments
- **Attachments** — File uploads via Active Storage
- **Assignments** — Assign issues to team members
- **Linked test cases** — Trace issues back to failing tests

### Cloud Management (Alibaba Cloud ECS-style)
- **Cloud providers** — AWS, GCP, Azure, private cloud
- **Cloud instances** — Provision, start, stop, terminate instances
- **Cost tracking** — Hourly cost estimates
- **Private cloud** — Per-user providers, scoped visibility

### Security
- **Command sanitization** — Shell test steps validated against whitelist
- **RBAC** — Admin, manager, user roles with granular permissions
- **JWT API auth** — Bearer token authentication for API endpoints
- **CSRF protection** — Rails defaults
- **BCrypt passwords** — Secure password hashing

### API (REST JSON)

```
GET  /api/v1/health              # Public health check
GET  /api/v1/jobs                # List jobs (auth required)
POST /api/v1/jobs                # Create job
GET  /api/v1/workers             # List workers
GET  /api/v1/results             # List test results
```

### CLI

```bash
bin/ratf dashboard                # Dashboard summary
bin/ratf jobs                     # List jobs
bin/ratf jobs:show 1              # Job detail
bin/ratf workers                  # Worker status
bin/ratf suites                   # Test suites
bin/ratf results:failed           # Recent failures
bin/ratf health                   # System health check
bin/ratf search "timeout"         # Cross-model search
```

## Configuration

### Timezone
Set in `config/application.rb`:
```ruby
config.time_zone = "Beijing"  # Asia/Shanghai (UTC+8)
```

### Theme
Click ☀️/🌙/💻 in the sidebar footer. Persisted in `localStorage`.

### Language
Click EN/中文 in the sidebar footer. Persisted via URL parameter and cookie.

## Testing

```bash
# Run all tests
bin/rails test

# Model tests only
bin/rails test test/models

# Controllers only
bin/rails test test/controllers
```

## Models

| Count | Categories |
|---|---|
| 34 models | User, Job, Worker, TestSuite, TestCase, TestResult, Issue, Schedule, ApiToken, CloudProvider, CloudInstance, WikiPage, Favorite, AuditLog, Notification, CommentReaction, LogComment, and more |

## Internationalization

Supports English (default) and Chinese (中文). 267 translation keys each.

Switch language via:
- Sidebar toggle (EN / 中文)
- URL: `/?locale=zh`
- Cookie persistence

## License

MIT
