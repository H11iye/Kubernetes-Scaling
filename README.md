# 🚀 Express App Deployment on GKE using GitHub Actions, Helm & Artifact Registry

![Build Status](https://img.shields.io/github/actions/workflow/status/<your-username>/<your-repo>/ci-cd.yaml?branch=main)
![GKE](https://img.shields.io/badge/Platform-GKE-blue?logo=googlecloud)
![Helm](https://img.shields.io/badge/Helm-3.0+-informational?logo=helm)
![License](https://img.shields.io/badge/License-MIT-green)

## 🧩 Overview

This project demonstrates a **complete CI/CD pipeline** for deploying a containerized **Node.js Express application** to **Google Kubernetes Engine (GKE)** using:

- **GitHub Actions** for continuous integration and delivery  
- **Google Artifact Registry** for image storage  
- **Helm** for Kubernetes resource management  
- **Workload Identity Federation (OIDC)** for secure authentication  

The pipeline automates:
1. Building the Docker image  
2. Pushing it to Artifact Registry  
3. Deploying it on GKE with Helm  
4. Verifying rollout and pod health  

---

## 🧠 Architecture

```text
GitHub Actions ──► Google Artifact Registry ──► GKE (Helm Deployments)
       │                  │                             │
       │   OIDC Auth      │    Pull Image               │
       ▼                  ▼                             ▼
  Secure CI/CD     Store Docker Image             Run & Scale Pods
```
## 🧾 Project Structure
```
.
├── express-app/
│   ├── Dockerfile
│   ├── app.js
│   └── package.json
├── helm/
│   └── express-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── hpa.yaml
│           └── _helpers.tpl
├── .github/
│   └── workflows/
│       └── ci-cd.yaml
└── README.md
```
## 🚦 CI/CD Workflow

File: .github/workflows/ci-cd.yaml

The workflow automates build and deployment.

## 🔁 Pipeline Steps

1. Authenticate to GCP using Workload Identity Federation.

2. Build Docker image via GitHub Actions.

3. Push image to Artifact Registry.

4. Configure GKE credentials.

5. Deploy using Helm (helm upgrade --install).

6. Verify deployment rollout.

## ☁️ Deployment Setup
🧱 1. Enable GCP APIs
```
gcloud services enable artifactregistry.googleapis.com container.googleapis.com
 
```
🧱 2. Create a GKE Cluster
```
gcloud container clusters create <CLUSTER_NAME> \
  --zone=<ZONE> \
  --num-nodes=3

```
🧱 3. Create Artifact Registry
```
gcloud artifacts repositories create <REPO_NAME> \
  --repository-format=docker \
  --location=<REGION>

```

🧱 4. Set Up Workload Identity Federation
Follow the official Google Cloud guide
 to link GitHub Actions and GCP securely.

 🧱 5. Add Secrets in GitHub
 Store the following secrets under Settings → Secrets → Actions:
 ```
GCP_PROJECT_ID
GCP_REGION
GCP_ZONE
GCP_REPO_NAME
GCP_WIF_PROVIDER
GKE_CLUSTER_NAME
```
🌐 Accessing the Application

Once deployed, retrieve the external IP:
```
kubectl get service express-app

```
Example output:
```
NAME          TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
express-app   LoadBalancer   10.12.3.45     34.125.60.210   80:31234/TCP   2m
```

Open your app at:

👉 http://34.125.60.210

📈 Scaling & Resource Management
View pods and replicas
```
kubectl get deployment express-app
kubectl get pods

```
Scale manually
```
kubectl scale deployment express-app --replicas=5
```

Auto-scale (HPA)

If HPA is configured:
```
kubectl get hpa
kubectl describe hpa express-app

```
📘 Reference:

[Workload Identity Federation Documentation](https://cloud.google.com/iam/docs/workload-identity-federation)

## 🔒 Security Best Practices

✅ Use Workload Identity Federation instead of JSON keys

✅ Apply principle of least privilege on service accounts

✅ Scan Docker images using Trivy

✅ Use Artifact Registry (not deprecated Container Registry)

✅ Enable GKE Network Policies

## 🏁 Summary

✅ Automated CI/CD from GitHub → GKE

✅ Secure, keyless authentication (OIDC)

✅ Scalable Helm-managed deployments

✅ Observable, production-ready setup

### 📘 Sources Used
All sections are based on reputable sources:
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Google Cloud Artifact Registry Documentation](https://cloud.google.com/artifact-registry/docs)
- [Helm Official Documentation](https://helm.sh/docs/)
- [Google Cloud Workload Identity Federation Guide](https://cloud.google.com/iam/docs/workload-identity-federation)
- [GitHub Actions for Google Cloud](https://github.com/google-github-actions)
