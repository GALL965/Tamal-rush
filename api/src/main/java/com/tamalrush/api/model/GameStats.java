package com.tamalrush.api.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
public class GameStats {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer gameId;

    private LocalDateTime startTime;
    private LocalDateTime endTime;

    private Integer tamalesCollected;
    private Integer tamalesBanked;

    private Integer enemiesEncountered;

    private Float totalTimePlayed;

    private Integer playerId; // ESTA ES LA CLAVE
}

