package com.showingflow.api.brokerage;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice(assignableTypes = BrokerageController.class)
public class BrokerageExceptionHandler {

    @ExceptionHandler(BrokerageNotFoundException.class)
    public ProblemDetail handleBrokerageNotFound(BrokerageNotFoundException exception) {
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, exception.getMessage());
        problemDetail.setTitle("Brokerage not found");
        return problemDetail;
    }
}
