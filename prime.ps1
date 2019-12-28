$ScriptBlock = {
    param($number_to_check)
    $flag = $true
    $number_to_divide = 2
    while($number_to_divide -le ($number_to_check/2)){
        $division_result = $number_to_check % $number_to_divide
        if ($division_result -eq 0){
            $flag = $false
            break
        }
           $number_to_divide++   
       }
    if($flag){
        $data = $number_to_check
    }else{
        $data = 0
    }
    return $data
}

#====================================================
$str=""
Set-Content "prime.txt" $str
$max_value=Read-Host -Prompt "Enter the last number " 
$max_value =[int]$max_value
$total_thread = 2
while($max_value%$total_thread -ne 0){
    $max_value++
}
Write-Host -ForegroundColor Yellow "Range is accecpted as 0 -"$max_value

write-host "Scanning will start shortly......"
while(get-job | where-object { $_.name -like '*SJob*'}){
    get-job | where-object { $_.name -like '*SJob*'} | Remove-Job -Force
} 
$prime_count = 0
$number = 2
$running_thread_count = 0
while($number -le $max_value){
    while($running_thread_count -le $total_thread){
        $SJob="SJob-" +[string]$running_thread_count
        write-host "job start for $number with thread count $running_thread_count"
        $thread_flag++
        $null = Start-Job -name $SJob $ScriptBlock -ArgumentList ($number)
        $number++
        $running_thread_count++
    }
    $joblists=get-job | where-object { $_.name -like '*SJob*'}
    #$joblists
    foreach($jList in $joblists)
    {
        if($running_thread_count -ge 0){
            while(-not($jList.State -eq "Completed")){
            } 
            $prime_val=Receive-Job $jList.name
            if($prime_val -ge 1){
                $prime_count++
                write-host "prime number $prime_val"
                $str=[String]$prime_val
                Add-Content "prime.txt" $str
            }
            remove-job $jList.name
            $running_thread_count--
            }else{
             break
        }
    }
        
}
write-host "Total Primes in the range $prime_count"
$str="Total primes count $prime_count"
Add-content "prime.txt" $str
