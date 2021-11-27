#!/bin/bash

# No use rm
#alias rm="echo Use 'del', or the full path i.e. '/bin/rm'"
#alias trash="rmtrash"
#alias del="rmtrash"

alias dns-flush='sudo killall -HUP mDNSResponder'

# Scan wifi networks with: "airport -s"
alias airport=/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport

alias backup-conf="mackup backup -f"
alias restore-conf="mackup restore -f"
