#!/bin/bash

# Add menu items to Firestore using the Firebase CLI
# This uses the gcloud auth credential linked to firebase login

PROJECT="throunburger"
API_URL="https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents/menu_items"

# Get Firebase access token
TOKEN=$(firebase login:ci --no-localhost 2>/dev/null || echo "")

if [ -z "$TOKEN" ]; then
  echo "Using Firebase emulator instead..."
  
  # Create menu items one by one using firebase CLI data:set
  echo "This requires manual setup. Please add from Firebase Console."
  exit 1
fi
