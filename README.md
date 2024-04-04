# tview
A Powershell script that leverages COM via ADSI to enumerate Active Directory environments.

Since it uses ADSI, any user on any computer can enumerate Active Directory without having to install anything or upload/import a tool like PowerView or the PS AD module. While the script is not flagged by any AV, the functionality is very limited and right now only shows a handful of interesting items.

This is a work in progress.

TO-DO:

Add RBCD functionality

Add Kerberoasting/ASREProasting functionality for RC4 encryption (need to figure out how to implement tgt trick)

Clean up, refactor, learn how to not make shit scripts lol
