package com.showingflow.api.brokerage;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import com.jayway.jsonpath.JsonPath;

@SpringBootTest
@Testcontainers
@AutoConfigureMockMvc
class BrokerageApiIntegrationTest {

    @Container
    @ServiceConnection
    static final PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:17-alpine");

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private BrokerageRepository brokerageRepository;

    @BeforeEach
    void setUp() {
        brokerageRepository.deleteAll();
    }

    @Test
    void createsAndReadsBackABrokerage() throws Exception {
        MvcResult createResult = mockMvc.perform(post("/brokerages")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "name": "Compass"
                        }
                        """))
                .andExpect(status().isCreated())
                .andExpect(header().exists("Location"))
                .andExpect(jsonPath("$.name").value("Compass"))
                .andExpect(jsonPath("$.createdAt").isNotEmpty())
                .andExpect(jsonPath("$.updatedAt").isNotEmpty())
                .andReturn();

        String responseBody = createResult.getResponse().getContentAsString();
        Number createdBrokerageId = JsonPath.read(responseBody, "$.id");

        mockMvc.perform(get("/brokerages/{id}", createdBrokerageId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(createdBrokerageId.longValue()))
                .andExpect(jsonPath("$.name").value("Compass"));

        mockMvc.perform(get("/brokerages"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(createdBrokerageId.longValue()))
                .andExpect(jsonPath("$[0].name").value("Compass"));
    }

    @Test
    void returnsStandardizedProblemDetailsForValidationFailures() throws Exception {
        mockMvc.perform(post("/brokerages")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "name": "   "
                        }
                        """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.title").value("Validation failed"))
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.detail").value("Request validation failed"))
                .andExpect(jsonPath("$.path").value("/brokerages"))
                .andExpect(jsonPath("$.errors[0].field").value("name"))
                .andExpect(jsonPath("$.errors[0].message").isNotEmpty());
    }

    @Test
    void returnsStandardizedProblemDetailsForMalformedJson() throws Exception {
        mockMvc.perform(post("/brokerages")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.title").value("Malformed request"))
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.detail").value("Request body could not be read"))
                .andExpect(jsonPath("$.path").value("/brokerages"));
    }

    @Test
    void returnsStandardizedProblemDetailsForNotFound() throws Exception {
        mockMvc.perform(get("/brokerages/999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.title").value("Brokerage not found"))
                .andExpect(jsonPath("$.status").value(404))
                .andExpect(jsonPath("$.detail").value("Brokerage not found: 999"))
                .andExpect(jsonPath("$.path").value("/brokerages/999"));
    }
}
