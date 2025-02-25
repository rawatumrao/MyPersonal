// src/components/GlobalMeetUI.jsx
import React, { useEffect } from 'react';
import { Player } from 'bitmovin-player';

function GlobalMeetUI() {
    useEffect(() => {
        const playerConfig = {
            key: 'YOUR_PLAYER_KEY',
            source: {
                dash: 'https://path/to/your/dash/manifest.mpd',
                poster: 'https://path/to/your/poster.jpg'
            }
        };

        const player = new Player(document.getElementById('player-container'), playerConfig);

        player.on('ready', () => {
            console.log('Bitmovin Player is ready');
        });

    }, []);

    return <div id="player-container" style={{ width: '100%', height: '500px' }}></div>;
}

export default GlobalMeetUI;
