/* eslint-disable camelcase */
/* global Blacklight */

(function (global) {
    var RequestViewerState;

    RequestViewerState = {
        init: function() {
            this.setupIframeMessageListener();
            this.setupRequestButton();
        },

        setupRequestButton: function() {
            $('#request-state').on('click', () => {
                console.log('Exhibits: Requesting state from iframe...');
                this.requestState();
            });
        },

        setupIframeMessageListener: function() {
            window.addEventListener('message', (event) => {
                if (event && event.data) {
                    // avoid development issues
                    if (event.data == "recaptcha-setup" || event.data.source == "react-devtools-content-script") { return; }

                    let parsedData;
                    try {
                        parsedData = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
                    } catch (error) {
                        console.error('Failed to parse event data:', error);
                        return; // Exit if parsing fails
                    }
                
                    if (parsedData.type === "stateResponse" && parsedData.source === "sul-embed-m3") {
                        console.log('Exhibits: received state:', parsedData.data);
                        // Pull out the data we need (we need all 4 of these)
                        let { companionWindows, windows, viewers, workspace } = parsedData.data;
                        // Pull out the data we need (we need all 4 of these)
                        // TODO: make sure we just only send these 4 keys and not more.
                        const result = JSON.stringify({ companionWindows, windows, viewers, workspace });
                        
                        fetch('/image_area', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                // 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') 
                            },
                            body: result
                        })
                        .then(response => {
                            if (response.ok) {
                                console.log('Successfully sent data to Rails');
                            } else {
                                console.error('Failed to send data to Rails:', response.statusText);
                            }
                        })
                        .catch(err => {
                            console.error('Error sending data to Rails:', err);
                        });
                    }
                }
            });
        },

        requestState: function() {
            const iframe = $('.oembed-widget iframe');
            iframe[0].contentWindow.postMessage(JSON.stringify({ type: 'requestState' }), '*'); // Change '*' to a specific origin for security?
        }
    };

    global.RequestViewerState = RequestViewerState;
}(this));

Blacklight.onLoad(function () {
    'use strict';

    RequestViewerState.init();
});