# WhereIsMyBus

WhereIsMyBus is a real-time bus tracking application prototype built for the 24-hour Smart India Hackathon.

## Repository Overview

This repository currently contains the **Backend Foundation** for the WhereIsMyBus project.

## Getting Started

### Prerequisites

- Node.js (v18+ recommended)
- npm

### Installation

Navigate to the `backend` directory and install the dependencies:

```bash
cd backend
npm install
```

### Running the Development Server

Start the development server with Node's built-in watch mode:

```bash
npm run dev
```

The server will run on `http://localhost:3000`.

### Testing Health Endpoint

To verify the server is running correctly, make a `GET` request to the health endpoint:

```bash
curl http://localhost:3000/health
```

Expected response:

```json
{
  "status": "healthy"
}
```
