Postman, is another app which installs at the user-level on windows devices.
this leave us with many installs of postman i nthe same device and shows up in my security platforms.

the goal is to keep an update cycle for postman.

what I did:

use postman from the community repo in my chocolatey repo
then, create 'postman.permachine' which copies the files from the service account profile into a local folder (C:\postman)
the create all the shortcuts for all users.

I also create a block in 'postman.permachine' to uninstall postman from the other user profiles. 


:^ )

Gus
