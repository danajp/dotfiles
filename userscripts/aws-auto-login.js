// ==UserScript==
// @name         Auto-login AWS
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Automatically click the button to log into AWS
// @author       Josh Souza
// @match        https://greenhouse-sso.awsapps.com/start/user-consent/authorize.html?*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';
    var checkExist = setInterval(function() {
        if (document.getElementById("cli_login_button")) {
            clearInterval(checkExist);
            document.getElementById("cli_login_button").click();
        }
    }, 100);
})();
