# PostInstall.sh
# v1.1
# - Rename
# - Join Domain
# - Add Domain Admins Group
# - Add User Local Admin
# - Enable FileVault
# - Install OCS 
#!/bin/bash

# Rename Computer
MY_HOSTNAME="MM-$(ioreg -l | grep IOPlatformSerialNumber | grep -Eo '".{12}"' | tr -d '"')"
sudo scutil --set HostName "$MY_HOSTNAME"
sudo scutil --set LocalHostName "$MY_HOSTNAME"
sudo scutil --set ComputerName "$MY_HOSTNAME"
dscacheutil -flushcache

#Join Domain
dsconfigad -add manomano.lan -computer "`hostname -s`" -mobile enable -mobileconfirm disable -username "domainaccountname" -password "passbolt" -ou "CN=Computers,DC=mondomaine,DC=lan"
dsconfigad -groups "mondomaine\Domain Admins,mondomaine\informatique"

# Ask the user
read -p 'Enter the username who will belong to this MAC: ' USERNAME

# Grant Admin Rights
sudo dscl . -merge /Groups/admin GroupMembership "$USERNAME"

# Enable FileVault
sudo fdesetup enable > /Volumes/macos/filevaultkey/"$(uname -n).txt"

if [ -f "/Volumes/macos/filevaultkey/$(uname -n).txt" ]; then
    echo FileVaultKey has been copied on network
fi
 echo Enable FileVault in progress...
 
# Install OCS
sudo installer -pkg /Users/admin/Desktop/macos-post-install/ocspackagemacos.pkg -target /
