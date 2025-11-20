package com.tamalrush.api.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Camp {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer campId;

	private Float safeRadius;


    private Float locationx;
    private Float locationy;

    private Integer tamalesBanked;
}
