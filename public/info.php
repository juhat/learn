<?php

phpinfo();

 session_start();
  
 // give wait messages some time
 sleep(1);
  
 // get command
 $cmd = isset($_REQUEST["cmd"]) ? $_REQUEST["cmd"] : false;
  
 // no command?
 if(!$cmd) {
 echo '{"success":false,"error":"No command"}';
 exit;
 }
  
 // load or save?
	switch($cmd) {
		case "load":
		$o = array(
			"success"=>true
			,"data"=>array(
				"firstName"=>"John"
				,"lastName"=>"Doe"
				,"email"=>"john.doe@example.com"
				,"friend"=>true
				,"note"=>"He's a good guy\ndoing more good than bad\nwe like him"
			)
		);
		break;
  
		case "save":
			$o = array(
			"success"=>isset($_SESSION["err"]) && $_SESSION["err"] ? false : true
			,"error"=>"An error simulation")
			;
		break;
	}
  
 // alternate between submit success and failure
 $_SESSION["err"] = isset($_SESSION["err"]) ? !$_SESSION["err"] : true;
  
 // return response to client
 header("Content-Type: application/json");
 echo json_encode($o);
?>


?>