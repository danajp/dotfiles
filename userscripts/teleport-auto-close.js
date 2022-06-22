// ==UserScript==
// @name         Auto-close teleport
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Close those pesky teleport windows
// @author       Dana Pieluszczak
// @match        https://teleport.*.gh.team*/web/msg/info/login_success
// @grant        window.close
// ==/UserScript==

(function() {
    'use strict';
    console.log("automatically closing window")
    setTimeout(()=>{window.close();}, 100)
})();
