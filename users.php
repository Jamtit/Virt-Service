<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User</title>
</head>
<body>
<div style="width: 60%; height:300px; background-color: rgb(33, 176, 78); color:white; margin: 0 auto!important; display: grid; grid-template-columns: 1fr 1fr; font-family: Arial, Helvetica, sans-serif;">
<!-- <div style="display:flex; justify-content: center; align-items:center; color:white">User</div> -->
<!-- <div style="display:flex; justify-content: center; align-items:center"></div> -->
<?php

include 'vars.php';

$conn = pg_connect("host=".$ip. "port=5432 dbname=postgres user=postgres password=1234");
if (!$conn) {
  echo "An error occurred.\n";
  exit;
}

$result = pg_query($conn, "SELECT * FROM data");
if (!$result) {
  echo "An error occurred.\n";
  exit;
}

while ($row = pg_fetch_row($result)) {
    $div1 = '<div style="display:flex; justify-content: center; align-items:center">' . $row[0] . '</div>';

// $CENDPOINT='https://grid5.mif.vu.lt/cloud3/RPC2'
// shell_exec('onetemplate instantiate "debian11" --name '.$row[0].' --user '.$row[0].' --password '.$row[1]'  --endpoint '.$CENDPOINT.)
    
    echo $div1;
  }
?> 
</div>

</body>
</html>
