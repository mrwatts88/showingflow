package com.showingflow.api.brokerage;

import java.util.Objects;

public record CreateBrokerageCommand(String name) {

    public CreateBrokerageCommand {
        name = Objects.requireNonNull(name, "name must not be null").trim();

        if (name.isBlank()) {
            throw new IllegalArgumentException("name must not be blank");
        }
    }
}
