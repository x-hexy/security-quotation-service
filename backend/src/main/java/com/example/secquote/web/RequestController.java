// backend/src/main/java/com/example/secquote/web/RequestController.java
package com.example.secquote.web;

import com.example.secquote.domain.Customer;
import com.example.secquote.domain.RequestEntity;
import com.example.secquote.domain.Site;
import com.example.secquote.repository.CustomerRepository;
import com.example.secquote.repository.RequestRepository;
import com.example.secquote.repository.SiteRepository;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.UUID;

@RestController
@RequestMapping("/api/requests")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:8081" })
public class RequestController {

    private final RequestRepository requestRepository;
    private final CustomerRepository customerRepository;
    private final SiteRepository siteRepository;

    public RequestController(RequestRepository requestRepository,
            CustomerRepository customerRepository,
            SiteRepository siteRepository) {
        this.requestRepository = requestRepository;
        this.customerRepository = customerRepository;
        this.siteRepository = siteRepository;
    }

    // DTO
    public record CreateRequestBody(
            String customerId,
            String siteId,
            String title,
            String description,
            String startDatetime,
            String endDatetime) {
    }

    @PostMapping
    public RequestEntity create(@RequestBody CreateRequestBody body) {
        Customer c = customerRepository.findById(body.customerId())
                .orElseThrow(() -> new IllegalArgumentException("customer not found"));
        Site s = siteRepository.findById(body.siteId())
                .orElseThrow(() -> new IllegalArgumentException("site not found"));

        RequestEntity r = new RequestEntity();
        r.setRequestId(UUID.randomUUID().toString());
        r.setCustomer(c);
        r.setSite(s);
        r.setRequestTitle(body.title());
        r.setDescription(body.description());
        r.setStartDatetime(OffsetDateTime.parse(body.startDatetime()));
        r.setEndDatetime(OffsetDateTime.parse(body.endDatetime()));
        r.setRequestStatus("quoting");
        var now = OffsetDateTime.now();
        r.setCreatedAt(now);
        r.setUpdatedAt(now);

        return requestRepository.save(r);
    }

    @GetMapping("/{id}")
    public RequestEntity get(@PathVariable String id) {
        return requestRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("request not found"));
    }
}
