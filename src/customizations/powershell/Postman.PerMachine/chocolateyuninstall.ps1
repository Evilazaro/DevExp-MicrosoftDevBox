$ApplicationName = 'Postman'
Remove-Item "${env:SystemDrive}\$ApplicationName" -Recurse -Force
Remove-Item "${env:Public}\Desktop\$ApplicationName.lnk" -Recurse -Force 
Remove-Item  "${env:AllUsersProfile}\Microsoft\Windows\Start Menu\Programs\$ApplicationName.lnk" -Recurse -Force 
