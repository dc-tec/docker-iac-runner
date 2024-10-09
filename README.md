# DevOps CI/CD Docker Image

This image contains a set of tools that I use for CI/CD pipelines. Which gives me a consistent environment across my pipelines.

## Included Tools

- Pulumi
- Ansible
- AWS CLI
- tenv (Terraform version manager)

## Usage

Build the Docker image:

`docker build -t devops-cicd-runner:test .`

Run a container:

`docker run -it devops-cicd-runner:test /bin/bash`

## Customization

Modify the Dockerfile to add or remove tools as needed for your CI/CD pipeline. The Dockerfile can be found at:

`Dockerfile`

## Versioning

Renovate will automatically create a new version for the image when a new version of a dependency is released.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

Before submitting your pull request, ensure that you've run the pre-commit hooks:

`pre-commit install`
`pre-commit install-hooks`
`pre-commit run --all-files`

## Testing

We use Container Structure Test to verify the integrity of our Docker image. The test file can be found at:

`tests/structure-test.yaml`

To run the tests:

`container-structure-test test --config tests/structure-test.yaml --image devops-cicd-runner:test`

## Continuous Integration

This project uses GitHub Actions for CI/CD. The workflows can be found in the `.github/workflows` directory:

- PR Test: Runs tests on pull requests
- Build and Push: Builds and pushes the Docker image to GitHub Container Registry
- Renovate: Keeps dependencies up to date

## Renovate

We use Renovate to keep our dependencies up to date. The configuration can be found in `renovate.json5`:

`[Path to renovate.json5]`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
