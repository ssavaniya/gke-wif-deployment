# 12 - Unit Testing

## Overview

Unit testing is the first quality gate in the CI/CD pipeline.

Before the application is packaged into a Docker image, automated tests verify that the application's business logic behaves as expected.

If any unit test fails, the GitHub Actions workflow stops immediately, preventing Docker image creation and deployment to Google Kubernetes Engine (GKE).

This ensures that only verified code progresses through the CI/CD pipeline.

---

# What is Unit Testing?

Unit testing verifies the smallest testable component of an application in isolation.

Examples include:

- Methods
- Classes
- Services
- Controllers
- Utility functions

Rather than testing the entire application, unit tests focus on validating individual pieces of functionality.

---

# Why Unit Testing?

Without automated testing:

```text
Developer

↓

Code Change

↓

Build

↓

Deploy

↓

Production Failure
```

With unit testing:

```text
Developer

↓

Code Change

↓

Unit Tests

↓

PASS

↓

Continue Pipeline
```

or

```text
Developer

↓

Code Change

↓

Unit Tests

↓

FAIL

↓

Pipeline Stops
```

By identifying defects early, unit testing reduces the risk of deploying faulty code.

---

# Testing Framework

The project uses the standard Spring Boot testing framework.

| Tool | Purpose |
|------|---------|
| JUnit 5 | Test execution |
| Mockito | Mock dependencies |
| Spring Boot Test | Spring testing support |
| Maven Surefire Plugin | Executes unit tests |
| JaCoCo | Code coverage reporting |

---

# Project Structure

Application source code:

```
src/main/java
```

Unit tests:

```
src/test/java
```

Example:

```
HelloController

↓

HelloControllerTest
```

---

# What is Tested?

The project currently includes unit tests for the application's REST controller.

Typical validations include:

- HTTP response status
- Response body
- Message content
- Environment value

Expected response:

```json
{
  "message":"Hello from GKE",
  "environment":"dev"
}
```

---

# Running Tests

Execute all unit tests:

```bash
./mvnw test
```

Run a specific test:

```bash
./mvnw test -Dtest=HelloControllerTest
```

Package the application without running tests:

```bash
./mvnw package -DskipTests
```

> Skipping tests is useful during local development but should never be used in the CI/CD pipeline.

---

# Test Reports

Maven automatically generates test reports.

Location:

```
target/surefire-reports/
```

JaCoCo generates code coverage reports in:

```
target/site/jacoco/
```

These reports help measure how much of the application code is exercised by the unit tests.

---

# CI/CD Integration

GitHub Actions automatically executes unit tests before building the Docker image.

Pipeline flow:

```text
Checkout Source

↓

Authenticate to Google Cloud

↓

Run Unit Tests

↓

Generate JaCoCo Coverage

↓

Build Docker Image

↓

Push Artifact Registry

↓

Trivy Scan

↓

Helm Deployment
```

If any unit test fails:

- Docker image is not built
- Image is not pushed to Artifact Registry
- Deployment to Kubernetes is skipped

This fail-fast approach prevents defective code from progressing through the deployment pipeline.

---

# Code Coverage

The project uses JaCoCo to generate code coverage reports.

Coverage reports help developers understand:

- Which classes are tested
- Which methods are executed
- Areas requiring additional tests

Coverage reports are generated automatically during the GitHub Actions workflow.

---

# Benefits

Automated unit testing provides several advantages:

- Detects defects early
- Prevents regressions
- Improves code quality
- Enables safe refactoring
- Supports continuous integration
- Reduces production incidents

---

# Best Practices Implemented

This project follows unit testing best practices, including:

- Automated execution
- Tests executed on every pipeline run
- Fail-fast CI/CD pipeline
- Separate test source directory
- Maven integration
- JaCoCo code coverage
- No deployment if tests fail

---

# Related Documentation

This document focuses on unit testing.

End-to-end API validation after deployment is covered in:

**13-functional-testing.md**

---

# Key Takeaways

Unit testing is the first quality gate in the CI/CD pipeline.

Every code change is validated before a Docker image is created, ensuring that only tested and verified code proceeds to vulnerability scanning and Kubernetes deployment.

This approach improves software quality, increases deployment confidence, and supports modern Continuous Integration practices.
