// backend/src/main/java/com/example/secquote/web/CustomerController.java
package com.example.secquote.web;

import com.example.secquote.repository.CustomerRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/customers")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:8081" })
public class CustomerController {

    private final CustomerRepository repo;

    public CustomerController(CustomerRepository repo) {
        this.repo = repo;
    }

    @GetMapping
    public Object list() {
        return repo.findAll();
    }
}
