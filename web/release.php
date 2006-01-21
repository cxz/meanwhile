<?
	global $mw_release, $mw_release_url;
	global $mw_gaim, $mw_gaim_url;

	// the files base for our project
	$base_url = "http://sourceforge.net/project/showfiles.php" .
		"?group_id=110565";

	// the only part that should need to change for these is the
	// name of the release, and the release_id

	$mw_release = "meanwhile 1.0.2";
	$mw_release_url = $base_url . "&amp;package_id=119439" .
		"&amp;release_id=356768";

	$mw_gaim = "gaim-meanwhile 1.2.8";
	$mw_gaim_url =  $base_url . "&amp;package_id=119703" .
		"&amp;release_id=387119";
?>

