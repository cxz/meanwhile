<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output indent="yes" method="xml" omit-xml-declaration="no" />


<xsl:template match="/">
  <xsl:apply-templates select="donors" />
</xsl:template>


<xsl:template match="donors">
<donors>
  <xsl:for-each select="a[not(img)]">
    <xsl:call-template name="donor" />
  </xsl:for-each>
</donors>
</xsl:template>


<xsl:template name="donor">
  <donor>
    <name><xsl:value-of select="text()" /></name>
    <href><xsl:value-of select="@href" /></href>
    <xsl:call-template name="i" />
    <xsl:call-template name="c" />
  </donor>
</xsl:template>


<xsl:template name="i">
  <xsl:param name="o" select="following-sibling::*[1]" />

  <xsl:if test="$o and not(name($o)='br')">
    <role><xsl:value-of select="$o/img/@alt" /></role>
    <xsl:call-template name="i">
      <xsl:with-param name="o" select="$o/following-sibling::*[1]" />
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template name="c">
  <xsl:variable name="o" select="following-sibling::span[1]" />
  <xsl:variable name="b" select="following-sibling::br[1]" />

  <xsl:if test="$o">
    <xsl:variable name="r" select="$o/preceding-sibling::br[1]" />
    <!-- <xsl:if test="$b is $r"> -->
      <comment><xsl:value-of select="$o/text()" /></comment>
    <!-- </xsl:if> -->
  </xsl:if>
</xsl:template>


</xsl:stylesheet>

