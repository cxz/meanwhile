
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


<h2>CVS</h2>
<p>The CVS version of gaim-meanwhile is written against the latest release of
Gaim, and the latest release of Meanwhile.</p>

<p>The CVS version of meanwhile is not guaranteed to work with the CVS version
of gaim-meanwhile. In fact, until 0.4.0 is released, it's guaranteed <i>not</i>
to work. However, the new Python bindings are in CVS, and are worth playing
around with if you have the time and a sametime server that doesn't mind. You
don't have to install CVS meanwhile to play with the Python bindings, the
included test scripts will function in the sandbox just fine.</p>

<p>To build from CVS, just check out the appropriate module and
run <code>./autogen.sh &amp;&amp; make all</code></p>

