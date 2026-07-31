#!/usr/bin/env node
/*
 * react-native-island iOS setup helper.
 *
 * Automates the safe, mechanical parts of iOS setup and prints a checklist for
 * the steps that must be done in Xcode (adding a Widget Extension target and an
 * App Group can't be scripted reliably). Run from your app's root:
 *
 *   node node_modules/react-native-island/auto-setup.js [WidgetName] [AppGroup]
 */

const fs = require('fs');
const path = require('path');

const WIDGET_NAME = process.argv[2] || 'DynamicWidgetExtension';
const APP_GROUP = process.argv[3] || 'group.your.app.island';

const appRoot = process.cwd();
const iosDir = path.join(appRoot, 'ios');
const resourcesDir = path.join(__dirname, 'resources');

const log = (m) => console.log(m);
const warn = (m) => console.warn(`⚠️  ${m}`);

if (!fs.existsSync(iosDir)) {
  warn(`No ios/ directory found in ${appRoot}. Run this from your app root.`);
  process.exit(1);
}

log('🚀 react-native-island iOS setup\n');

// 1. Add NSSupportsLiveActivities to the app Info.plist -----------------------
function findAppInfoPlist() {
  const entries = fs.readdirSync(iosDir, { withFileTypes: true });
  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    if (entry.name === 'Pods' || entry.name === 'build') continue;
    const candidate = path.join(iosDir, entry.name, 'Info.plist');
    if (fs.existsSync(candidate)) return candidate;
  }
  return null;
}

const infoPlist = findAppInfoPlist();
if (infoPlist) {
  let content = fs.readFileSync(infoPlist, 'utf8');
  if (content.includes('NSSupportsLiveActivities')) {
    log('✅ Info.plist already has NSSupportsLiveActivities');
  } else {
    content = content.replace(
      /<dict>/,
      '<dict>\n\t<key>NSSupportsLiveActivities</key>\n\t<true/>'
    );
    fs.writeFileSync(infoPlist, content);
    log(
      `✅ Added NSSupportsLiveActivities to ${path.relative(appRoot, infoPlist)}`
    );
  }
} else {
  warn(
    'Could not locate the app Info.plist; add NSSupportsLiveActivities manually.'
  );
}

// 2. Copy the widget Swift templates into place -------------------------------
const targetDir = path.join(iosDir, WIDGET_NAME);
const templates = [
  'DynamicWidgetExtensionLiveActivity.swift',
  'DynamicWidgetExtensionBundle.swift',
  'ReactNativeViewWrapper.swift',
];

if (!fs.existsSync(targetDir)) fs.mkdirSync(targetDir, { recursive: true });
for (const file of templates) {
  const src = path.join(resourcesDir, file);
  const dest = path.join(targetDir, file);
  if (!fs.existsSync(src)) {
    warn(`Template missing: ${file}`);
    continue;
  }
  let content = fs.readFileSync(src, 'utf8');
  // Point the wrapper at the chosen App Group.
  content = content.replace(/group\.your\.app\.island/g, APP_GROUP);
  if (fs.existsSync(dest)) {
    log(`•  Skipped (exists): ${path.relative(appRoot, dest)}`);
  } else {
    fs.writeFileSync(dest, content);
    log(`✅ Copied ${path.relative(appRoot, dest)}`);
  }
}

// 3. Manual steps -------------------------------------------------------------
log(`
📋 Remaining manual steps in Xcode (open ios/*.xcworkspace):

  1. File ▸ New ▸ Target… ▸ Widget Extension. Name it "${WIDGET_NAME}".
     Deselect "Include Configuration App Intent". Activate the scheme.
  2. Delete the boilerplate .swift Xcode created in the target, then add the
     files this script placed in ios/${WIDGET_NAME}/ to the target.
  3. Add the App Group capability "${APP_GROUP}" to BOTH the app target and the
     "${WIDGET_NAME}" target (Signing & Capabilities ▸ + Capability ▸ App Groups).
  4. In JS, call setAppGroup('${APP_GROUP}') before starting an activity.
  5. Run: cd ios && pod install

See docs/DYNAMIC_WIDGET_SETUP.md for screenshots.

🎉 Done with the automatable parts.
`);
