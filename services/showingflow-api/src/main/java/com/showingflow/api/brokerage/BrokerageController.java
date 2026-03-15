package com.showingflow.api.brokerage;

import java.net.URI;
import java.util.List;

import jakarta.validation.Valid;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

@RestController
@RequestMapping("/brokerages")
public class BrokerageController {

    private final BrokerageService brokerageService;

    public BrokerageController(BrokerageService brokerageService) {
        this.brokerageService = brokerageService;
    }

    @PostMapping
    public ResponseEntity<BrokerageResponse> createBrokerage(@Valid @RequestBody CreateBrokerageRequest request) {
        BrokerageResult brokerage = brokerageService.createBrokerage(new CreateBrokerageCommand(request.name()));
        URI location = ServletUriComponentsBuilder
            .fromCurrentRequest()
            .path("/{id}")
            .buildAndExpand(brokerage.id())
            .toUri();

        return ResponseEntity
            .created(location)
            .body(toResponse(brokerage));
    }

    @GetMapping("/{id}")
    public BrokerageResponse getBrokerage(@PathVariable Long id) {
        return toResponse(brokerageService.getBrokerage(id));
    }

    @GetMapping
    public List<BrokerageResponse> listBrokerages() {
        return brokerageService.listBrokerages()
            .stream()
            .map(this::toResponse)
            .toList();
    }

    private BrokerageResponse toResponse(BrokerageResult brokerage) {
        return new BrokerageResponse(
            brokerage.id(),
            brokerage.name(),
            brokerage.createdAt(),
            brokerage.updatedAt()
        );
    }
}
