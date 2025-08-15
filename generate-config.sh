#!/bin/bash

# This script creates the config file for Vercel deployment.
# It reads environment variables set in the Vercel project settings
# and writes them into a JavaScript file that the browser can use.

echo "Generating js/config.js"

# Create the js directory if it doesn't exist
mkdir -p js

# Create the config file using environment variables
cat > js/config.js << EOF
window.env = {
    SUPABASE_URL: '${SUPABASE_URL}',
    SUPABASE_ANON_KEY: '${SUPABASE_ANON_KEY}'
};
EOF