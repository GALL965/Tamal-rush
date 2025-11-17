package com.tamalrush.api.dto;

import lombok.Data;
import java.util.List;
import java.util.Map;

@Data
public class GamePayload {

    public Map<String, Object> player;
    public Map<String, Object> camp;
    public List<Map<String, Object>> tamales;
    public Map<String, Integer> player_tamales;
    public Map<String, Integer> camp_tamales;
    public List<Map<String, Object>> enemies;
    public List<Map<String, Object>> enemy_logs;
    public Map<String, Object> game_stats;

}
