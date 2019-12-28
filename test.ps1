$max_value=100
for($number_to_check=2; $number_to_check -le $max_value; $number_to_check++){
#$number_to_check=3
$number_to_divide = 2
$flag = $true
    while($number_to_divide -le ($number_to_check/2)){
        $division_result = $number_to_check % $number_to_divide
        if ($division_result -eq 0){
           # write-host  "Not Prime $number_to_check"
            $flag = $false
            break
            #  return $false
        }
           $number_to_divide++   
       }
  
  if($flag){
    write-host  "Prime $number_to_check"
  }     
   #return $true
    }