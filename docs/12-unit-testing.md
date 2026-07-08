# Unit Testing

## Overview

Unit testing is the first quality gate in the CI/CD pipeline.

Before an application is packaged into a Docker image, automated tests verify that the application's business logic behaves as expected.

If any unit test fails, the pipeline stops immediately and the application is not deployed.

This prevents defective code from reaching production.

---

# What is Unit Testing?

Unit testing verifies the smallest testable component of an application in isolation.

Examples include:

- Methods
- Classes
- Services
- Controllers
- Utility functions

Rather than testing the entire application, unit tests focus on individual pieces of functionality.

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

This allows defects to be identified before deployment.

---

# Testing Framework

The project uses the standard Spring Boot testing framework.

| Tool | Purpose |
|------|---------|
| JUnit 5 | Test execution |
| Mockito | Mock dependencies |
| Spring Boot Test | Spring testing support |
| Maven Surefire | Test execution during build |

---

# Test Structure

Application code:

```
src/main/java
```

Unit tests:

```
src/test/java
```

Typical structure:

```
HelloController

↓

HelloControllerTest
```

---

# Example

Controller:

```java
@GetMapping("/")
public Message hello() {
    ...
}
```

Unit test verifies:

- HTTP response
- Message value
- Environment value

Expected response:

```json
{
  "message":"Hello from Ingress",
  "environment":"dev"
}
```

---

# Running Tests

Execute all tests:

```bash
./mvnw test
```

Run a specific test:

```bash
./mvnw test \
-Dtest=HelloControllerTest
```

Generate package without tests:

```bash
./mvnw package \
-DskipTests
```

---

# Test Reports

Maven automatically generates test reports.

Location:

```
target/surefire-reports
```

View report:

```bash
cat target/surefire-reports/*.txt
```

---

# CI/CD Integration

The GitHub Actions pipeline executes unit tests before building the Docker image.

Pipeline sequence:

```text
Checkout

↓

Unit Tests

↓

Build Application

↓

Docker Build

↓

Artifact Registry

↓

Security Scan

↓

Deployment
```

If unit tests fail:

- Docker image is not built
- Artifact Registry is not updated
- Kubernetes deployment does not occur

---

# Benefits

Automated unit testing provides several advantages.

- Detects defects early
- Prevents regressions
- Improves code quality
- Enables safe refactoring
- Supports continuous integration
- Reduces production incidents

---

# Best Practices Followed

The project follows several unit testing best practices.

- Automated execution
- Tests run on every commit
- Fail-fast pipeline
- Separate test source directory
- Maven integration
- No deployment if tests fail

---

# Future Enhancements

Potential improvements include:

- Increase code coverage
- Mock external services
- Parameterized tests
- Integration tests
- Performance tests

---

# Key Takeaways

Unit testing serves as the first quality gate of the deployment pipeline.

Every code change is validated before packaging the application into a Docker image, ensuring that only tested and verified code proceeds to the remaining CI/CD stages.
