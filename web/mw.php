<?php echo("<?xml version=\"1.0\" ?>\n"); ?>

<?php
global $full_path;
$full_path = "/home/groups/m/me/meanwhile/htdocs/";

global $title, $back, $body, $side, $links, $date;


$page_title = "Meanwhile Project";
if($title && $title != $page_title)
	$page_title = $page_title . " | " . $title;

if(! $date)
	$date = date("Y-m-d", filemtime($back . $body));


function drawLink($href, $test, $depth) {
	global $back, $title;
	echo ($test == $title)?
		"<p class=\"depth_$depth\">$test</p>\n":
		"<a class=\"depth_$depth\" href=\"$back$href\">$test</a>\n";
}

?>

<?php
global $mw_release, $mw_release_url;
global $mw_gaim, $mw_gaim_url;

/* using a require here, because occasionally sf.net's php craps out */
require($full_path . "release.php");
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<meta http-equiv="Robots" content="index,follow" />
<meta name="Description" content="Meanwhile Project Home Page" />
<meta name="Keywords" content="Meanwhile Sametime Linux Gaim" />
<meta name="DC.Date" scheme="iso8601" content="<?= $date ?>" />
<meta name="DC.Language" scheme="rfc1766" content="en-US" />

<title><?= $page_title ?></title>

<link rel="stylesheet" type="text/css" href="<?= $back ?>_style/mw.css" />
</head>

<body>


  <!-- ==================================================================== -->
  <!-- the site title, the sf.net logo, stuff -->
  <div id="dHead">
    <p class="hide"><a href="#content">Skip to content</a></p>

    <div id="dHeadTitle">
      The Meanwhile Project
      <p class="subtitle">An Open Re-Implementation of Lotus Sametime</p>
    </div>

    <div id="dHeadLogo">
      <a href="http://sourceforge.net/"><img
       src="http://sflogo.sourceforge.net/sflogo.php?group_id=110565&amp;type=1"
       alt="SF.net" width="88" height="31" /></a>
    </div>

    <div id="dHeadNav">
      <a href="https://sourceforge.net/">SF.net</a> |
      <a href="http://gnu.org/copyleft/gpl.html">GNU GPL</a> |
      <a href="https://sourceforge.net/donate/index.php?group_id=110565">Donate</a>
    </div>
  </div>


  <table id="tLayout">
    <colgroup>
      <col id="cNav" />
      <col id="cBody" />
      <col id="cSide" />
    </colgroup>
 
    <tr>
      <!-- ================================================================ -->
      <!-- the menu, optional related links -->
      <td id="dNav" rowspan="2">
	<div id="dNavMenu">
	<?php
	drawLink("", "Meanwhile Project", 1);
	/* drawLink("news/", "News", 1); */
	drawLink("plugins/", "Client Plugins", 1);
	drawLink("download/", "Download", 1);
	drawLink("docs/", "Documentation", 1);
	drawLink("wiki/", "Wiki", 2);
	drawLink("faq/", "Questions", 2);
	drawLink("contact/", "Contact", 1);
	?>
	</div>

        <div id="dNavJunk">
	  <ul>
	  <li>Latest Releases
	    <ul>
<?php printf("<li><a href=\"%s\">%s</a></li>",$mw_release_url,$mw_release); ?>
<?php printf("<li><a href=\"%s\">%s</a></li>",$mw_gaim_url,$mw_gaim); ?>
	    </ul></li>

	  <li>SF.net
	    <ul>
	    <li><a href="https://sourceforge.net/projects/meanwhile">Project Page</a></li>
	    <li><a href="https://sourceforge.net/projects/meanwhile/files/">Files</a></li>
	    <li><a href="https://sourceforge.net/forum/?group_id=110565">Forums</a></li>
	    <li><a href="https://sourceforge.net/tracker/?group_id=110565">Trackers</a></li>
	    <li><a href="http://cvs.sourceforge.net/viewcvs.py/meanwhile/">CVS</a></li>
	    </ul></li>
	  </ul>
        </div>

	<div id="dNavLink">
		<?php if($links) require($full_path . $links); ?>
	</div>

	<div id="dNavFriendlies">
		<p><a href="http://www.spreadfirefox.com/?q=affiliates&amp;id=0&amp;t=86"><img width="125" height="50" alt="Get Firefox!" title="Get Firefox!" src="http://spreadfirefox.com/community/images/affiliates/Buttons/125x50/takebacktheweb_125x50.png" /></a></p>
		<p>Valid <a href="http://validator.w3.org/check/referer">XHTML</a> and <a href="http://jigsaw.w3.org/css-validator/check/referer">CSS</a></p>
	</div>

      </td>

      <!-- ================================================================ -->
      <!-- date and nested path heading -->
      <td id="dMainHead" colspan="2">
	<p>Last Modified: <?= $date ?></p>
      </td>

    </tr>

    <!-- ================================================================== -->
    <!-- the wide body, or the narrow body and a sidebar -->
    <tr>
      <?php if($side) { ?>
        <td id="dMainBody">
          <h1><?= $title ?></h1><a name="content"></a>
          <?php require($full_path . $body); ?>
        </td>
        <td id="dMainSide">
          <?php require($full_path . $side); ?>
        </td>

      <?php } else { ?>
        <td colspan="2" id="dMainBody">
          <h1><?= $title ?></h1><a name="content"></a>
          <?php require($full_path . $body); ?>
        </td>
      <?php } ?>
    </tr>

  </table>

  <!-- ==================================================================== -->
  <!-- the footer -->
  <div id="dFoot">
    <p id="pGoodbye">Thanks for visiting, hope you found something useful.</p>
    <p id="pCopyright">
	Site content &copy; Christopher (siege) O'Brien, 2005.
	Site and project are neither endorsed by<br />
	nor affiliated with IBM or Lotus. Lotus and Sametime are trademarks
	of Lotus Development<br />
	Corportation and/or IBM Corporation.</p>
  </div>


</body>
</html>

