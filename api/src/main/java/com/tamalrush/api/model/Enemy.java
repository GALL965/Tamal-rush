package com.tamalrush.api.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Enemy {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer enemyId;

    private String type;

    private Float patrolSpeed;
    private Float chaseSpeed;

    private Float detectRange;

	private Boolean chasing;


    private Integer campId;
}
