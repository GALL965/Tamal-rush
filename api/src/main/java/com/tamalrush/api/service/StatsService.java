package com.tamalrush.api.service;

import com.tamalrush.api.dto.RunPayload;
import com.tamalrush.api.model.*;
import com.tamalrush.api.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;

@Service
public class StatsService {

    private final PlayerRepository playerRepository;
    private final CampRepository campRepository;
    private final TamaleRepository tamaleRepository;
    private final EnemyRepository enemyRepository;
    private final GameStatsRepository gameStatsRepository;
    private final PlayerTamaleRepository playerTamaleRepository;
    private final CampTamaleRepository campTamaleRepository;
    private final EnemyLogRepository enemyLogRepository;

    public StatsService(
            PlayerRepository playerRepository,
            CampRepository campRepository,
            TamaleRepository tamaleRepository,
            EnemyRepository enemyRepository,
            GameStatsRepository gameStatsRepository,
            PlayerTamaleRepository playerTamaleRepository,
            CampTamaleRepository campTamaleRepository,
            EnemyLogRepository enemyLogRepository
    ) {
        this.playerRepository = playerRepository;
        this.campRepository = campRepository;
        this.tamaleRepository = tamaleRepository;
        this.enemyRepository = enemyRepository;
        this.gameStatsRepository = gameStatsRepository;
        this.playerTamaleRepository = playerTamaleRepository;
        this.campTamaleRepository = campTamaleRepository;
        this.enemyLogRepository = enemyLogRepository;
    }

    @Transactional
    public void saveRun(RunPayload payload) {

        // ===========================
        //  PLAYER
        // ===========================
        Map<String, Object> p = payload.getPlayer();
        Player player = new Player();
        player.setName((String) p.get("name"));
        player.setSpeed(toFloat(p.get("speed")));
        player.setDashPower(toFloat(p.get("dash_power")));
        player.setHidden((Boolean) p.get("hidden"));
        player.setTamalesCollected((Integer) p.get("tamales_collected"));
        player = playerRepository.save(player);

        // ===========================
        //  CAMP
        // ===========================
        Map<String, Object> c = payload.getCamp();
        Camp camp = new Camp();
        camp.setSafeRadius(toFloat(c.get("safe_radius")));
        camp.setLocationx(toFloat(c.get("location_x")));
        camp.setLocationy(toFloat(c.get("location_y")));
        camp.setTamalesBanked((Integer) c.get("tamales_banked"));
        camp = campRepository.save(camp);

        // ===========================
        //  TAMALES
        // ===========================
        if (payload.getTamales() != null) {
            for (Map<String, Object> t : payload.getTamales()) {
                Tamale tamale = new Tamale();
                tamale.setTamalName((String) t.get("tamal_name"));
                tamale.setValue((Integer) t.get("value"));
                tamale.setSpawnLocationx(toFloat(t.get("spawn_location_x")));
                tamale.setSpawnLocationy(toFloat(t.get("spawn_location_y")));
                tamale.setCollected((Boolean) t.get("collected"));
                tamaleRepository.save(tamale);
            }
        }

        // ===========================
        //  GAME STATS
        // ===========================
        Map<String, Object> gs = payload.getGame_stats();
        if (gs != null) {
            GameStats stats = new GameStats();
            stats.setPlayerId(player.getPlayerId());

            if (gs.get("start_time") != null)
                stats.setStartTime(LocalDateTime.parse((String) gs.get("start_time")));

            if (gs.get("end_time") != null)
                stats.setEndTime(LocalDateTime.parse((String) gs.get("end_time")));

            stats.setTamalesCollected((Integer) gs.get("tamales_collected"));
            stats.setTamalesBanked((Integer) gs.get("tamales_banked"));
            stats.setEnemiesEncountered((Integer) gs.get("enemies_encountered"));
            stats.setTotalTimePlayed(toFloat(gs.get("total_time_played")));

            gameStatsRepository.save(stats);
        }

        // ===========================
        //  PLAYER TAMALES
        // ===========================
        if (payload.getPlayer_tamales() != null) {
            for (Map.Entry<String, Integer> entry : payload.getPlayer_tamales().entrySet()) {
                PlayerTamale pt = new PlayerTamale();
                pt.setPlayerId(player.getPlayerId());
                pt.setTamalId(Integer.parseInt(entry.getKey()));
                pt.setQuantity(entry.getValue());
                playerTamaleRepository.save(pt);
            }
        }

        // ===========================
        //  CAMP TAMALES
        // ===========================
        if (payload.getCamp_tamales() != null) {
            for (Map.Entry<String, Integer> entry : payload.getCamp_tamales().entrySet()) {
                CampTamale ct = new CampTamale();
                ct.setCampId(camp.getCampId());
                ct.setTamalId(Integer.parseInt(entry.getKey()));
                ct.setQuantityBanked(entry.getValue());
                campTamaleRepository.save(ct);
            }
        }

        // ===========================
        //  ENEMIES
        // ===========================
        if (payload.getEnemies() != null) {
            for (Map<String, Object> e : payload.getEnemies()) {
                Enemy enemy = new Enemy();
                enemy.setType((String) e.get("type"));
                enemy.setPatrolSpeed(toFloat(e.get("patrol_speed")));
                enemy.setChaseSpeed(toFloat(e.get("chase_speed")));
                enemy.setDetectRange(toFloat(e.get("detect_range")));
                enemy.setChasing((Boolean) e.get("is_chasing"));
                enemy.setCampId(camp.getCampId());
                enemyRepository.save(enemy);
            }
        }

        // ===========================
        //  ENEMY LOGS
        // ===========================
        if (payload.getEnemy_logs() != null) {
            for (Map<String, Object> log : payload.getEnemy_logs()) {
                EnemyLog el = new EnemyLog();
                el.setEnemyId((Integer) log.get("enemy_id"));
                el.setEventType((String) log.get("event_type"));

                if (log.get("timestamp") != null)
                    el.setTimestamp(LocalDateTime.parse((String) log.get("timestamp")));

                enemyLogRepository.save(el);
            }
        }
    }

    // Utilidad para convertir número genérico en float
    private Float toFloat(Object o) {
        if (o instanceof Integer) return ((Integer)o).floatValue();
        if (o instanceof Double) return ((Double)o).floatValue();
        if (o instanceof Float) return (Float)o;
        return 0f;
    }
}
