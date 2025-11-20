package com.tamalrush.api.repository;

import com.tamalrush.api.model.Tamale;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TamaleRepository extends JpaRepository<Tamale, Integer> {
}
