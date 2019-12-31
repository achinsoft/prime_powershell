$ScriptBlock = {
    param($start, $end)
    #write-host "start = $start and end = $end"
    for($number_to_check=$start; $number_to_check -le $end; $number_to_check++){
        #$number_to_check=3
        $number_to_divide = 2
        $division_result =  $number_to_check % $number_to_divide
        if ($division_result -eq 0){
        }else{
          $number_to_divide = 3
          $flag = $true
         # while($number_to_divide -le ($number_to_check/2)){
          while($number_to_divide -le ([math]::Sqrt($number_to_check))){
            $division_result = $number_to_check % $number_to_divide
            if ($division_result -eq 0){
                $flag = $false
                break
            }
            $number_to_divide=$number_to_divide+2   
          }
          if($flag){
            $prime_count++
          #write-host  "Prime $number_to_check"
          }     
        }
    }
    #write-host "Prime count = $prime_count"
return $prime_count
}

$str=""
Set-Content "prime.txt" $str
$max_value=Read-Host -Prompt "Enter the last number " 
$max_value =[int]$max_value
$total_thread = 4
while($max_value%$total_thread -ne 0){
    $max_value++
}
Write-Host -ForegroundColor Yellow "Range is accecpted as 0 -"$max_value
$stDate=get-date

while(get-job | where-object { $_.name -like '*SJob*'}){
    get-job | where-object { $_.name -like '*SJob*'} | Remove-Job -Force
} 
$segment_start_value = 3
$segment_value = $max_value/$total_thread
for($i = 0; $i -lt $total_thread; $i++){
    $SJob="SJob-" +[string]$i
    if($i -eq 0){
        $segment_start_value = 3
    }else{
        $segment_start_value = $segment_end_value + 1
    }
    $segment_end_value = $segment_start_value + $segment_value
    if($segment_end_value -gt $max_value){
        $segment_end_value = $max_value
    }
    write-host "Start : $segment_start_value and End : $segment_end_value"
    $null = Start-Job -name $SJob $ScriptBlock -ArgumentList ($segment_start_value, $segment_end_value)

}
#$SJob = "SJob-01"
#$null = Start-Job -name $SJob $ScriptBlock -ArgumentList ($segment_start_value, $segment_end_value)
#$segment_start_value =  $segment_end_value + 1
#$segment_end_value = $max_value
#$SJob = "SJob-02"
#$null = Start-Job -name $SJob $ScriptBlock -ArgumentList ($segment_start_value, $segment_end_value)
$joblists=get-job | where-object { $_.name -like '*SJob*'}
#$joblists
$prime_count = 1
$prime_val = 0
foreach($jList in $joblists)
{
    while(-not($jList.State -eq "Completed")){
        sleep 10
    } 
    $prime_val = Receive-Job $jList.name
    write-host "Prime count in segemnt $($jList.Name) = $prime_val"
    remove-job $jList.name
    if($prime_val -ge 0){
        $prime_count +=$prime_val
        $prime_val = 0
    }
}
write-host "Total prime in the range of 2 - $max_value is : $prime_count"  
$endDate=get-date
$TimeSpan=$endDate-$stDate
$d=$TimeSpan.Days
$h=$TimeSpan.Hours
$m=$TimeSpan.Minutes
$s=$TimeSpan.Seconds
write-host "It took $($d)d:$($h)h:$($m)m:$($s)s to complete."       