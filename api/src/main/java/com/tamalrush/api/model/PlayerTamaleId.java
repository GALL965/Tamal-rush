package com.tamalrush.api.model;

import java.io.Serializable;
import lombok.Data;

@Data
public class PlayerTamaleId implements Serializable {
    private Integer playerId;
    private Integer tamalId;
}
