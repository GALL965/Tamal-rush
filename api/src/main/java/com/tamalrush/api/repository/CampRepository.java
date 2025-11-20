package com.tamalrush.api.repository;

import com.tamalrush.api.model.Camp;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CampRepository extends JpaRepository<Camp, Integer> {
}
