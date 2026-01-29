# AutoGPT: Matherly.net Forked Edition

**AutoGPT** is a powerful platform that allows you to create, deploy, and manage continuous AI agents that automate complex workflows.

## How to Self-Host the AutoGPT Platform

### System Requirements

Before proceeding with the installation, ensure your system meets the following requirements:

#### Hardware Requirements

- CPU: 4+ cores recommended
- RAM: Minimum 8GB, 16GB recommended
- Storage: At least 10GB of free space

#### Software Requirements

- Operating Systems:
  - Linux (Ubuntu 20.04 or newer recommended)
  - macOS (10.15 or newer)
  - Windows 10/11 with WSL2
- Required Software (with minimum versions):
  - **mise** (2026.1.0 or newer) - Development tool manager ([install guide](https://mise.jdx.dev))
  - Docker Engine (20.10.0 or newer)
  - Docker Compose (2.0.0 or newer)
  - Git (2.30 or newer)

**Note:** The following tools are managed automatically by mise:
  - Python 3.13
  - Node.js 22.x
  - pnpm 10.28.2+
  - Poetry 2.3.1+

**Optional:**
  - VSCode (1.60 or newer) or any modern code editor

#### Network Requirements

- Stable internet connection
- Access to required ports (will be configured in Docker)
- Ability to make outbound HTTPS connections

---

### 🧱 AutoGPT Frontend

The AutoGPT frontend is where users interact with our powerful AI automation platform. It offers multiple ways to engage with and leverage our AI agents. This is the interface where you'll bring your AI automation ideas to life:

   **Agent Builder:** For those who want to customize, our intuitive, low-code interface allows you to design and configure your own AI agents.

   **Workflow Management:** Build, modify, and optimize your automation workflows with ease. You build your agent by connecting blocks, where each block     performs a single action.

   **Deployment Controls:** Manage the lifecycle of your agents, from testing to production.

   **Ready-to-Use Agents:** Don't want to build? Simply select from our library of pre-configured agents and put them to work immediately.

   **Agent Interaction:** Whether you've built your own or are using pre-configured agents, easily run and interact with them through our user-friendly      interface.

   **Monitoring and Analytics:** Keep track of your agents' performance and gain insights to continually improve your automation processes.

[Read this guide](https://docs.agpt.co/platform/new_blocks/) to learn how to build your own custom blocks.

### 💽 AutoGPT Server

The AutoGPT Server is the powerhouse of our platform This is where your agents run. Once deployed, agents can be triggered by external sources and can operate continuously. It contains all the essential components that make AutoGPT run smoothly.

   **Source Code:** The core logic that drives our agents and automation processes.

   **Infrastructure:** Robust systems that ensure reliable and scalable performance.

   **Marketplace:** A comprehensive marketplace where you can find and deploy a wide range of pre-built agents.

### 🐙 Example Agents

Here are two examples of what you can do with AutoGPT:

1. **Generate Viral Videos from Trending Topics**
   - This agent reads topics on Reddit.
   - It identifies trending topics.
   - It then automatically creates a short-form video based on the content.

2. **Identify Top Quotes from Videos for Social Media**
   - This agent subscribes to your YouTube channel.
   - When you post a new video, it transcribes it.
   - It uses AI to identify the most impactful quotes to generate a summary.
   - Then, it writes a post to automatically publish to your social media.

These examples show just a glimpse of what you can achieve with AutoGPT! You can create customized workflows to build agents for any use case.

---

### 🚀 Quick Start

```bash
# 1. Install mise (one-time setup)
curl https://mise.run | sh
eval "$(mise activate bash)"  # or zsh - add to ~/.bashrc or ~/.zshrc

# 2. Clone and setup the project
git clone https://github.com/Significant-Gravitas/AutoGPT.git
cd AutoGPT/autogpt_platform

# 3. Trust mise configuration and run setup
mise trust
mise run setup

# 4. Start development
mise run docker:up     # Start infrastructure (Supabase, Redis, RabbitMQ)
mise run backend       # Terminal 1: Start backend server
mise run frontend      # Terminal 2: Start frontend dev server
```

**For detailed setup instructions:** See [docs/platform/getting-started.md](docs/platform/getting-started.md)
**For mise migration:** See [docs/MISE_MIGRATION.md](docs/MISE_MIGRATION.md)

---

### **License Overview:**

🛡️ **Polyform Shield License:**
All code and content within the `autogpt_platform` folder is licensed under the Polyform Shield License. This new project is our in-developlemt platform for building, deploying and managing agents.</br>*[Read more about this effort](https://agpt.co/blog/introducing-the-autogpt-platform)*

🦉 **MIT License:**
We publish additional work under the MIT License in other repositories, such as [GravitasML](https://github.com/Significant-Gravitas/gravitasml) which is developed for and used in the AutoGPT Platform. See also our MIT Licensed [Code Ability](https://github.com/Significant-Gravitas/AutoGPT-Code-Ability) project.

---

### Mission

Our mission is to provide the tools, so that you can focus on what matters:

- 🏗️ **Building** - Lay the foundation for something amazing.
- 🧪 **Testing** - Fine-tune your agent to perfection.
- 🤝 **Delegating** - Let AI work for you, and have your ideas come to life.

Be part of the revolution! **AutoGPT** is here to stay, at the forefront of AI innovation.

&ensp;|&ensp;
**🚀 [Contributing](CONTRIBUTING.md)**

---

## 🤝 Sister projects

### 🔄 Agent Protocol

To maintain a uniform standard and ensure seamless compatibility with many current and future applications, AutoGPT employs the [agent protocol](https://agentprotocol.ai/) standard by the AI Engineer Foundation. This standardizes the communication pathways from your agent to the frontend and benchmark.

---
