package com.tamalrush.api.controller;

import com.tamalrush.api.dto.RunPayload;
import com.tamalrush.api.service.StatsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/stats")
public class StatsController {

    private final StatsService statsService;

    public StatsController(StatsService statsService) {
        this.statsService = statsService;
    }

    @PostMapping("/run")
    public ResponseEntity<String> saveRun(@RequestBody RunPayload payload) {
        statsService.saveRun(payload);
        return ResponseEntity.ok("Run guardada correctamente");
    }
}
