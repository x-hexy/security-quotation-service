// backend/src/main/java/com/example/secquote/web/SiteController.java
package com.example.secquote.web;

import com.example.secquote.repository.SiteRepository;
import com.example.secquote.domain.Site;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customers/{customerId}/sites")
@CrossOrigin(origins = { "http://localhost:5173" })
public class SiteController {

    private final SiteRepository siteRepository;

    public SiteController(SiteRepository siteRepository) {
        this.siteRepository = siteRepository;
    }

    // 简单DTO
    public record SiteDto(String siteId, String siteName) {
    }

    @GetMapping
    public List<SiteDto> list(@PathVariable String customerId) {
        List<Site> sites = siteRepository.findByCustomerCustomerId(customerId);
        return sites.stream()
                .map(s -> new SiteDto(s.getSiteId(), s.getSiteName()))
                .toList();
    }
}

