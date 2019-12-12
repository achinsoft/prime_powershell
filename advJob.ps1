

############################################################################## 
## 
## IIS Server Report
## Created by Shaikh Wasim Raja  
## Date : 10 Jan 2019 
## Version : 2.0 
## Email: shaikraj@in.ibm.com   
############################################################################## 

$ScriptBlock = {
    param($server) 
    $pingStatus="N/A"
    $serverAccess="N/A"
    $iisStatus="N/A"
    $uptime="N/A"
    try
        {

                $ping=test-connection -count 1 $server -errorAction Stop
             
                $pingStatus="OK"
                try
                {
                    $OS = Get-WmiObject -Computer $server -Class Win32_OperatingSystem -ErrorAction Stop
                 
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
                    $serverAccess="Denied"
                }
        }
        catch
        {
                $pingStatus="Failed"
        }
        Return $server+","+$pingStatus+","+$serverAccess+","+$iisStatus+","+$uptime
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

$str="Server Name, Ping Status, Access, IIS Status, Uptime"
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
$srno++
$pingStatus="N/A"
    $serverAccess="N/A"
    $iisStatus="N/A"
    $uptime="N/A"
    try
        {

                $ping=test-connection -count 1 $servers -errorAction Stop
             
                $pingStatus="OK"
                try
                {
                    $OS = Get-WmiObject -Computer $servers -Class Win32_OperatingSystem -ErrorAction Stop
                 
                    $serverAccess="Ok"
                    $wmiDate=$OS.ConvertToDateTime($OS.LocalDateTime) – $OS.ConvertToDateTime($OS.LastBootUpTime) 
                    $d=$wmiDate.Days
                    $h=$wmiDate.Hours
                    $m=$wmiDate.Minutes
                    $s=$wmiDate.Seconds

                    $uptime=[string]$d +"d:"+[string]$h +"h:"+[string]$m +"m:"+[string]$s+"s"

                    try
                    {
                        $srvStat=Get-Service -ComputerName $servers -Name W3SVC -ErrorAction Stop
                        
                        $srvStat1 =$srvStat |  Select Status
                       
                        $matchStr="Running"
                        if ($srvStat1 -match $matchStr)
                        {
                      
                            $iisStatus="Running"
                            $pingCount++
                    $accessCount++
                    $IISCount++
                                                        
                        }
                        else
                        {
                            $iisStatus="Not Running"
                        }
                    }
                    catch
                    {
                        $iisStatus="No IIS"
                        $pingCount++
                    $accessCount++
                    }
                }
                catch
                {
                    $serverAccess="Denied"
                    $pingCount++
                }
        }
        catch
        {
                $pingStatus="Failed"
        }
        $jStat="1,"+$servers+","+$pingStatus +","+$serverAccess +","+$iisStatus +","+$uptime
        $jStat
        add-content "ServerStatusReport.csv" $jStat
}
else
{
while($q -le 10)
{
        $r=0
        if(($p -le 10) -and ($k -le $servers.count-1))
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
              
               $sname,$pingSt,$accessSt,$iisSt,$upSt = $jStat.split(',')
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
              
               $sname,$pingSt,$accessSt,$iisSt,$upSt = $jStat.split(',')
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
      

#sorting   
write-host "preparing report.Please wait..."
$str="Sr.No.,Server Name, Ping Status, Access, IIS Status, Uptime"
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
}  
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


    
send-MailMessage -To $emailID -Bcc "shaikraj@in.ibm.com" -From "shaikraj@sandvik.com" -Subject "Server Status Report" -SmtpServer "SMTP.SANDVIK.COM" -Body $mbody -BodyAsHtml -Attachments "ServerStatusReport.csv","serverListPing.txt"

