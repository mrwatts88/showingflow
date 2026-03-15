package com.showingflow.api.brokerage;

import java.time.OffsetDateTime;

public record BrokerageResponse(
    Long id,
    String name,
    OffsetDateTime createdAt,
    OffsetDateTime updatedAt
) {
}
