
<?
global $mw_release, $mw_release_url;
global $mw_gaim, $mw_gaim_url;
?>

<h2>Release</h2>
<p>The current Meanwhile release is <a href="<?= $mw_release_url ?>"><?= $mw_release ?></a>, and the current Gaim plugin release is <a href="<?= $mw_gaim_url ?>"><?= $mw_gaim ?></a>.</p>

<p>Release numbering for the Gaim plugin currently mirrors the <a href="http://gaim.sf.net/">Gaim</a> release that the plugin portion is built against. Since Gaim often changes the plugin ABI significantly between releases, please make sure your versions match.</p>


<h2>CVS</h2>
<p>The CVS versions of meanwhile-gaim are built against the (near) current CVS
version of Gaim. Since the meanwhile-gaim plugin code is therefore aiming at a
moving target, ocasionally the build will break. Ideally however, changes to
the Gaim prpl or plugin interfaces will be reflected in Meanwhile within a day
or two. If you're still feeling brave, simply follow these steps:</p>

<ol>

<li>Checkout the <code>gaim</code> module from Sourceforge anonymous CVS<br />
<a href="http://sourceforge.net/cvs/?group_id=235">http://sourceforge.net/cvs/?group_id=235</a></li>

<li>Build and install first gaim, then meanwhile, then meanwhile-gaim. Simply running the following in each sandbox should work:<br />
<code>./autogen.sh &amp;&amp; ./configure &amp;&amp; make all &amp;&amp; su -c "make install"</code></li>

<li>Run <code>ldconfig</code> as root. This will ensure that your system will be able to load the meanwhile libraries when gaim starts.</li>

<li>Start up Gaim, and with luck you'll be ready to go!</li>
</ol>

