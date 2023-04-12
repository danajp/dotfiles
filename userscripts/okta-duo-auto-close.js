// ==UserScript==
// @name         Okta/Duo Skip Chrome Out of Date
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Clicks the skip button when warned about chrome being out of date
// @author       Dana Pieluszczak
// @match        https://greenhouse.okta.com/oauth2/v1/authorize
// @icon         https://www.google.com/s2/favicons?sz=64&domain=okta.com
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    var title = document.querySelector("span.warning-card-title")
    var skipButton = document.querySelector("div.navigation > span.navigation-label")

    if (title && title.textContent.includes("Chrome is out of date") && skipButton) {
        skipButton.click()
    }
})();
