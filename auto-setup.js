#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('🚀 Setting up react-native-island...');

// 1. Update Podfile
const podfilePath = path.join(process.cwd(), 'ios', 'Podfile');
let podfileContent = fs.readFileSync(podfilePath, 'utf8');

if (!podfileContent.includes('Island/WidgetExtension')) {
  podfileContent = podfileContent.replace(
    /pod 'Island'/,
    `pod 'Island'
  pod 'Island/WidgetExtension'`
  );
  fs.writeFileSync(podfilePath, podfileContent);
  console.log('✅ Updated Podfile');
}

// 2. Create widget extension target (simplified)
console.log('📱 Creating widget extension target...');
// This would use Xcode command line tools or project manipulation

// 3. Install pods
console.log('📦 Installing pods...');
execSync('cd ios && pod install', { stdio: 'inherit' });

console.log('🎉 Setup complete! You can now use react-native-island.');
