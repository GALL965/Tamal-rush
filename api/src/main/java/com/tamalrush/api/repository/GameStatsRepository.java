package com.tamalrush.api.repository;

import com.tamalrush.api.model.GameStats;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GameStatsRepository extends JpaRepository<GameStats, Integer> {
}
