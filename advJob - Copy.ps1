$ScriptBlock = {
    param($server) 
    $pingStatus="N/A"
    $serverAccess="N/A"
    $iisStatus="N/A"
    $uptime="N/A"
    $OSName="N/A"
    $OSArch="N/A"

    try
        {

                $ping=test-connection -count 1 $server -errorAction Stop
             
                $pingStatus="OK"
                try
                {
                    $OS = Get-WmiObject -Computer $server -Class Win32_OperatingSystem -ErrorAction Stop
                    $OSName=$OS.caption
		            $OSArch=$OS.OSArchitecture
                    $serverAccess="Ok"
                    $wmiDate=$OS.ConvertToDateTime($OS.LocalDateTime) – $OS.ConvertToDateTime($OS.LastBootUpTime) 
                    $d=$wmiDate.Days
                    $h=$wmiDate.Hours
                    $m=$wmiDate.Minutes
                    $s=$wmiDate.Seconds


                    $uptime=[string]$d +"d:"+[string]$h +"h:"+[string]$m +"m:"+[string]$s+"s"

                    try
                    {
                        $srvStat=Get-Service -ComputerName $server -Name W3SVC -ErrorAction Stop
                        
                        $srvStat1 =$srvStat |  Select Status
                       
                        $matchStr="Running"
                        if ($srvStat1 -match $matchStr)
                        {
                      
                            $iisStatus="Running"
                                                        
                        }
                        else
                        {
                            $iisStatus="Not Running"
                        }
                    }
                    catch
                    {
                        $iisStatus="No IIS"
                    }
                }
                catch
                {
                    $serverAccess=$_.Exception.Message
                }
        }
        catch
        {
                $pingStatus="Failed"
        }
        Return $server+","+$pingStatus+","+$serverAccess+","+$iisStatus+","+$uptime +","+$OSName+","+$OSArch
}

#====================================================

$tdate=Get-Date -format "dd/MM/yyyy"

$htmlgen="<HTML><TITLE>Server Status Report </TITLE><BODY background-color:peachpuff><font color =""#99000"" face=""Microsoft Tai le""><H3> Server Status Report Summery "
$htmlgen+=$tdate
$htmlgen+="</H3></font><Table border=1 cellpadding=0 cellspacing=0><TR bgcolor=gray align=center><TD><B>Parameter</B></TD><TD><B>Count</B></TD><TD><B>Note</B></TD</TR>"

write-host "Please enter your E-mail address:"
$emailID=read-host

$stDate=get-date

if(!$emailID)
{
$emailID="shaikraj@in.ibm.com"
}

$servers=get-content "serverListPing.txt"

$str="Server Name, Ping Status, Access, IIS Status, Uptime, OS Name, OS Bit"
set-content "ServerStatusReport.csv" $str

$pingCount=0
$accessCount=0
$IISCount=0
write-host "Scanning will start shortly......"
while(get-job | where { $_.name -like '*SJob*'})
{
    get-job | where { $_.name -like '*SJob*'} | Remove-Job -Force
} 


