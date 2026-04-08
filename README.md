# 🚀 Rocket.Chat ARM64 Docker Images

Docker images for Rocket.Chat optimized for ARM64/AArch64 architecture.

## 📦 Available Images

| Version | Tag | Status |
|---------|-----|--------|
| 8.1.0 | `systemcrashpoa/nerdseverino:RC.8.3.0-arm64` | ✅ Latest |
| 8.0.1 | `systemcrashpoa/nerdseverino:RC.8.3.0-arm64` | ⚠️ Deprecated |
| 8.0.0 | `systemcrashpoa/nerdseverino:RC.8.3.0-arm64` | ⚠️ Deprecated |

## 🚀 Quick Start

```bash
# Create docker-compose.yml
services:
  rocketchat:
    image: systemcrashpoa/nerdseverino:RC.8.3.0-arm64
    restart: unless-stopped
    environment:
      - ROOT_URL=http://localhost:3000
      - MONGO_URL=mongodb://mongo:27017/rocketchat?replicaSet=rs0
      - MONGO_OPLOG_URL=mongodb://mongo:27017/local?replicaSet=rs0
    ports:
      - "3000:3000"
    depends_on:
      - mongo

  mongo:
    image: mongo:7
    restart: unless-stopped
    command: mongod --replSet rs0 --oplogSize 128
    volumes:
      - mongo_data:/data/db

volumes:
  mongo_data:
```

## 🏗️ Building

Images are automatically built via GitHub Actions when pushing to version branches (`8.*`).

## 🔧 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ROOT_URL` | Your Rocket.Chat URL | `http://localhost:3000` |
| `MONGO_URL` | MongoDB connection string | Required |
| `MONGO_OPLOG_URL` | MongoDB oplog URL | Required |
| `PORT` | Application port | `3000` |

## 📊 Architecture

- **Base**: Node.js 22 on Debian Bookworm Slim
- **Architecture**: ARM64/AArch64 only
- **Deno**: v1.43.5 included
- **Sharp**: Optimized for ARM64

## 🤝 Contributing

1. Create version branch: `git checkout -b 8.x.x`
2. Update `RC_VERSION` in Dockerfile
3. Update tag in workflow
4. Push and wait for build

## 📝 License

Same as original Rocket.Chat project.
