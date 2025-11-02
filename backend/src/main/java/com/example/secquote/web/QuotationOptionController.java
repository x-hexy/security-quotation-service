// backend/src/main/java/com/example/secquote/web/QuotationOptionController.java
package com.example.secquote.web;

import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/quotation-options")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:8081" }, allowCredentials = "true")
public class QuotationOptionController {

    @PostMapping("/generate")
    public Object generate(@RequestParam String requestId) {
        return Map.of(
                "requestId", requestId,
                "options", List.of(
                        Map.of(
                                "code", "STANDARD",
                                "label", "標準プラン",
                                "totalAmount", new BigDecimal("320000")),
                        Map.of(
                                "code", "COST_MIN",
                                "label", "コスト重視",
                                "totalAmount", new BigDecimal("270000")),
                        Map.of(
                                "code", "PREMIUM",
                                "label", "リスク対応",
                                "totalAmount", new BigDecimal("360000"))));
    }
}
