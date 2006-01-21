
<?
global $mw_release, $mw_release_url;
global $mw_gaim, $mw_gaim_url;
?>

<h2>Release</h2>
<p>The current Meanwhile release is <a href="<?= $mw_release_url ?>"><?= $mw_release ?></a>, and the current Gaim plugin release is <a href="<?= $mw_gaim_url ?>"><?= $mw_gaim ?></a>.</p>

<p>Release numbering for the Gaim plugin indicates the <i>exact</i> major
and <i>minimum</i> minor version of Gaim required for the plugin to function.
The micro number only differentiates plugin releases and doesn't relate to
Gaim in any way.</p>

<h2>Repositories</h2>
<p>The following repositories distribute the meanwhile and/or gaim-meanwhile
packages</p>

<ul>
<li><a href="http://rpmforge.net/user/">RPMforge.net</a></li>
<li><a href="http://fedoraproject.org/wiki/Extras">Fedora Extras</a></li>
<li><a href="http://www.gentoo-portage.com/">Gentoo Portage</a></li>
<li><a href="http://www.linuxpackages.net/search_view.php?by=name&name=meanwhile&ver=">Slackware Linuxpackages</a></li>
</ul>

<h2>CVS</h2>
<p>The CVS versions of meanwhile, gaim-meanwhile, and meanwhile-python are
written to work with each other, rather than to work with any  of the existing
releases. Because it's a rather dynamic environment, one or two of the modules
may be un-buildable from time to time.</p>

<p>Follow the instructions on the <a href="https://sourceforge.net/cvs/?group_id=110565">CVS page</a> to checkout a local
sandbox. Please keep in mind that the anonymous CVS access is lagged behind
developer CVS access by four to eight hours.</p>

<p>To build from CVS, just check out the appropriate module and
use <code>autogen.sh</code> to generate the configure script. gaim-meanwhile
has a handy <code>private-install</code> target to install the plugin to
<code>$HOME/.gaim/plugins/</code></p>


