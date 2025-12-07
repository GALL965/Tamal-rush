package com.tamalrush.api.controller;

import com.tamalrush.api.service.StatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class LastRunController {

    private final StatsService statsService;

    @GetMapping("/last-run")
    public Map<String, Object> getLastRun() {
        return statsService.getLastRunSummary();
    }
}
