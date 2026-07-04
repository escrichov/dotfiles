#!/usr/bin/env bash


## Ensure XCode Command Line Tools are installed.

if ! xcode-select -p >/dev/null 2>&1; then
    # Abre el diálogo de instalación de las Command Line Tools
    xcode-select --install

    # Espera a que termine la instalación antes de continuar
    until xcode-select -p >/dev/null 2>&1; do
        sleep 5
    done
fi
