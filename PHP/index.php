<?PHP
	$counter = file_get_contents('counter.txt');
	if(isset($_GET['new'])) {
		$counter = intval($counter) + 1;
		file_put_contents('counter.txt', $counter);
	}
	echo 'RTH' . $counter;

