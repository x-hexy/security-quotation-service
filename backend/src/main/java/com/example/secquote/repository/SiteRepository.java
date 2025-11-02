package com.example.secquote.repository;

import com.example.secquote.domain.Site;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SiteRepository extends JpaRepository<Site, String> {
    List<Site> findByCustomerCustomerId(String customerId);
}
