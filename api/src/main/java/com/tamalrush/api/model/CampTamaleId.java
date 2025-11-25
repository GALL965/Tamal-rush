package com.tamalrush.api.model;

import java.io.Serializable;
import lombok.Data;

@Data
public class CampTamaleId implements Serializable {
    private Integer campId;
    private Integer tamalId;
}
