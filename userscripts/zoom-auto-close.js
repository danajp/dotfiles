// ==UserScript==
// @name         Auto-close zoom
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Close those pesky zoom windows
// @author       Josh.Souza
// @match        https://*.zoom.us/*
// @match        https://zoom.us/*
// @grant        window.close
// ==/UserScript==

(function() {
    'use strict';
    function check(){
        console.log("Checking")
        if ( /#.*success/.test(location.hash) ) {
            setTimeout(()=>{window.close();}, 100)
            return;
        }
        setTimeout(()=>{check();}, 100)
    }
    check()
})();
