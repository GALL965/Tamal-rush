package com.tamalrush.api.dto;

import lombok.Data;
import java.util.List;
import java.util.Map;

@Data
public class RunPayload {
    private Map<String, Object> player;
    private Map<String, Object> camp;

    private List<Map<String, Object>> tamales;

    private Map<String, Integer> player_tamales;
    private Map<String, Integer> camp_tamales;

    private List<Map<String, Object>> enemies;
    private List<Map<String, Object>> enemy_logs;

    private Map<String, Object> game_stats;
}
