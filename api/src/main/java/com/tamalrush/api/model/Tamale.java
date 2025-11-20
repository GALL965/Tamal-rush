package com.tamalrush.api.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Tamale {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer tamalId;

    private String tamalName;

    private Integer value;

    private Float spawnLocationx;
    private Float spawnLocationy;

    private Boolean collected;
}
