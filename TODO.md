# TODO

This file tracks unfinished work for the current checkpoint only.

Current checkpoint: complete the first vertical API slice for `brokerages` to a production-ready baseline.

## API Slice Baseline

- Add unit tests for `BrokerageServiceImpl`, including create, get-by-id, list ordering, and not-found behavior.
- Add controller tests for `BrokerageController`, covering happy paths, request validation failures, and `404` responses.
- Decide whether API errors should use plain `ProblemDetail` only or a custom wrapper with stable fields for clients and observability.
- Add request/response examples and endpoint expectations to project docs for the `brokerages` slice.
- Add API logging and request correlation conventions before more endpoints are introduced.
- Confirm Java 21 local toolchain setup so `./gradlew test` and `./gradlew bootRun` work consistently across environments.

## Architecture Follow-Through

- Add mapper strategy guidance for future slices so controller, service, and entity conversions stay consistent.
- Define repository and service conventions for sorting, pagination, and not-found handling before more read endpoints are added.
