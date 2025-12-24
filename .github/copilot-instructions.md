# Long Operation API - Copilot Instructions

## Project Overview

Long Operation API is a web service that manages long-running asynchronous operations. It provides a REST API for creating operations with configurable wait times and checking their status. The API follows an asynchronous request/response pattern where operations are accepted immediately (202 Accepted) and their status can be polled via a separate endpoint.

### Key Features
- Create long-running operations with configurable wait times
- Poll operation status via unique operation IDs
- Persistent storage using MongoDB
- Deployed on AWS using Fargate (ECS) with API Gateway
- Infrastructure as Code using Terraform

## Tech Stack

### Languages & Frameworks
- **Go 1.23**: Primary language for the API server
- **Standard Library**: HTTP server using `net/http`

### Database
- **MongoDB**: NoSQL database for storing operation state
- **MongoDB Driver v2**: Official Go driver for MongoDB

### Infrastructure & Deployment
- **Docker**: Containerization using multi-stage builds
- **AWS Fargate**: Container orchestration
- **AWS API Gateway**: API management and routing
- **AWS ECR**: Container registry
- **Terraform**: Infrastructure as Code (IaC)
- **GitHub Actions**: CI/CD pipelines

### Development Tools
- **Task**: Task runner (see Taskfile.yml)
- **Docker Compose**: Local development environment
- **Air**: Hot reload for Go development (cosmtrek/air)

## Project Structure

```
.
├── main.go                  # Main application code
├── go.mod                   # Go module dependencies
├── Dockerfile               # Multi-stage Docker build
├── Taskfile.yml             # Task runner configuration
├── compose.yml              # Docker Compose for local dev
├── longoperation-api.yaml   # OpenAPI specification
├── deployment/              # Terraform infrastructure code
│   ├── fargate.tf          # ECS Fargate configuration
│   ├── gateway.tf          # API Gateway setup
│   ├── ecr.tf              # Container registry
│   ├── vpc.tf              # Network configuration
│   └── ...
└── .github/
    └── workflows/           # GitHub Actions workflows
```

## Coding Standards and Guidelines

### Go Code Style
- Follow standard Go conventions and formatting (use `gofmt`)
- Use meaningful variable and function names
- Keep functions focused and concise
- Handle errors explicitly; never ignore errors
- Use structured logging with `log/slog` package
- Always use context for database operations and HTTP requests

### Error Handling
- Log errors with appropriate severity levels using `slog.Error()`
- Return appropriate HTTP status codes
- Never expose internal error details to clients in production

### Database Operations
- Use request context for MongoDB operations to enable proper timeout handling and cancellation
- Use `context.Background()` only for application lifecycle operations (e.g., connecting/disconnecting)
- Use BSON for MongoDB documents
- Close database connections properly (defer disconnect)

### HTTP API Design
- Follow RESTful conventions
- Use appropriate HTTP methods (POST for create, GET for read)
- Return proper status codes (202 for async operations, 404 for not found)
- Include operation location headers for async operations
- Use `application/json` content type

### Security
- Never commit credentials or secrets
- Use environment variables for sensitive configuration
- Credentials should be retrieved from AWS Secrets Manager in production
- Database connection strings should use environment variables

## Build, Test, and Run

### Local Development

#### Prerequisites
- Go 1.23 or later
- Docker and Docker Compose
- Task runner (optional, but recommended)

#### Build the Application
```bash
# Using Task
task build

# Or directly with Go
go build main.go
```

#### Run Locally with Docker Compose
```bash
# Start the application with hot reload
task app:up

# Or directly with Docker Compose
docker compose up -d

# The API will be available at http://localhost:8080
```

#### Stop Local Environment
```bash
task app:down
# Or: docker compose down
```

#### Environment Variables
- `PORT`: Server port (default: 80 in production, 8080 in dev)
- `MONGODB_CREDENTIALS`: JSON object with `username` and `password` keys

### Docker Build
```bash
# Build Docker image
docker build -t longoperation-api .

# The Dockerfile uses multi-stage builds for optimization
# Final image is based on Alpine Linux for minimal size
```

### API Testing

#### Create an Operation
```bash
curl -X POST http://localhost:8080/api/v1/operations \
  -H "Content-Type: application/json" \
  -d '{"wait-for": 10}'

# Returns 202 Accepted with Operation-ID and Operation-Location headers
```

#### Check Operation Status
```bash
curl http://localhost:8080/api/v1/operations/{operation-id}

# Returns operation status: "NotStarted" or "Finished"
```

#### Health Check
```bash
curl http://localhost:8080/health
```

## Infrastructure and Deployment

### Terraform
Infrastructure is defined in the `deployment/` directory using Terraform.

#### Terraform Commands (using Task)
```bash
# Initialize Terraform
task terraform:init

# Plan infrastructure changes
task terraform:plan

# Apply infrastructure changes
task terraform:apply

# Lint Terraform files
task terraform:lint
```

### GitHub Actions Workflows

#### Build and Push Docker Image
- Triggered on: Push to `main` branch (when Go files change) or manual dispatch
- Workflow: `.github/workflows/build-app.yml`
- Builds Docker image and pushes to AWS ECR

#### Terraform Workflows
- `terraform-deploy.yml`: Deploy infrastructure
- `terraform-lint.yml`: Lint Terraform files
- `terraform-destroy.yml.disable`: Destroy infrastructure (disabled by default)

### AWS Setup Notes
1. Deploy infrastructure using Terraform workflow
2. Push Docker image to ECR using build workflow
3. Add VPC `public_ip` to MongoDB Atlas Network Access list

## Code Review Considerations

### Before Submitting PRs
- Ensure code compiles without errors
- Follow Go coding standards and use `gofmt`
- Test API endpoints locally
- Verify Docker build succeeds
- Check that infrastructure changes are valid (Terraform validate)

### Review Checklist
- Code follows project structure and conventions
- Error handling is proper and complete
- Logging is appropriate and helpful
- Security best practices are followed (no hardcoded secrets)
- MongoDB operations use proper context handling
- HTTP responses include appropriate status codes and headers

## API Specification

The OpenAPI 3.0 specification is available in `longoperation-api.yaml`. This defines:
- API endpoints and methods
- Request/response schemas
- Headers and parameters
- AWS API Gateway integration configuration

## References

- [Go Documentation](https://golang.org/doc/)
- [MongoDB Go Driver](https://www.mongodb.com/docs/drivers/go/current/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
