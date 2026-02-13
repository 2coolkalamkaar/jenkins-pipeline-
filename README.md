# Flask App with Jenkins CI/CD Pipeline

This project is a simple Task Manager application built with **Flask** (Python), containerized with **Docker**, and deployed using a comprehensive **Jenkins CI/CD pipeline**.

## 🚀 Features

*   **Web Application:** A simple Todo/Task manager built with Flask.
*   **CI/CD Pipeline:** Automated pipeline using Jenkins.
*   **Dockerized:** Application is containerized for portability.
*   **Parallel Execution:** Builds Docker images and deploys to production server in parallel.
*   **Security Scanning:** Integrated **Trivy** image scanning to detect vulnerabilities.
*   **Automated Deployment:** Deploys artifacts to a production server via SSH and systemd.

## 🛠️ Technology Stack

*   **Backend:** Python, Flask
*   **Containerization:** Docker
*   **CI/CD:** Jenkins (Groovy Pipeline)
*   **Security:** Trivy (Aqua Security)
*   **OS:** Linux (Debian/Ubuntu)

## 📂 Project Structure

```
├── app.py              # Main Flask application
├── Dockerfile          # Docker configuration
├── Jenkinsfile         # CI/CD Pipeline definition
├── requirements.txt    # Python dependencies
├── templates/          # HTML templates
│   └── index.html      # Main page
└── README.md           # Documentation
```

## ⚙️ Setup & Installation

### Local Development

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/2coolkalamkaar/jenkins-pipeline-.git
    cd jenkins-pipeline-
    ```

2.  **Create a Virtual Environment:**
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```

3.  **Install Dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Run the App:**
    ```bash
    python app.py
    ```
    Access at `http://localhost:5000`.

### Docker Usage

1.  **Build the Image:**
    ```bash
    docker build -t task-manager .
    ```

2.  **Run Container:**
    ```bash
    docker run -p 5000:5000 task-manager
    ```

## 🔄 Jenkins Pipeline Overview

The `Jenkinsfile` defines the following stages:

1.  **Setup:** Installs necessary build tools/dependencies (e.g., Flask).
2.  **Package Code:** Zips the application source code for deployment.
3.  **Parallel Stage:**
    *   **Deploy to Prod:** 
        *   Transfers `myapp.zip` and a generated `deploy.sh` script to the production server via SCP.
        *   Executes the deployment script via SSH to unzip, update dependencies, and restart the `flaskapp` systemd service.
    *   **Build Docker Image:** Builds the Docker image concurrently.
4.  **Trivy Image Scan:** Scans the built Docker image for **HIGH** and **CRITICAL** vulnerabilities using a Trivy container.
5.  **Push to Docker Hub:** Logs in to Docker Hub and pushes the tagged image (`latest` + Build Number).

## 🔑 Configuration Requirements

To run this pipeline, you need the following **Jenkins Credentials**:

| ID | Type | Description |
| :--- | :--- | :--- |
| `prod-dash-server-dash-IP` | Secret Text | Public IP address of the Production Server. |
| `docker-creds` | Username with Password | Docker Hub credentials for pushing images. |

**Server Requirements:**
*   **Jenkins Server:** Needs `docker` installed and the `jenkins` user added to the `docker` group.
*   **Production Server:** Needs `python3`, `pip`, `unzip`, and a configured systemd service (`flaskapp.service`).
*   **SSH Access:** Jenkins must have SSH access to the Production Server (keys configured in `~/.ssh/`).

## 🛡️ Security

The pipeline includes a **Trivy** scan stage:
```groovy
trivy image --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_TAG}
```
*   It mounts `/var/run/docker.sock` to scan images directly from the host.
*   Currently set to report issues without failing the build (`exit-code 0`).

---
*Maintained by Rahul*
