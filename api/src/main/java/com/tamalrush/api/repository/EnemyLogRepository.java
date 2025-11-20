package com.tamalrush.api.repository;

import com.tamalrush.api.model.EnemyLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EnemyLogRepository extends JpaRepository<EnemyLog, Integer> {
}
