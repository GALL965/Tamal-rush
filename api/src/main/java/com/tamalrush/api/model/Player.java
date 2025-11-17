package com.tamalrush.api.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Player {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer playerId;

    private String name;
    private Float speed;
    private Float dashPower;
    private Boolean hidden;
    private Integer tamalesCollected;
}
