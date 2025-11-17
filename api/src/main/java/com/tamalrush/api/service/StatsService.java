package com.tamalrush.api.service;

import com.tamalrush.api.dto.GamePayload;
import com.tamalrush.api.model.Player;
import com.tamalrush.api.repository.PlayerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class StatsService {

    private final PlayerRepository playerRepository;

    public void saveRun(GamePayload payload) {

        // EXTRAER player
        var p = payload.getPlayer();

        Player player = new Player();
        player.setName((String)p.get("name"));
        player.setSpeed(floatValue(p.get("speed")));
        player.setDashPower(floatValue(p.get("dash_power")));
        player.setHidden((Boolean)p.get("hidden"));
        player.setTamalesCollected(intValue(p.get("tamales_collected")));

        playerRepository.save(player);
    }

    private float floatValue(Object o){
        return o == null ? 0 : Float.parseFloat(o.toString());
    }

    private int intValue(Object o){
        return o == null ? 0 : Integer.parseInt(o.toString());
    }
}
