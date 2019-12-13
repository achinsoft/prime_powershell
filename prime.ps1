$ScriptBlock = {
    param($sMin_val,$sMax_val,$initial_Array,$segment_number,$p)
        # Write-Host $sMin_val
          $i=$sMin_val
        
          while(($i*$p) -le $sMax_val){
        
            $initial_Array[(($p*$i)-$sMin_val)] = $true
            $i++             
       }

   # write-host $initial_Array
   return $initial_Array
}

#====================================================

$max_value=Read-Host -Prompt "Enter the last number " 
$max_value =[int]$max_value
$total_thread = 4
while($max_value%$total_thread -ne 0){
    $max_value++
}
Write-Host -ForegroundColor Yellow "Range is accecpted as 0 -"$max_value

$segment_array_size = $total_thread*2
$segment_size = [int]($max_value/$total_thread)

$initial_Array= new-object bool[] $segment_size
$segment_array = new-object int[] $segment_array_size
$start_value_segment = 0
$end_value_segment = $segment_size
$segment_index=0
$segment_array[$segment_index] = $start_value_segment
$segment_index++
$segment_array[$segment_index] = $end_value_segment
for($i=0; $i -le ($total_thread-2); $i++){
    $start_value_segment+=$segment_size
    $end_value_segment+=$segment_size
    $segment_index++
    $segment_array[$segment_index] = $start_value_segment
    $segment_index++
    $segment_array[$segment_index] = $end_value_segment
   
}
Write-Host $segment_array
Write-Host "Initial array is set"
write-host "Scanning will start shortly......"
while(get-job | where { $_.name -like '*SJob*'}){
    get-job | where { $_.name -like '*SJob*'} | Remove-Job -Force
} 

$Max_val--
#main algo
for($p=2; ($p*$p) -le $max_value; $p++){
$segment_index=0
    if(-not($initial_Array[$p])){
        write-host "Checking : "$p
        for($i=0; $i -le ($total_thread-1); $i++){
            $SJob="SJob-" +[string]$i
            $sMin_val=$segment_array[$segment_index]
            $segment_index++
            $sMax_val=$segment_array[$segment_index]
            Write-Host "sMax_val : $sMax_val   sMin_val : $sMin_val"

            $segment_index++
            $segment_number = $i
            write-host "job start"
            $null = Start-Job -name $SJob $ScriptBlock -ArgumentList ($sMin_val,$sMax_val,$initial_Array,$segment_number,$p)
        }
        $joblists=get-job | where { $_.name -like '*SJob*'}
        
        foreach($jList in $joblists)
        {
            while(-not($jList.State -eq "Completed")){
        
            } 
            $initial_Array=Receive-Job $jList.name
            remove-job $jList.name 
           # $joblists
        }

    }   
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
      