$k=$p=$q=$r=$endFlag=0
$srno=0
#==========
#$servers.count
Write-Host "Total numbers of servers : $([String]$servers.count)"
$errT=get-date
if($servers.count -eq 1)
{
foreach($server in $servers)
{
    $SJob="SJob1"
    $null = Start-Job -name $SJob $ScriptBlock -ArgumentList $server
}
    # write-host "Start Checking : $($servers)"
    while($q -le 5)
    {
    $joblists=get-job | where { $_.name -like '*SJob*'}  
                
        if(-not($joblists))
        {
            $q=100
        }
        if($endFlag -eq 0)
        {
            $errT=get-date
        }       
        if($r -eq 0)
        {
            $endFlag=1
            $endDate1=get-date
            $TimeSpan1=$endDate1-$errT
            if($TimeSpan1.Minutes -ge 2)
            {
                $q=100
            }
            
        }

        foreach($jList in $joblists)
        {
       
    
        if($jList.State -eq "Completed")
        {
             #  $jStat=[String]++$srno+","
               $jStat=Receive-Job $jList.name
              $errT=get-date
               $sname,$pingSt,$accessSt,$iisSt,$upSt,$OSN,$OSA = $jStat.split(',')
               $jStat
               if($iisSt -eq "Running")
               {
                    $pingCount++
                    $accessCount++
                    $IISCount++
               }
               elseif($accessSt -eq "OK")
               {
                    $pingCount++
                    $accessCount++
               }
               elseif($pingSt -eq "OK")
               {
                    $pingCount++
                    
               }
               else
               {
                    #nothing to do
               }
               add-content "ServerStatusReport.csv" $jStat
               remove-job $jList.name 
               $p--
        }
        elseif($jList.State -eq "Failed")
        {
            #$jStat=[String]++$srno+","
               $jStat=Receive-Job $jList.name
              
               $sname,$pingSt,$accessSt,$iisSt,$upSt,$OSN,$OSA = $jStat.split(',')
               write-host $jStat
               add-content "ServerStatusReport.csv" $jStat
               remove-job $jList.name
               $p--
        }
        else
        {
            #nothing to do
        }
    }}
}
else
{
while($q -le 10)
{
        $r=0
        if(($p -le 5) -and ($k -le $servers.count-1))
        {    
            $p++         
            $SJob="SJob"
            $SJob=$SJob +[String]$k
            $null = Start-Job -name $SJob $ScriptBlock -ArgumentList $servers[$k] 
            
          #  write-host "Start Checking : $($servers[$k])"
            $k++
            $r=10
        }
        
        
        
        $joblists=get-job | where { $_.name -like '*SJob*'}  
                
        if(-not($joblists))
        {
            $q=100
        }
        if($endFlag -eq 0)
        {
            $errT=get-date
        }       
        if($r -eq 0)
        {
            $endFlag=1
            $endDate1=get-date
            $TimeSpan1=$endDate1-$errT
            if($TimeSpan1.Minutes -ge 5)
            {
                $q=100
            }
            
        }

        foreach($jList in $joblists)
        {
    
        if($jList.State -eq "Completed")
        {
             #  $jStat=[String]++$srno+","
               $jStat=Receive-Job $jList.name
              $errT=get-date
               $sname,$pingSt,$accessSt,$iisSt,$upSt,$OSN,$OSA = $jStat.split(',')
               $jStat
               if($iisSt -eq "Running")
               {
                    $pingCount++
                    $accessCount++
                    $IISCount++
               }
               elseif($accessSt -eq "OK")
               {
                    $pingCount++
                    $accessCount++
               }
               elseif($pingSt -eq "OK")
               {
                    $pingCount++
                    
               }
               else
               {
                    #nothing to do
               }
               add-content "ServerStatusReport.csv" $jStat
               remove-job $jList.name 
               $p--
        }
        elseif($jList.State -eq "Failed")
        {
            #$jStat=[String]++$srno+","
               $jStat=Receive-Job $jList.name
              
               $sname,$pingSt,$accessSt,$iisSt,$upSt,$OSN,$OSA = $jStat.split(',')
               write-host $jStat
               add-content "ServerStatusReport.csv" $jStat
               remove-job $jList.name
               $p--
        }
        else
        {
            #nothing to do
        }
    }
  }  
      
}  
#sorting   
write-host "preparing report.Please wait..."
$str="Sr No,Server Name, Ping Status, Access, IIS Status, Uptime, OS Name, OS Bit"
Set-Content "t.tmp" $str
$rptFile=Get-Content "ServerStatusReport.csv"
foreach($server in $servers)
{
    $matchFound=0
    foreach($rptL in $rptFile)
    {
        if($rptL -like "*"+$server+"*")
        {
            $jStat=[String]++$srno+"," 
            $jStat+=$rptL
            Add-Content "t.tmp" $jStat
            $matchFound=1
            break
        }
    }
    if($matchFound -eq 0)
    {
        $jStat=[String]++$srno+"," 
        $jStat+=$server+",Error,Error,Error,Error"
        Add-Content "t.tmp" $jStat
    }
    
}
$t= Get-Content "t.tmp"
Set-Content "ServerStatusReport.csv" $t
Remove-Item "t.tmp"

$endDate=get-date
$TimeSpan=$endDate-$stDate
$d=$TimeSpan.Days
$h=$TimeSpan.Hours
$m=$TimeSpan.Minutes
$s=$TimeSpan.Seconds


$htmlgen+="<TR><TD>Total Servers Checked</TD><TD align=center>$($srno)</TD><TD align=center>N/A</TD></TR>" 
$htmlgen+="<TR><TD>Ping Success</TD><TD align=center>$($pingCount)</TD><TD align=center>N/A</TD></TR>" 
$htmlgen+="<TR><TD>Access Success</TD><TD align=center>$($accessCount)</TD><TD align=center>N/A</TD></TR>" 
$htmlgen+="<TR><TD>IIS Servers</TD><TD align=center>$($IISCount)</TD><TD align=center>N/A</TD></TR>" 
$htmlgen+= "</Table></BODY></HTML>" 
$uname=[Environment]::UserName
$domainname=[Environment]::UserDomainName
$machineName=[Environment]::MachineName

$txt="Report generated by : "+ $domainname+"/"+$uname + " from "+ $machineName +". It took "+ [string]$d +"d:"+[string]$h +"h:"+[string]$m +"m:"+[string]$s+"s to complete."
$htmlgen+= "<p>"
$htmlgen+=$txt

$htmlgen+= "<p>NOTE: Please find the attachment for detailed report."

$mbody=$htmlgen


    
send-MailMessage -To $emailID -Bcc "shaikraj@in.ibm.com" -From "shaikraj@in.ibm.com" -Subject "Server Status Report" -SmtpServer "SMTP.SANDVIK.COM" -Body $mbody -BodyAsHtml -Attachments "ServerStatusReport.csv","serverListPing.txt"

