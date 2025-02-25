// src/components/GlobalMeetUI.jsx
import React, { useEffect } from 'react';
import 'bitmovin-player/bitmovinplayer-ui.css';
import { UIContainer, PlaybackToggleButton, ControlBar } from 'bitmovin-player-ui';

function GlobalMeetUI() {
    useEffect(() => {
        const defaultUiConfig = new UIContainer({
            components: [
                new PlaybackToggleButton({
                    id: 'playback-toggle-button',
                    cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
                }),
                new ControlBar({
                    components: [],
                    id: 'control-bar-container',
                    cssClasses: ['controlbar-bottom']
                })
            ],
            cssClasses: ['ui-skin-modern']
        });

        // Attach to an existing DOM element
        const uiContainerElement = document.getElementById('bitmovin-player-ui');
        defaultUiConfig.attachToElement(uiContainerElement);

    }, []);

    return <div id="bitmovin-player-ui" className="bitmovin-player-ui"></div>;
}

export default GlobalMeetUI;
