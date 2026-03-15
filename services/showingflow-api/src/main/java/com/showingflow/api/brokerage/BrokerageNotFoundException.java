package com.showingflow.api.brokerage;

public class BrokerageNotFoundException extends RuntimeException {

    public BrokerageNotFoundException(Long id) {
        super("Brokerage not found: " + id);
    }
}
