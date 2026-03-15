package com.showingflow.api.brokerage;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateBrokerageRequest(
    @NotBlank
    @Size(max = 255)
    String name
) {
}
