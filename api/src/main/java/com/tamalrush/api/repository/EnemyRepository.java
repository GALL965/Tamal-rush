package com.tamalrush.api.repository;

import com.tamalrush.api.model.Enemy;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EnemyRepository extends JpaRepository<Enemy, Integer> {
}
