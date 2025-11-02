// backend/src/main/java/com/example/secquote/repository/CustomerRepository.java
package com.example.secquote.repository;

import com.example.secquote.domain.Customer;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerRepository extends JpaRepository<Customer, String> {
}
