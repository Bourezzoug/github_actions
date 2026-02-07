Here is a formatted, clean, and color-coded README.md. I have organized it logically using headers, ordered/unordered lists, and syntax highlighting so you can easily reference it later.

GitHub Actions: Complete Workflow Reference

A comprehensive guide to understanding, building, and debugging GitHub Actions pipelines.

1. Complete Workflow Anatomy

This is a full example showing the structure of a production-ready workflow.

code
Yaml
download
content_copy
expand_less
name: Complete-CI-CD-Pipeline

# 1. TRIGGERS (When to run)
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch: # Manual trigger
    inputs:
      environment:
        type: choice
        options: [dev, staging, prod]

# 2. GLOBAL VARIABLES (Available to all jobs)
env:
  NODE_VERSION: '18'
  APP_NAME: 'my-awesome-app'

jobs:
  # JOB A: Build and Test
  build:
    name: Build and Test Application
    runs-on: ubuntu-latest
    
    # Job-level variables
    env:
      DATABASE_URL: 'postgres://localhost/testdb'
    
    # Expose data to other jobs
    outputs:
      build-version: ${{ steps.version.outputs.version }}
      artifact-name: ${{ steps.set-name.outputs.name }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Get version
        id: version  # ID required for outputs
        run: echo "version=1.0.${{ github.run_number }}" >> $GITHUB_OUTPUT
      
      - name: Set artifact name
        id: set-name
        run: echo "name=${{ env.APP_NAME }}-build" >> $GITHUB_OUTPUT
      
      - name: Install dependencies
        run: npm install
      
      - name: Run tests
        run: npm test
        env:
          TEST_ENV: 'ci' # Step-level variable
      
      - name: Build application
        run: npm run build
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: ${{ steps.set-name.outputs.name }}
          path: ./dist

  # JOB B: Deploy to Staging (Dependent Job)
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build  # ⚠️ Waits for 'build' to finish
    if: github.ref == 'refs/heads/main'
    
    environment:
      name: staging
      url: https://staging.example.com
    
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: ${{ needs.build.outputs.artifact-name }}
      
      - name: Deploy
        run: echo "Deploying version ${{ needs.build.outputs.build-version }}"
2. Breaking Down Components
🟢 Workflow Name & Triggers

name: The label visible in the Actions tab.

on: Defines triggers.

push: Runs on commit.

pull_request: Runs when opening/updating a PR.

schedule: Runs on a CRON timer.

workflow_dispatch: Adds a button to manually trigger the workflow.

🔵 Jobs Structure

Jobs run in parallel by default. Use needs to make them sequential.

runs-on: (Required) The virtual machine environment.

ubuntu-latest (Standard)

windows-latest

macos-latest

self-hosted

needs: Defines dependencies.

needs: build: Wait for build job.

needs: [build, test]: Wait for both.

if: Conditional execution.

success(): Run if previous jobs passed (Default).

failure(): Run only if previous jobs failed.

always(): Run regardless of status.

cancelled(): Run if workflow was stopped manually.

🟠 Steps Breakdown

Steps execute sequentially inside a job.

Uses (Actions): Pre-packaged scripts from the marketplace.

code
Yaml
download
content_copy
expand_less
- uses: actions/checkout@v4
  with:
    fetch-depth: 0

Run (Commands): Shell commands.

code
Yaml
download
content_copy
expand_less
- run: npm test
# Or Multi-line
- run: |
    npm install
    npm run build
3. Data Flow & Variables
Passing Data Between Jobs (Outputs)

This requires a specific chain of events:

Step Level: Write to $GITHUB_OUTPUT.

code
Bash
download
content_copy
expand_less
echo "my_key=my_value" >> $GITHUB_OUTPUT

Job Level: Map the step output to the job output.

code
Yaml
download
content_copy
expand_less
outputs:
  job_output_name: ${{ steps.step_id.outputs.my_key }}

Dependent Job: Read via needs.

code
Yaml
download
content_copy
expand_less
- run: echo ${{ needs.previous_job.outputs.job_output_name }}
Variable Scopes (Priority Order)

Inner scopes override outer scopes.

Step: steps.env (Specific to one command)

Job: jobs.job_id.env (Available to all steps in job)

Workflow: env (Available to all jobs)

Common GitHub Contexts

Automatically populated variables you can use:

${{ github.repository }}: "owner/repo-name"

${{ github.ref }}: Branch or tag name

${{ github.sha }}: Commit hash

${{ github.actor }}: Who triggered the run

${{ github.run_number }}: Incremental build number

4. Advanced Concepts
🔐 Secrets

Sensitive data (API keys, passwords) must never be hardcoded.

Add in Repo Settings → Secrets and variables → Actions.

Access in YAML:

code
Yaml
download
content_copy
expand_less
env:
  API_KEY: ${{ secrets.MY_API_KEY }}

Note: Secrets are automatically masked as *** in logs.

🕸️ Matrix Strategy

Runs the same job multiple times with different variables.

code
Yaml
download
content_copy
expand_less
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    node: [18, 20]
# Creates 4 jobs: Ubuntu+18, Ubuntu+20, Windows+18, Windows+20
📦 Artifacts

Persist files after a job finishes (e.g., binaries, test reports).

Upload:

code
Yaml
download
content_copy
expand_less
uses: actions/upload-artifact@v4
with:
  name: my-build
  path: ./dist

Download:

code
Yaml
download
content_copy
expand_less
uses: actions/download-artifact@v4
with:
  name: my-build
🌍 Environments

Used for "Gatekeeping" deployments (e.g., requiring manual approval).

code
Yaml
download
content_copy
expand_less
environment:
  name: production
  url: https://example.com
5. Quick Reference Cheat Sheet
Workflow Hierarchy

Name: Title of the file.

On: Triggers.

Env: Global variables.

Jobs:

Runs-on: OS image.

Needs: Dependency chain.

If: Conditions.

Strategy: Matrix builds.

Steps:

Name: Step title.

Id: Reference tag.

Uses: External action.

Run: Shell command.

With: Action inputs.

Env: Local variables.

Common Syntax

Variable: ${{ env.VAR_NAME }}

Secret: ${{ secrets.SECRET_NAME }}

Step Output: ${{ steps.step_id.outputs.key }}

Job Output: ${{ needs.job_name.outputs.key }}

Write Output: run: echo "key=val" >> $GITHUB_OUTPUT