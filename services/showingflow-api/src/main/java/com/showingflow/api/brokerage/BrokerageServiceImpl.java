package com.showingflow.api.brokerage;

import java.util.List;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class BrokerageServiceImpl implements BrokerageService {

    private final BrokerageRepository brokerageRepository;

    public BrokerageServiceImpl(BrokerageRepository brokerageRepository) {
        this.brokerageRepository = brokerageRepository;
    }

    @Override
    @Transactional
    public BrokerageResult createBrokerage(CreateBrokerageCommand command) {
        Brokerage brokerage = new Brokerage(command.name());
        Brokerage savedBrokerage = brokerageRepository.save(brokerage);
        return toResult(savedBrokerage);
    }

    @Override
    public BrokerageResult getBrokerage(Long id) {
        return brokerageRepository.findById(id)
            .map(this::toResult)
            .orElseThrow(() -> new BrokerageNotFoundException(id));
    }

    @Override
    public List<BrokerageResult> listBrokerages() {
        return brokerageRepository.findAll(Sort.by(Sort.Direction.ASC, "name", "id"))
            .stream()
            .map(this::toResult)
            .toList();
    }

    private BrokerageResult toResult(Brokerage brokerage) {
        return new BrokerageResult(
            brokerage.getId(),
            brokerage.getName(),
            brokerage.getCreatedAt(),
            brokerage.getUpdatedAt()
        );
    }
}
