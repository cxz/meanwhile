<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" />

<xsl:template match="/">
	<xsl:call-template name="gen-index" />
	<hr />
	<xsl:apply-templates select="faq/group/question" />
</xsl:template>


<xsl:template name="gen-index">
	<ul>
	<xsl:for-each select="faq/group">
		<xsl:if test="question">
			<li><b><xsl:value-of select="title" /></b>
			<a name="{@id}">
			<xsl:text disable-output-escaping="yes">
			<![CDATA[&nbsp;]]></xsl:text></a>
			<ul>
			<xsl:for-each select="question">
				<xsl:call-template name="gen-question" />
			</xsl:for-each>
			</ul>
			</li>
		</xsl:if>
	</xsl:for-each>
	</ul>
</xsl:template>


<xsl:template name="gen-question">
	<li><a href="#{@id}"><xsl:value-of select="title" /></a></li>
</xsl:template>


<xsl:template match="question">
	<table class="question">
	<tr><td class="q-title">
	<a name="{@id}" href="#{@id}"><xsl:value-of select="title" /></a>
	</td><td class="q-back">
	<a href="#{../@id}">back</a>
	</td></tr>

	<tr><td class="q-answer" colspan="2">
	<xsl:apply-templates select="answer" />
	</td></tr>
	</table>
</xsl:template>


<xsl:template match="answer">
	<xsl:choose>
	<xsl:when test="p">
		<xsl:copy-of select="p" />
	</xsl:when>
	<xsl:otherwise>
		<p><xsl:value-of select="text()" /></p>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>


</xsl:stylesheet>
