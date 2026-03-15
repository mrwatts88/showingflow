package com.showingflow.api.brokerage;

import java.util.List;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;

import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ProblemDetail;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice(assignableTypes = BrokerageController.class)
public class BrokerageExceptionHandler {

    @ExceptionHandler(BrokerageNotFoundException.class)
    public ProblemDetail handleBrokerageNotFound(BrokerageNotFoundException exception, HttpServletRequest request) {
        return problemDetail(HttpStatus.NOT_FOUND, "Brokerage not found", exception.getMessage(), request);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ProblemDetail handleValidationFailure(MethodArgumentNotValidException exception, HttpServletRequest request) {
        ProblemDetail problemDetail = problemDetail(
            HttpStatus.BAD_REQUEST,
            "Validation failed",
            "Request validation failed",
            request
        );

        List<Map<String, String>> errors = exception.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(this::toValidationError)
            .toList();

        problemDetail.setProperty("errors", errors);
        return problemDetail;
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ProblemDetail handleMalformedRequest(HttpMessageNotReadableException exception, HttpServletRequest request) {
        return problemDetail(
            HttpStatus.BAD_REQUEST,
            "Malformed request",
            "Request body could not be read",
            request
        );
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ProblemDetail handleIllegalArgument(IllegalArgumentException exception, HttpServletRequest request) {
        return problemDetail(HttpStatus.BAD_REQUEST, "Invalid request", exception.getMessage(), request);
    }

    private ProblemDetail problemDetail(
        HttpStatusCode status,
        String title,
        String detail,
        HttpServletRequest request
    ) {
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(status, detail);
        problemDetail.setTitle(title);
        problemDetail.setProperty("path", request.getRequestURI());
        return problemDetail;
    }

    private Map<String, String> toValidationError(FieldError fieldError) {
        return Map.of(
            "field", fieldError.getField(),
            "message", fieldError.getDefaultMessage() == null ? "Invalid value" : fieldError.getDefaultMessage()
        );
    }
}
