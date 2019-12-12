$ScriptBlock = {
    param($max_value,$initial_Array)
    $max_value-- 
    for($i=2; ($i*$i) -le $max_value; $i++){
      #  Write-Host "Checking for " $i
        if(-not($initial_Array[$i])){
            $j=$i
              while(($j*$i) -le $max_value){
                    $initial_Array[$j*$i] = $true
                    $j++
                                   
               }
              
        }
    }
 #   Write-Host $initial_Array
    
   return $initial_Array
}

#====================================================

write-host "Enter the last number "
$max_value=Read-Host
$max_value =[int]$max_value
$initial_Array= new-object bool[] $max_value
$segment_divider=10
$segment_size = [int]($max_value/10)
$segment_array = new-object int[] $segment_divider
$start_value_segment = 0
$end_value_segment = 0
$segment_size
$segment_index=0
for($i=0; $i -le 20; $i++){
    $start_value_segment = $start_value_segment + $segment_size
    $end_value_segment = $start_value_segment + $segment_size
    $segment_array[$segment_index]=$start_value_segment
    $segment_index++
    $segment_array[$segment_index]=$end_value_segment
    $segment_index++
}
write-host $segment_array
Write-Host "Initial array is set"
write-host "Scanning will start shortly......"
while(get-job | where { $_.name -like '*SJob*'})
{
    get-job | where { $_.name -like '*SJob*'} | Remove-Job -Force
} 
$SJob="SJob-" +[string]10
$null = Start-Job -name $SJob $ScriptBlock -ArgumentList ($max_value,$initial_Array)
$joblists=get-job | where { $_.name -like '*SJob*'}
#$joblists
foreach($jList in $joblists)
{
    while(-not($jList.State -eq "Completed")){
        
    } 
    $initial_Array=Receive-Job $jList.name
    #$jStat | Get-Member
    #write-host $initial_Array
    remove-job $jList.name 
}
$total_prime=0
$str=""
$stringbuilder = New-Object -TypeName System.Text.StringBuilder
$max_value--
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
      