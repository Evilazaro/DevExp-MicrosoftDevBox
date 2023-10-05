#!/bin/bash

set -euo pipefail

function updateUbuntu
{
    sudo apt-get update && sudo apt-get upgrade -y
}

updateUbuntu