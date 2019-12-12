write-host "Enter the last number "
$max_value=Read-Host
$stDate=get-date
$stIntDate=get-date

$max_value =[int]$max_value

$initial_Array= new-object bool[] $max_value

Write-Host "Initial array is set"
$endDate=get-date
$TimeSpan=$endDate-$stIntDate
$d=$TimeSpan.Days
$h=$TimeSpan.Hours
$m=$TimeSpan.Minutes
$s=$TimeSpan.Seconds

$str="It took "+ [string]$d +"d:"+[string]$h +"h:"+[string]$m +"m:"+[string]$s+"s to complete."
Write-Host $str
$stIntDate=get-date
$max_value--
#main algo
for($i=2; ($i*$i) -le $max_value; $i++){
    Write-Host "Checking for " $i
    if(-not($initial_Array[$i])){
        $j=$i
          while(($j*$i) -le $max_value){
                $initial_Array[$j*$i] = $true
                 $j++
                               
           }
          
    }
}
#Write-Host $initial_Array
write-host "Prime number marked"
$endDate=get-date
$TimeSpan=$endDate-$stIntDate
$d=$TimeSpan.Days
$h=$TimeSpan.Hours
$m=$TimeSpan.Minutes
$s=$TimeSpan.Seconds

$str="It took "+ [string]$d +"d:"+[string]$h +"h:"+[string]$m +"m:"+[string]$s+"s to complete."

Write-Host $str
$total_prime=0
$str=""
$stringbuilder = New-Object -TypeName System.Text.StringBuilder
for($i=2;$i -le $max_value; $i++){
    if(-not($initial_Array[$i])){
        $null=$stringbuilder.Append([String]$i)
        $null=$stringbuilder.Append(" ")
        $total_prime++
    }
}
Set-Content "prime.txt" $stringbuilder.ToString()
$str= "Total Prime " + $total_prime
Add-Content "prime.txt" $str

write-host "Total Prime "  $total_prime

$endDate=get-date
$TimeSpan=$endDate-$stDate
$d=$TimeSpan.Days
$h=$TimeSpan.Hours
$m=$TimeSpan.Minutes
$s=$TimeSpan.Seconds

$str="Total time taken "+ [string]$d +"d:"+[string]$h +"h:"+[string]$m +"m:"+[string]$s+"s to complete."
Write-Host $str
Add-Content "prime.txt" $str

