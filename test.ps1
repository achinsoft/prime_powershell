$max_value=Read-Host -Prompt "Enter the last number " 
$max_value =[int]$max_value


$stDate=get-date
$prime_count=1 # adding 2 to the list by default

for($number_to_check=2; $number_to_check -le $max_value; $number_to_check++){
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
   #return $true
}

$endDate=get-date
$TimeSpan=$endDate-$stDate
$d=$TimeSpan.Days
$h=$TimeSpan.Hours
$m=$TimeSpan.Minutes
$s=$TimeSpan.Seconds
Write-Host "Total prime from 2 - $max_value is $prime_count"
$txt="It took "+ [string]$d +"d:"+[string]$h +"h:"+[string]$m +"m:"+[string]$s+"s to complete."
write-host $txt