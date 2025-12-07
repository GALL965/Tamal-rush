package com.tamalrush.api.controller;

import com.tamalrush.api.service.StatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class PlayerStatsController {

    private final StatsService statsService;

    @GetMapping("/stats/total")
    public Map<String, Object> getTotalStats() {
        return statsService.getTotalPlayerStats();
    }
}
