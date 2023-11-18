#!/bin/sh
# "#################################################"
# "This file is based on a Gist, located here:"
#    "https://gist.github.com/BillRaymond/db761d6b53dc4a237b095819d33c7332#file-post-run-txt"
# "Steps to finalize a Docker image to use GitHub Pages and Jekyll"
# "Instructions:"
# " 1. Open a terminal window and cd into your repo"
# " 3. Run the script, like this:
# "      sh script-name.sh"
# "#################################################"

# Display current Ruby version
echo "Ruby version"
ruby -v

# Display current Jekyll version
echo "Jekyll version"
jekyll -v

# Configure Jekyll for GitHub Pages
echo "Add GitHub Pages to the bundle"
bundle add "github-pages" --group "jekyll_plugins" --version 228

# webrick is a technology that has been removed by Ruby, but needed for Jekyll
echo "Add required webrick dependency to the bundle"
bundle add webrick

# Install and update the bundle
echo "bundle install"
bundle install
echo "bundle update"
bundle update


