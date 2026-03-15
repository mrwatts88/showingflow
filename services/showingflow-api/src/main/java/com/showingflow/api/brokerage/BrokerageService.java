package com.showingflow.api.brokerage;

import java.util.List;

public interface BrokerageService {

    BrokerageResult createBrokerage(CreateBrokerageCommand command);

    BrokerageResult getBrokerage(Long id);

    List<BrokerageResult> listBrokerages();
}
