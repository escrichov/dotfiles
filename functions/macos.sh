#!/bin/bash

# No use rm
#alias rm="echo Use 'del', or the full path i.e. '/bin/rm'"
#alias trash="rmtrash"
#alias del="rmtrash"

alias dns-flush='sudo killall -HUP mDNSResponder'

# 'airport' fue eliminado en macOS 14.4. Info de wifi con wdutil (requiere sudo):
alias wifi-info='sudo wdutil info'

# Backup/restore de preferencias de apps vía 'defaults' (reemplaza a mackup)
alias backup-conf="backup-defaults"
alias restore-conf="restore-defaults"
