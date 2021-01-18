#!/usr/bin/env bash

# Skim through all files for anything particularly sus
bat $(find -type f -iname '*.conf' -o -iname '*.fish' -o -iname '*.py' -o -iname '*.sh')
