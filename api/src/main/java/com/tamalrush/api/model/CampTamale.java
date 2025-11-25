package com.tamalrush.api.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@IdClass(CampTamaleId.class)
public class CampTamale {

    @Id
    private Integer campId;

    @Id
    private Integer tamalId;

    private Integer quantityBanked;
}
