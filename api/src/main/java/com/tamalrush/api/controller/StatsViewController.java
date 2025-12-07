package com.tamalrush.api.controller;

import com.tamalrush.api.model.GameStats;
import com.tamalrush.api.model.Player;
import com.tamalrush.api.repository.GameStatsRepository;
import com.tamalrush.api.repository.PlayerRepository;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/stats")
public class StatsViewController {

    private final PlayerRepository playerRepo;
    private final GameStatsRepository gameRepo;

    public StatsViewController(PlayerRepository playerRepo,
                               GameStatsRepository gameRepo) {
        this.playerRepo = playerRepo;
        this.gameRepo = gameRepo;
    }

    @GetMapping("/latest")
    public Map<String, Object> getLatestStats() {

        Map<String, Object> result = new HashMap<>();

        // Último jugador creado
        Player p = playerRepo.findTopByOrderByPlayerIdDesc();

        // Última sesión de juego
        GameStats gs = gameRepo.findTopByOrderByGameIdDesc();

        result.put("player_name", p != null ? p.getName() : "N/A");
        result.put("speed", p != null ? p.getSpeed() : 0);
        result.put("dash_power", p != null ? p.getDashPower() : 0);
        result.put("tamales_collected", p != null ? p.getTamalesCollected() : 0);

        if (gs != null) {
            result.put("tamales_banked", gs.getTamalesBanked());
            result.put("total_time", gs.getTotalTimePlayed());
        } else {
            result.put("tamales_banked", 0);
            result.put("total_time", 0);
        }

        return result;
    }
}
