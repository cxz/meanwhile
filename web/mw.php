<?= "<?xml version=\"1.0\" ?>\n" ?>

<?
global $full_path;
$full_path = "/home/groups/m/me/meanwhile/htdocs/";

global $title, $back, $body, $side, $links, $date;


$page_title = "Meanwhile Project";
if($title && $title != $page_title)
	$page_title = $page_title . " | " . $title;

if(! $date) $date = date("Y-m-d", filemtime($back . $body));


function drawLink($href, $test) {
	global $back, $title;
	echo ($test == $title)?
		"<p class=\"depth_1\">$test</p>\n":
		"<a class=\"depth_1\" href=\"$back$href\">$test</a>\n";
}

?>

<?
global $mw_release, $mw_release_url;
global $mw_gaim, $mw_gaim_url;

/* using a require here, because occasionally sf.net's php craps out */
require($full_path . "release.php");
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<meta http-equiv="Robots" content="index,nofollow" />
<meta name="Description" content="Meanwhile Project Home Page" />
<meta name="Keywords" content="Meanwhile Sametime Linux Gaim" />
<meta name="DC.Date" scheme="iso8601" content="<?= $date ?>" />
<meta name="DC.Language" scheme="rfc1766" content="en-US" />

<title><? echo($page_title); ?></title>

<link rel="stylesheet" type="text/css" href="<?= $back ?>_style/mw.css" />
</head>

<body>


  <!-- ==================================================================== -->
  <!-- the site title, the sf.net logo, stuff -->
  <div id="dHead">
    <p class="hide"><a href="#content">Skip to content</a></p>

    <div id="dHeadTitle">
      <? echo($page_title); ?>
    </div>

    <div id="dHeadLogo">
      <a href="http://sf.net/"><img
       src="http://sf.net/sflogo.php?group_id=110565&amp;type=1"
       alt="SF.net" width="88" height="31" border="0" /></a>
    </div>

    <div id="dHeadNav">
      <a href="http://sf.net/">SF.net</a> |
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
	<?
	drawLink("", "Meanwhile Project");
	/* drawLink("news/", "News"); */
	drawLink("download/", "Download");
	drawLink("docs/", "Documentation");
	drawLink("plugins/", "Client Plugins");
	drawLink("faq/", "Questions");
	drawLink("contact/", "Contact");
	?>
	</div>

        <div id="dNavJunk">
	  <ul>
	  <li>Latest Releases
	    <ul>
	    <li><a href="<?= $mw_release_url ?>"><?= $mw_release ?></a></li>
	    <li><a href="<?= $mw_gaim_url ?>"><?= $mw_gaim ?></a></li>
	    </ul></li>

	  <li>SF.net
	    <ul>
	    <li><a href="http://sf.net/projects/meanwhile">Project Page</a></li>
	    <li><a href="http://sf.net/projects/meanwhile/files/">Files</a></li>
	    <li><a href="http://sf.net/forum/?group_id=110565">Forums</a></li>
	    <li><a href="http://sf.net/tracker/?group_id=110565">Trackers</a></li>
	    </ul></li>
	  </ul>
        </div>

	<div id="dNavLink">
		<? if($links) require($full_path . $links); ?>
	</div>

	<div id="dFriendlies">
		<a href="http://www.spreadfirefox.com/?q=affiliates&amp;id=0&amp;t=86"><img border="0" width="125" height="50" alt="Get Firefox!" title="Get Firefox!" src="http://spreadfirefox.com/community/images/affiliates/Buttons/125x50/takebacktheweb_125x50.png" /></a>
	</div>

      </td>

      <!-- ================================================================ -->
      <!-- date and nested path heading -->
      <td id="dMainHead" colspan="2">
	<p>Last Modified: <? if($date) echo $date; ?></p>
      </td>

    </tr>

    <!-- ================================================================== -->
    <!-- the wide body, or the narrow body and a sidebar -->
    <tr>
      <? if($side) { ?>
        <td id="dMainBody">
          <h1><?= $title ?></h1><a name="content"></a>
          <? require($full_path . $body); ?>
        </td>
        <td id="dMainSide">
          <? require($full_path . $side); ?>
        </td>

      <? } else { ?>
        <td colspan="2" id="dMainBody">
          <h1><?= $title ?></h1><a name="content"></a>
          <? require($full_path . $body); ?>
        </td>
      <? } ?>
    </tr>

  </table>

  <!-- ==================================================================== -->
  <!-- the footer -->
  <div id="dFoot">
    <p id="pGoodbye">Thanks for visiting</p>
    <p id="pCopyright">&copy; Christopher (siege) O'Brien, 2004</p>
  </div>


</body>
</html>

