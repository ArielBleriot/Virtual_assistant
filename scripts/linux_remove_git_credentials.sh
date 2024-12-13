#!/bin/bash

# Remove saved Git credentials
echo "Removing saved Git credentials..."
git config --global --unset user.name
git config --global --unset user.email
git config --global --unset user.password

# Unset GitHub credential variables (for the current session)
unset GITHUB_USERNAME
unset GITHUB_EMAIL
unset GITHUB_PASSWORD

echo "Credentials removed."