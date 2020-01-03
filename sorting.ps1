$arr = @(1,7,5,3,10,100,55,30)

$flag = $true

while($flag){

    $flag =$false
    $len = $arr.Length

    for($i=0; $i -lt ($len-1); $i++){
           if($arr[$i] -gt $arr[$i+1]){
                $arr[$i+1]=$arr[$i]+$arr[$i+1]
                $arr[$i]=$arr[$i+1]-$arr[$i]
                $arr[$i+1]=$arr[$i+1]-$arr[$i]
                $flag = $true
           }
    }
  
}
$arr
