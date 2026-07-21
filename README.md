# Banking Application (DevSecOps Pipeline)

 Spring Boot application containerized with security best practices and deployed via an end-to-end automated DevSecOps CI/CD pipeline using GitHub Actions.



### Single-Stage vs. Multi-Stage Optimization
* **Stage 1 (Compilation Workbench):** Pulls a specialized `maven:alpine` build image containing the full Java Development Kit (JDK) and dependencies. Third-party packages are pulled and stored locally in the container's `.m2` engine cache using `dependency:go-offline`. This isolates the code compilation layer and cuts subsequent local build times from minutes down to seconds.
* **Stage 2 (Secure Production Runtime):** Discards the compiler workspace, heavy tools, and raw source code files completely. Only the final compiled `app.jar` is extracted and placed onto an ultra-lightweight **`eclipse-temurin:17-jre-alpine`** base runtime footprint (~200MB instead of ~800MB).

### Container Hardening Standards
* **Non-Root User Context:** The application process switches execution privileges to a custom system `testuser` account right before runtime initialization. It avoids the catastrophic risk of running as `root`.


---

## 🔒 Automated DevSecOps Pipeline Structure

The GitHub Actions configuration (`.github/workflows/devsecops.yml`) acts as an automated security gate across two distinct pipeline layers:

```text
 [STAGE 1: Code Quality & SCA]   ➔   [STAGE 2: Artifact Hardening & Release]
  ├─ Secret Detection (TruffleHog)    ├─ Secure Multi-Stage Build
  ├─ Java Style Linting               ├─ Image Scanning (Trivy Layer)
  ├─ Dependency Audit (Trivy FS)      ├─ CycloneDX SBOM Export
  └─ Native Compilation Framework     └─ Cryptographic Signing (Cosign)
```

### Stage 1: Linting, Software Composition Analysis (SCA) & Compilation
1. **Secret Detection (TruffleHog):** Scans the incoming Git history tree dynamically for accidentally leaked access tokens, keys, or internal environment passwords before code processing.
2. **Code Style Verification (Checkstyle Linter):** Audits Java formatting against standard structural style properties using `mvn checkstyle:check` to catch code smells early.
3. **Software Composition Analysis (Trivy FS Scan):** Parses the application `pom.xml` configuration files for vulnerable open-source third-party dependencies.
4. **Native Compilation Engine:** Pre-resolves package dependency loops sequentially to bypass common 429 Maven registry rate-limiting errors and builds the runtime JAR.


### Stage 2: Containerization, Artifact Hardening & Provenance Verification
1. **Docker Layer Verification:** Triggers the multi-stage Docker build engine and isolates dependencies securely.
2. **Container Image Scan (Trivy Image):** Conducts static analysis directly against the compiled filesystem of the Alpine environment, auditing systemic OS packages for deep vulnerabilities.
3. **Software Bill of Materials (SBOM Generator):** Generates a fully compliant, machine-readable inventory manifest (`sbom.json`) using the **CycloneDX standard** format, tracking application transparency logs.
4. **Cryptographic Layer Signing (Sigstore Cosign):** Digitally signs the published image layers using secure OpenID Connect (OIDC) identity federation keys. This provides tamper-proof image verification before deployment to orchestration hubs.

---

## 🛠️ Local Development Setup

### Prerequisites
* Docker Desktop installed and running.
* Java JDK 17 & Maven 3.x configured locally.

### Build and Run Manually

1. **Compile springboot application JAR package safely:**
   ```bash
   mvn clean package -DskipTests -Dcheckstyle.skip=true
   ```

2. **Compile the hardened container image using local Docker engines:**
   ```bash
   docker build -t banking-app:v2  .
   ```


---

## 📋 Required Repository Configuration Secrets

To execute the cloud delivery pipelines successfully, add the following encrypted environment key values inside your GitHub path repository layout under `Settings` -> `Secrets and variables` -> `Actions`:

| Secret Key Identifier | Description Target |
| :--- | :--- |
| `DOCKERHUB_USERNAME` | Your verified Docker Hub username account signature. |
| `DOCKERHUB_TOKEN` | A personal API access token generated from your Docker Hub profile dashboard. |
