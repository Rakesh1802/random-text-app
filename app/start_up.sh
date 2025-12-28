#!/bin/bash

# Navigate to the site root
cd /home/site/wwwroot

# Install dependencies (only if necessary at runtime)
# Using --production avoids installing devDependencies to save time
npm install --production

# Start the node server
# Use 'node' for simple apps or 'pm2' for production-grade management
node server.js