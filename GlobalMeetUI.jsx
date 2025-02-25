// src/components/GlobalMeetUI.jsx
import React, { useEffect } from 'react';
import 'bitmovin-player/bitmovinplayer-ui.css';
import { UIManager, UIFactory } from 'bitmovin-player-ui';

function GlobalMeetUI() {
    useEffect(() => {
        const player = new bitmovin.player.Player(document.getElementById('player-container'), {
            key: 'YOUR_BITMOVIN_LICENSE_KEY',
            playback: {
                autoplay: true
            },
            source: {
                dash: 'YOUR_MANIFEST_URL.mpd'
            }
        });

        // Clear existing UI if any
        UIManager.clearUi(player);

        // Create default UI
        UIFactory.buildDefaultUI(player);
        
    }, []);

    return (
        <div id="player-container" className="bitmovin-player"></div>
    );
}

export default GlobalMeetUI;
