package com.tamalrush.api.controller;

import com.tamalrush.api.dto.GamePayload;
import com.tamalrush.api.service.StatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class GameController {

    private final StatsService statsService;

    @PostMapping("/upload")
    public String uploadStats(@RequestBody GamePayload payload){
        statsService.saveRun(payload);
        return "OK";
    }
}
