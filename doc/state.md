# OpenTofu Project Lifecycle

OpenTofu is an open-source infrastructure as code (IaC) tool that allows you to define and provision infrastructure using declarative configuration files. This document outlines the complete lifecycle of an OpenTofu project.

## Overview

The typical OpenTofu workflow follows these stages:
1. Write configuration
2. Initialize the project
3. Plan changes
4. Apply changes
5. Manage state
6. Destroy resources (when needed)

---

## 1. Initialize the Project

**Command:** `tofu init`

Initialize your OpenTofu working directory. This command:
- Downloads and installs required provider plugins
- Initializes the backend for state storage
- Prepares the working directory for other commands

```bash
tofu init
```

**Options:**
- `-upgrade`: Upgrade providers to the latest acceptable version
- `-backend-config`: Specify backend configuration
- `-reconfigure`: Reconfigure the backend, ignoring any saved configuration

---

## 2. Validate Configuration

**Command:** `tofu validate`

Validate the configuration files for syntax errors and internal consistency.

```bash
tofu validate
```

This command checks:
- Syntax correctness
- Valid attribute names
- Required attributes presence
- Type correctness

---

## 3. Format Configuration

**Command:** `tofu fmt`

Format your configuration files to a canonical format and style.

```bash
tofu fmt
```

**Options:**
- `-recursive`: Format files in subdirectories
- `-check`: Check if formatting is needed without modifying files
- `-diff`: Display formatting differences

---

## 4. Plan Changes

**Command:** `tofu plan`

Create an execution plan showing what actions OpenTofu will take to reach the desired state.

```bash
tofu plan
```

The plan shows:
- Resources to be created (+)
- Resources to be modified (~)
- Resources to be destroyed (-)
- Resources to be replaced (-/+)

**Options:**
- `-out=FILE`: Save the plan to a file
- `-var='key=value'`: Set variable values
- `-var-file=FILE`: Load variable values from a file
- `-target=RESOURCE`: Focus on specific resources
- `-destroy`: Create a plan to destroy all resources

---

## 5. Apply Changes

**Command:** `tofu apply`

Apply the changes required to reach the desired state of the configuration.

```bash
tofu apply
```

**Options:**
- `-auto-approve`: Skip interactive approval
- `-var='key=value'`: Set variable values
- `-var-file=FILE`: Load variable values from a file
- `-target=RESOURCE`: Apply changes to specific resources
- `FILE`: Apply a previously saved plan file

**Best Practice:** Review the plan output before approving the apply.

---

## 6. Show Current State

**Command:** `tofu show`

Display the current state or a saved plan in human-readable format.

```bash
# Show current state
tofu show

# Show a saved plan
tofu show plan.tfplan
```

---

## 7. State Management

### List Resources

**Command:** `tofu state list`

List all resources in the state file.

```bash
tofu state list
```

### Show Resource Details

**Command:** `tofu state show`

Show detailed information about a specific resource.

```bash
tofu state show <resource_address>
```

### Move Resources

**Command:** `tofu state mv`

Move resources within the state file (useful for refactoring).

```bash
tofu state mv <source> <destination>
```

### Remove Resources

**Command:** `tofu state rm`

Remove resources from the state file without destroying them.

```bash
tofu state rm <resource_address>
```

### Import Existing Resources

**Command:** `tofu import`

Import existing infrastructure into your OpenTofu state.

```bash
tofu import <resource_address> <resource_id>
```

---

## 8. Inspect and Query

### Output Values

**Command:** `tofu output`

Display output values defined in your configuration.

```bash
# Show all outputs
tofu output

# Show specific output
tofu output <output_name>

# Output as JSON
tofu output -json
```

### Console

**Command:** `tofu console`

Interactive console for evaluating expressions.

```bash
tofu console
```

### Providers

**Command:** `tofu providers`

Show the providers required by the configuration.

```bash
tofu providers
```

---

## 9. Workspace Management

Workspaces allow you to manage multiple distinct sets of infrastructure resources.

### List Workspaces

```bash
tofu workspace list
```

### Create Workspace

```bash
tofu workspace new <workspace_name>
```

### Select Workspace

```bash
tofu workspace select <workspace_name>
```

### Delete Workspace

```bash
tofu workspace delete <workspace_name>
```

---

## 10. Refresh State

**Command:** `tofu refresh`

Update the state file to match real-world infrastructure.

```bash
tofu refresh
```

**Note:** This command is less commonly needed as `tofu plan` and `tofu apply` automatically refresh state.

---

## 11. Destroy Resources

**Command:** `tofu destroy`

Destroy all resources managed by the configuration.

```bash
tofu destroy
```

**Options:**
- `-auto-approve`: Skip interactive approval
- `-target=RESOURCE`: Destroy specific resources only

**Warning:** This action is irreversible. Always review what will be destroyed before confirming.

---

## 12. Graph Visualization

**Command:** `tofu graph`

Generate a visual representation of the configuration or execution plan.

```bash
tofu graph | dot -Tsvg > graph.svg
```

Requires Graphviz to be installed for visualization.

---

## Complete Workflow Example

```bash
# 1. Initialize the project
tofu init

# 2. Validate configuration
tofu validate

# 3. Format code
tofu fmt

# 4. Plan changes
tofu plan -out=tfplan

# 5. Review and apply
tofu apply tfplan

# 6. Check outputs
tofu output

# 7. Show current state
tofu show

# 8. When done, destroy resources
tofu destroy
```

---

## Best Practices

1. **Version Control**: Always keep your `.tf` files in version control (Git)
2. **State Management**: Use remote state backends (S3, Azure Blob, etc.) for team collaboration
3. **Plan Before Apply**: Always review the plan before applying changes
4. **Use Workspaces**: Separate environments (dev, staging, prod) using workspaces
5. **Lock State**: Enable state locking to prevent concurrent modifications
6. **Modularize**: Break complex configurations into reusable modules
7. **Document**: Add comments and use meaningful resource names
8. **Regular Validation**: Run `tofu validate` and `tofu fmt` regularly
9. **Backup State**: Keep backups of your state files
10. **Security**: Never commit sensitive data; use variables and secrets management

---

## Common File Structure

```
project/
├── main.tf                 # Main configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars        # Variable values (don't commit sensitive data)
├── versions.tf             # Provider version constraints
├── backend.tf              # Backend configuration
├── modules/                # Custom modules
│   └── vpc/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/           # Environment-specific configs
    ├── dev/
    ├── staging/
    └── prod/
```

---

## State File

The `terraform.tfstate` (or remote equivalent) contains:
- Current infrastructure state
- Resource metadata
- Output values
- Provider configurations

**Important:** Never manually edit the state file. Use `tofu state` commands instead.

---

## Additional Commands

### Get Modules

```bash
tofu get
```

Download and update modules referenced in the configuration.

### Version

```bash
tofu version
```

Display the OpenTofu version.

### Login

```bash
tofu login
```

Obtain and save credentials for a remote host.

### Logout

```bash
tofu logout
```

Remove stored credentials for a remote host.

---

## Conclusion

The OpenTofu lifecycle provides a structured approach to infrastructure management, from initialization through planning, application, and eventual destruction. Following this lifecycle ensures consistent, reproducible infrastructure deployments while maintaining state integrity and enabling collaboration across teams.