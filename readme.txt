This script should provide upload of all xml files from one folder to FTP server and after check it would move all xml to other folder. 

settings is made in xml file Config.xml

it can be saved as windows service

#Config.xml
<?xml version="1.0"?>
<?xml-stylesheet type='text/xsl' href='style.xsl'?>
<RootElement>
    <ftp>
        <ftpaddress>FTP_Server_address:21</ftpaddress> --- address and port of FTP server
		<username>FTP_User</username>
        <password>FTP_User_Password</password>
		<FolderA>C:\test1</FolderA> --- folder where should be new xml files
		<FolderB>C:\test2</FolderB> --- folder where to move uploaded files
		<waittime>60</waittime> --- time that service will wait to start upload
		<ftptime>60</ftptime> --- time that service will wait to run again
    </ftp>
</RootElement>



if((Test-Path $copyfrom\lockFile.lck) -eq 'True'){
Start-Sleep $sleep
} --- as i had need to run script from multiple pc and xml files were on shared folder, i set lock file so if script from one pc start with upload it will create lock file and other will not start
