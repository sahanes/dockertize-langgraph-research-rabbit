# dockertize-langgraph-research-rabbit
Dockertize the target project (langgraph-research-rabbit)

This repository contains the Dockerfile and docker-compose configuration for containerizing the Langgraph and Research Rabbit setup.

## Features
- Simplified deployment of Langgraph and Research Rabbit using Docker.
- Supports Redis and PostgreSQL as dependencies.
- Includes health checks and volume mapping for reliability.

## Summary of Updates in Docke-composer.yaml

| **Section**            | **Original**                | **Updated**                     | **Reason**                                                                                  |
|-------------------------|-----------------------------|----------------------------------|---------------------------------------------------------------------------------------------|
| `version`              | Not specified               | `version: "3.9"`                | Ensures compatibility with Docker Compose features.                                         |
| `healthcheck.test`     | Command as a string         | Proper array (`["CMD", ...]`)   | Ensures proper parsing and execution by Docker.                                             |
| `langgraph-api ports`  | `8123:8000`                 | `2024:2024`                     | Reflects the actual port used by the application.                                           |
| `langgraph-api image`  | `${IMAGE_NAME}`             | Build from `Dockerfile`         | Builds the image locally instead of relying on a pre-built image(Docker fails as this image does not exist yet).                          |
| `langgraph-redis ports`| Not exposed                | `6379:6379`                     | Exposed Redis port for debugging.                                                          |
| `langgraph-postgres`   | Basic health check          | Detailed `start_period`, etc.   | Improves health check robustness and reliability.                                           |

**Reasons:**
- Version Decleration: "3.9" is recommended for compatibility with newer Docker Compose configurations.
- healthcheck.test Format: Docker requires test to be a proper array, either as ``` ["CMD", "command"]``` or ```["CMD-SHELL", "shell_command"]```. This ensures correct parsing and execution of the healthcheck commands.
- ports Mapping for langgraph-api: First, I set the inputbound and output bound ports be 2024 on my Windows Defender Firewall. This reflects the correct internal port so that the application is accessible on the expected port.
- image vs. build for langgraph-api: Assuming that an image is pre-built and tagged as ${IMAGE_NAME}, if such an image does not exist, docker-compose will fail. The updated configuration builds the image locally - using the provided Dockerfile and source code in the current directory (```context: .```).

- Volumes Definition for langgraph-api ```volumes:
  -./src:/deps/research-rabbit/src # Maps the project source directory for live updates and access```

    This allows the container to access the application code and ensures consistency with the PYTHONPATH.
- Adding Exposed Ports for langgraph-redis: xposing port 6379 for langgraph-redis is optional but helpful for debugging purposes if you need to interact with Redis directly from the host system.
- environment update: Ensuring all environment variables (e.g., REDIS_URI, POSTGRES_URI, API keys) are passed into the container for langgraph-api ensures the application can connect to the appropriate services.```HOST: "0.0.0.0"
      PORT: "2024"
      LANGSMITH_ENDPOINT: "https://api.smith.langchain.com"
      CORS_ALLOW_ORIGINS: "https://smith.langchain.com"
      CORS_ALLOW_CREDENTIALS: "true"
      CORS_ALLOW_HEADERS: "*"```

- Added the command field: This ensures the container executes the start.sh script as the main startup process. ```command: /start.sh```


## Summary of Key Points in Dockerfile

- **Startup Script (start.sh):** A `start.sh` script was created to manage the application startup and set environment variables:
  
  ```bash
  #!/bin/sh
  export PYTHONPATH=/deps/research-rabbit
  export PATH=/usr/local/bin:$PATH
  /usr/local/bin/langgraph dev --host 0.0.0.0 --port 2024


  Purpose:
  -  Set PYTHONPATH: Points to ```/deps/research-rabbit``` to ensure the application has access to project files.
  -  Add /usr/local/bin to PATH: Ensures the langgraph CLI can be found during execution.
  -  Run langgraph dev: Starts the application on host 0.0.0.0 and port 2024.

- **Dockerfile Command:**

  ```bash
  RUN echo '#!/bin/sh\n\
  export PYTHONPATH=/deps/research-rabbit\n\
  export PATH=/usr/local/bin:$PATH\n\
  /usr/local/bin/langgraph dev --host 0.0.0.0 --port 2024\n\
  ' > /start.sh && chmod +x /start.sh

- Installation of langgraph-cli: Installed the langgraph-cli with in-memory support:```bash RUN pip install --upgrade pip && \
    pip install "langgraph-cli[inmem]" && \
    pip install -e . && \
    find /usr/local/bin -name "langgraph*"  # Debug: find the executable```

Purpose:
-  Ensures the langgraph-cli is available globally in the container.
-  Allows debugging to verify the CLI installation and path.

- Command to Use the Startup Script: Ensured the container runs the start.sh script as the main entry point: ```CMD ["/start.sh"]```

## Getting Started
1. Clone the repository:
   ```bash git clone https://github.com/langchain-ai/research-rabbit.git
    cd research-rabbit```

2. Create the updated docker-composer.yaml file as in this repository
3. Create the Dockerfile as in this repository
4. Create your .env file with also having the name for your image included as research-rabbit added (TAVILY_API_KEY and LANGSMITH_API_KEY)
5. login Docker desktop
6. run the command in the same directory: ```bash docker-compose up --build```
7. If everything works fine, you should be able to access langraph Studio right from your Windows machine! Amazing!!!:

    API: http://127.0.0.1:2024
    Studio UI: https://smith.langchain.com/studio/?baseUrl=http://127.0.0.1:2024
