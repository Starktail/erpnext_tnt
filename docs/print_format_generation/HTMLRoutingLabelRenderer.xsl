<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="HTMLItalianDomesticRoutingLabelRenderer.xsl" />
<xsl:import href="HTMLFrenchDomesticRoutingLabelRenderer.xsl" />
<xsl:import href="HTMLRestOfWorldRoutingLabelRenderer.xsl" />

<xsl:preserve-space elements="*"/>
<xsl:output method="html" omit-xml-declaration="yes" doctype-public="-//W3C//DTD XHTML 1.0 Transistional//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    indent="yes"
    />   
    
<xsl:param name="twoDbarcode_url" />
<xsl:param name="barcode_url" />
<xsl:param name="int2of5barcode_url" />
<xsl:param name="code128Bbarcode_url" />
<xsl:param name="images_dir" />
<xsl:param name="css_dir" />

<xsl:template match="/">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" type="text/css" href="label-rendering-style.css" />
<link rel="stylesheet" type="text/css" href="label-rendering-style-fr.css" />
<link rel="stylesheet" type="text/css" href="label-rendering-style-it.css" />
<link rel="stylesheet" type="text/css" href="label-rendering-exception-style.css" />
<title>Express Label Example</title>
</head>
<body>

<xsl:choose>
    <xsl:when test="(//consignmentLabelData/sender/country = 'IT') and (//consignmentLabelData/delivery/country = 'IT')">
        <xsl:for-each select="//consignment/pieceLabelData">
            <xsl:call-template name="ItalianDomesticHtml" />
        </xsl:for-each>
    </xsl:when>
	<xsl:when test="(//consignmentLabelData/sender/country = 'FR') and (//consignmentLabelData/delivery/country = 'FR')">
		<xsl:for-each select="//consignment/pieceLabelData">
			<xsl:call-template name="FrenchDomesticHtml" />
		</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
		<xsl:for-each select="//consignment/pieceLabelData">
			<xsl:call-template name="RestOfWorldHtml" />
		</xsl:for-each>
	</xsl:otherwise>
</xsl:choose>

    
<!--Brokenrules-->
    
    <xsl:variable name="numberBrokenRules" select="count(//brokenRules)" />
    <xsl:if test="$numberBrokenRules >0">   
      <!--Logo -->
      <span id="errorLogo">
          <img src='{$images_dir}/logo.jpg' alt='logo' id="tntLogo" />
      </span>
      <span id="errorHeader">ExpressLabel Error(s)</span>   
    
    <div id="errorBox" style="clear:left">
        <xsl:for-each select="//brokenRules">   
            <div id="errorConNumber">
                <span id="errorConNumberHeader">KEY:</span>
                <span id="errorConNumberDetail">
                    <xsl:value-of select="@key" />
                </span>
            </div>
            <div id="errorCode">
                <span id="errorCodeHeader">ERROR CODE:</span>
                <span id="errorCodeDetail">
                    <xsl:value-of select="errorCode" />
                </span>
            </div>
            <div id="errorDescription">
                <span id="errorDescriptionDetail">
                    <xsl:value-of select="errorDescription" />
                </span>
            </div> 
        </xsl:for-each> 
    </div>
    </xsl:if>
</body>
</html>
</xsl:template>

</xsl:stylesheet>