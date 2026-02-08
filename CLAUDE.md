# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CreatorPulse is a Phoenix LiveView application for tracking and analyzing YouTube channels. It fetches channel data from the YouTube Data API v3 and displays analytics.

**Tech Stack:**
- Phoenix 1.8.3 (LiveView for real-time UI)
- Ecto 3.13 (PostgreSQL database)
- Tailwind CSS for styling
- Bandit web server

## Development Commands

### Setup
```bash
mix setup              # Install dependencies, create DB, migrate, build assets
```

### Database
```bash
mix ecto.create        # Create database
mix ecto.migrate       # Run migrations
mix ecto.reset         # Drop and recreate database (drop + setup)
```

### Server
```bash
mix phx.server         # Start Phoenix server (runs on localhost:4000)
iex -S mix phx.server  # Start server with IEx console
```

### Assets
```bash
mix assets.setup       # Install Tailwind and esbuild
mix assets.build       # Compile assets
mix assets.deploy      # Build and minify assets for production
```

### Testing
```bash
mix test               # Run all tests (creates test DB, migrates, then tests)
mix test test/path/to/test.exs  # Run specific test file
```

### Code Quality
```bash
mix format             # Format code
mix compile --warnings-as-errors  # Compile with warnings as errors
mix precommit          # Run full precommit checks (compile, deps.unlock, format, test)
```

## Architecture

### Application Structure

**Contexts Pattern:**
- `CreatorPulse.Analytics` - Main context for managing channels (CRUD operations)
  - `CreatorPulse.Analytics.Channel` - Ecto schema for channels table

**YouTube Integration:**
- `CreatorPulse.YoutubeAPI` - Module for fetching channel data from YouTube API v3
  - Uses `Req` for HTTP requests
  - Requires `YT_API_KEY` environment variable
  - `get_channel_info/1` - Fetches channel snippet by YouTube channel ID

**Web Layer:**
- `CreatorPulseWeb.Router` - Routes configuration
  - Browser pipeline for HTML/LiveView
  - API pipeline (currently unused, reserved for future)
  - LiveView routes for channels at `/channels`
- LiveViews in `lib/creator_pulse_web/live/channel_live/`:
  - `Index` - List and create channels
  - `Show` - View individual channel details
  - `Form` - Form component for creating/editing channels

### Database Schema

**channels table:**
- `youtube_id` (string, required) - YouTube channel ID
- `title` (string, required) - Channel title from YouTube
- `thumbnail` (string, optional) - Channel thumbnail URL
- `description` (text, optional) - Channel description
- `timestamps` - UTC datetime timestamps

### Environment Variables

Required in `.env` or system environment:
- `YT_API_KEY` - YouTube Data API v3 key for fetching channel information

### Development Tools

- **LiveDashboard** - Available at `/dev/dashboard` in development
- **Swoosh Mailbox Preview** - Available at `/dev/mailbox` in development
- **Hot Reload** - Code reloading enabled in development for:
  - Static assets in `priv/static/`
  - Router
  - Controllers, LiveViews, Components
