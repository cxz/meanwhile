
<?
global $mw_release, $mw_release_url;
global $mw_gaim, $mw_gaim_url;
?>

<h2>Release</h2>
<p>The current Meanwhile release is <a href="<?= $mw_release_url ?>"><?= $mw_release ?></a>, and the current Gaim plugin release is <a href="<?= $mw_gaim_url ?>"><?= $mw_gaim ?></a>.</p>

<p>Release numbering for the Gaim plugin currently mirrors the <a href="http://gaim.sf.net/">Gaim</a> release that the plugin portion is built against. Since Gaim often changes the plugin ABI significantly between releases, please make sure your versions match.</p>


<h2>CVS</h2>
<p>The CVS versions of Meanwhile are built against the (near) current CVS
version of Gaim. Since the Meanwhile gaim plugin code is therefore aiming at a
moving target, ocasionally the build will break. Ideally however, changes to
the Gaim prpl or plugin interfaces will be reflected in Meanwhile within a day
or two. If you're still feeling brave, simply follow these steps:</p>

<ol>

<li>Checkout the <code>gaim</code> module from Sourceforge anonymous CVS<br />
<a href="http://sourceforge.net/cvs/?group_id=235">http://sourceforge.net/cvs/?group_id=235</a></li>

<li>Checkout the <code>meanwhile</code>, and
<code>meanwhile-gaim</code> modules from Sourceforge anonymous CVS</li>

<li>Build and install Gaim</li>

<li>Set the <code>gaim_src_dir</code> environment variable to point to the <code>src</code> directory in your Gaim sandbox</li>

<li>Run <code>./autogen.sh &amp;&amp; ./configure --with-gaim-source=$gaim_src_dir</code></li>

<li>Run <code>make all</code></li>

<li>Run <code>make install &amp;&amp; ldconfig</code> as root. You may need to
set the <code>libdir</code>, <code>includedir</code> and <code>datadir</code>
variables to match you preferred installation points. Defaults for CVS point to
<code>/usr/local</code>, while the packaged installs point to <code>/usr</code>.
You'll need to match these to the Gaim installation.</li>

<li>Start up Gaim, and with luck you'll be ready to go!</li>
</ol>

