<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" />

<xsl:template match="/">
	<xsl:apply-templates select="rss/channel" />
</xsl:template>


<xsl:template match="channel">
	<h2><xsl:value-of select="item[1]/title" /></h2>
	<p><xsl:value-of select="item[1]/description" /></p>

	<xsl:if test="item[position() &gt; 1]">
		<h2>Old News</h2>
		<ul>
		<xsl:apply-templates select="item[position() &gt; 1]" />
		</ul>
	</xsl:if>
</xsl:template>


<xsl:template match="item">
	<xsl:variable name="url" select="link/text()" />
	<li><a href="{link/text()}"><xsl:value-of select="title" /></a></li>
</xsl:template>


</xsl:stylesheet>
