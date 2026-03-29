# ADR 002: Module Structure

## Status

Accepted

## Context

The project needs a scalable approach to organizing Terraform configurations that supports multiple environments and reusable components.

## Decision

Use a module-composition pattern where:
- Reusable modules live in `modules/` with a single responsibility each
- Environment configurations in `environments/` compose these modules
- Each module follows a standard file structure: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `locals.tf`, `README.md`

## Rationale

- Clear separation of concerns between module logic and environment configuration
- Modules are independently testable and versioned
- Environment configs are thin wiring layers, easy to diff and review
- Standard structure makes navigation predictable
- Supports future extraction to a private module registry

## Consequences

- Module interfaces (variables/outputs) must be carefully designed
- Changes to module interfaces may require updates across all environments
- Each module must be self-contained with no cross-module references
