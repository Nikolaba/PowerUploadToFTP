while($true){


$configfilePath = 'C:\Services\FTP\config\config.xml'
$settings = [xml](get-content $configfilePath)
$podesavanja = $settings.RootElement.ftp

###Log file
$LogFileName = (get-date).ToString("yyyyMMdd")
$logFile = "C:\services\ftp\Log\ftp_upload_$LogFileName.log"

$ftpaddress = $podesavanja.ftpaddress
$ftpuser = $podesavanja.username
$ftppass = $podesavanja.password
$copyfrom = $podesavanja.FolderA
$sleep = $podesavanja.waittime
$ftptime = $podesavanja.ftptime

if((Test-Path $copyfrom\lockFile.lck) -eq 'True'){
Start-Sleep $sleep
}
else{
#####Locking process
New-Item -Path $copyfrom -Name LockFile.lck -ItemType File

####Creating new folders
$folders = Get-ChildItem $copyfrom -Recurse | ?{ $_.PSIsContainer }
foreach($folder in $folders.Name){

try
{
$newFolder = "ftp://$ftpaddress/$folder"
$makeDirectory = [System.Net.WebRequest]::Create($newFolder);
$makeDirectory.Credentials = New-Object System.Net.NetworkCredential($ftpuser,$ftppass);
$makeDirectory.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory;
$makeDirectory.GetResponse() 
if($?){
$fcreataed = get-date
Add-Content $logFile "$fcreataed FOLDER $folder - Created"}
}catch [Net.WebException] {}
}
####Uploading files


foreach($foldetoupload in $folders){
    $foldername = $foldetoupload.name
    foreach($item in (dir $foldetoupload.FullName)){ 
       
        $ftp = "ftp://$ftpaddress/$foldername/"
        $webclient = New-Object System.Net.WebClient 
        $webclient.Credentials = New-Object System.Net.NetworkCredential($ftpuser,$ftppass)  
            #Start-Sleep -Seconds $ftptime 
            $uri = New-Object System.Uri($ftp+$item.Name) 
            $webclient.UploadFile($uri, $item.FullName)
            if($?){
                $uploadtime = Get-Date
                Add-Content $logFile "$uploadtime File $item Uploaded"
            Remove-Item $item.FullName
                   }
            }
            $directoryInfo = Get-ChildItem $foldetoupload.FullName | Measure-Object
            $number_of_files = $directoryInfo.count
            if($number_of_files -eq '0'){
            Remove-Item $foldetoupload.FullName}
            else{}
    }
$ftp = "ftp://$ftpaddress/"
$webclient = New-Object System.Net.WebClient 
$webclient.Credentials = New-Object System.Net.NetworkCredential($ftpuser,$ftppass)  
 
foreach($item in (dir $copyfrom -Exclude 'LockFile.lck'| where { ! $_.PSIsContainer })){ 
    $uri = New-Object System.Uri($ftp+$item.Name) 
    $webclient.UploadFile($uri, $item.FullName)
    if($?){
    $uploadtime = Get-Date
    Add-Content $logFile "$uploadtime File $item Uploaded"
    Remove-Item $item.FullName
    }

 }
                #####Unlocking process
                Remove-Item $copyfrom\lockFile.lck
}
 Start-Sleep -Seconds $sleep
 }

