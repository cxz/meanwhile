<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" />

<xsl:template match="/">
	<xsl:call-template name="gen-index" />
	<hr />
	<xsl:apply-templates select="faq/group" />
</xsl:template>


<xsl:template name="gen-index">
	<xsl:variable name="qid">
		<xsl:choose>
		<xsl:when test="@id"><xsl:value-of select="@id" />
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="position()" />
		</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<ul>
	<xsl:for-each select="faq/group">
		<xsl:if test="question">
			<li><b><xsl:value-of select="title" /></b>
			<a name="{$qid}">
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
	<xsl:variable name="qid">
		<xsl:choose>
		<xsl:when test="@id"><xsl:value-of select="@id" />
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="position()" />
		</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<li><a href="#{$qid}"><xsl:value-of select="title" /></a></li>
</xsl:template>


<xsl:template match="group">
	<h2><xsl:value-of select="title" /></h2>
	<xsl:apply-templates select="question" />
</xsl:template>


<xsl:template match="question">
	<xsl:variable name="qid">
		<xsl:choose>
		<xsl:when test="@id"><xsl:value-of select="@id" />
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="position()" />
		</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<h3 id="{$qid}"><xsl:value-of select="title" /></h3>
	<div class="answer">
	<xsl:apply-templates select="answer" />
	</div>

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
