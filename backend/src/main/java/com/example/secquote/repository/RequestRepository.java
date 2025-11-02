// backend/src/main/java/com/example/secquote/repository/RequestRepository.java
package com.example.secquote.repository;

import com.example.secquote.domain.RequestEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RequestRepository extends JpaRepository<RequestEntity, String> {
}
