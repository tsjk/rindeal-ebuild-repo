/* disable autoupdater */
pref("app.update.auto", false);
pref("app.update.enabled", false);
pref("app.update.autoInstallEnabled", false);

// pref("browser.backspace_action", 2);
// pref("browser.display.use_system_colors",   true);
// pref("browser.download.folderList",         1);
// pref("browser.link.open_external",          3);

pref("general.smoothScroll", true);

// pref("intl.locale.matchOS",                 true);
// pref("storage.nfs_filesystem",              false);
// pref("dom.ipc.plugins.enabled.nswrapper*",  false);
// pref("network.manage-offline-status",       true);
// pref("toolkit.networkmanager.disable", false);

// pref("toolkit.storage.synchronous",         0);

/* Workaround for rhbz#1134876 */
pref("javascript.options.baselinejit", false);

/* Workaround for rhbz#1110291 */
pref("network.negotiate-auth.allow-insecure-ntlm-v1", true);

/* Workaround for mozbz#1063315 */
pref("security.use_mozillapkix_verification", false);

/* Don't disable extensions dropped in to a system
 * location, or those owned by the application */
pref("extensions.autoDisableScopes", 3);

/* Don't display the one-off addon selection dialog when
 * upgrading from a version of Firefox older than 8.0 */
pref("extensions.shownSelectionUI", true);

/* Enable Network Manager integration */
pref("network.manage-offline-status", true);

/* Fall back to en-US search plugins if none exist for the current locale */
pref("distribution.searchplugins.defaultLocale", "en-US");

/* Use LANG environment variable to choose locale */
pref("intl.locale.matchOS", true);

/* Enable extensions in the application directory */
pref("extensions.enabledScopes", 5);
