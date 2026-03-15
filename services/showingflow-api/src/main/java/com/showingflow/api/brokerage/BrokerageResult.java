package com.showingflow.api.brokerage;

import java.time.OffsetDateTime;

public record BrokerageResult(
    Long id,
    String name,
    OffsetDateTime createdAt,
    OffsetDateTime updatedAt
) {
}
