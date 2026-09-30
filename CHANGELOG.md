# Changelog

All notable changes to `latent_investigator` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [0.1.0] - 2026-09-30

### Added
- Initial release of `latent_investigator` v1.1 research architecture and implementation.
- Deterministic investigation core managing immutable investigation state, causal world registries, hard constraints, and ordinal compatibility aggregation.
- Synthetic strategic-network simulator with multiple scale profiles (`:smoke`, `:small`, `:medium`, `:large`) and diagnostic case classes (`:resolvable`, `:transition`, `:non_identifiable`).
- Bounded local evaluator adapters for Inference provider clients, System One SDK / Jev primitives, and deterministic Oracle.
- Strict-schema generative world proposal, attack, and repair workflows via Inference.
- Experimental runners: monolithic baseline reconnaissance (B0a/B0b), Gate 1 paired qualification, Gate 2 evaluator ablation, cost projection, and candidate generation bottleneck diagnostics.
- Auditable execution layer featuring normalized state artifacts, evaluator truth isolation, SHA-256 verification, and zero-network replay engine.
