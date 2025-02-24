
var app = function () {
    const src = {
        dash: "https://cdn.bitmovin.com/content/assets/art-of-motion-dash-hls-progressive/mpds/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.mpd"
    };
    
    
    const config = {
        key: "29ba4a30-8b5e-4336-a7dd-c94ff3b25f30",
        playback: {
            autoplay: true,
            muted: true
        },
        // the UI must be disabled to load a custom UI with custom buttons on it
        ui: false
    };
    
    
    const player = new bitmovin.player.Player( document.getElementById("player-container"), config);

    // Create a custom UI 
    let customUi = createGlobalMeetUi()

    // Attach the custom UI to the player instance
    let uiManager = new bitmovin.playerui.UIManager(player, customUi);
    
    player
        .load(src)
        .then(
        (player) => {
            console.log("Successfully created Bitmovin Player instance");
        },
        (reason) => {
            console.log("Error while creating Bitmovin Player instance", reason);
        }
        );
    }
