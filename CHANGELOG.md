# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

## [0.1.0] - 2026-07-26

### Added
- BDD test framework — `describe`/`context`/`it` with `xit`/`xdescribe`
  skipping, hooks (`before-each`/`after-each`/`before-all`/`after-all`),
  `expect`/`expect-error` with matchers (`to-equal`, `to-eqv`, `to-be`,
  `to-be-truthy`, `to-be-falsy`, …), and `run-specs`
- Pure Scheme implementation, no C dependencies or build step
- CI workflow for automated testing
