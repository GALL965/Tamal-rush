package com.tamalrush.api.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@IdClass(PlayerTamaleId.class)
public class PlayerTamale {

    @Id
    private Integer playerId;

    @Id
    private Integer tamalId;

    private Integer quantity;
}
