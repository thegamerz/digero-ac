<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
	
  <xsl:template match="/">
    <html>
      <head>
        <title><xsl:value-of select="log/@date"/></title>
        <style>
					<![CDATA[
          body {
					]]>
					<xsl:if test="log/@bkgd">
							background-image: url('<xsl:value-of select="log/@bkgd"/>');
					</xsl:if>
					<![CDATA[
							background-color: #342614;
              font-family: "Palatino Linotype", "Times New Roman", Times, serif;
              font-size: 0.8em;
              color: white;
              line-height: 1.5em;
          }

          h1 {
              text-align: center;
          }

          h3 {
              font-size: 1.2em;
              border-bottom: 1px solid #AAAAAA;
              width: 100%;
              text-indent: 20px;
							margin-top: 30px;
              margin-bottom: 4px;
              line-height: 0.9em;
              padding-bottom: 0px;
          }
					
          span.server {
              font-size: 0.65em;
							line-height: 0.65em;
              font-weight: normal;
              font-family: Arial;
              color: #D2FAC8;
          }

          .c0  {color:#7FFF7E;}
          .c1  {color:#7FFF7E;}
          .c2  {color:#FFFFFF;}
          .c3  {color:#FFFF3E;}
          .c4  {color:#D2D263;}
          .c5  {color:#FF7EFF;}
          .c6  {color:#FF3E3E;}
          .c7  {color:#3EBEFF;}
          .c8  {color:#FF9595;}
          .c9  {color:#FF9595;}
          .c10 {color:#FFFF3E;}
          .c11 {color:#D2D263;}
          .c12 {color:#D2D2C7;}
          .c13 {color:#3EDCDC;}
          .c14 {color:#B4DCEF;}
          .c15 {color:#FF3E3E;}
          .c16 {color:#7FFF7E;}
          .c17 {color:#3EBEFF;}
          .c18 {color:#ED921E;}
          .c19 {color:#FFFF3E;}
          .c20 {color:#7FFF7E;}
          .c21 {color:#FF3E3E;}
          .c22 {color:#F47571;}
          .c23 {color:#7FFF7E;}
          .c24 {color:#7FFF7E;}
          .c25 {color:#7FFF7E;}
          .c26 {color:#FF0000;}
          .c27 {color:#B4DCEF;}
          .c28 {color:#B4DCEF;}
          .c29 {color:#B4DCEF;}
          .c30 {color:#B4DCEF;}
          .c31 {color:#FFFF3E;}
          .c32 {color:#D2D2C7;}
          .timestamp {color:#9999FF;}
          .comment {color:#FFDDBB;}
          .info {color:#FFDDBB; font:Arial;}
          .highlight {color:white; font-weight:bold;}
          a {color:#FFDDBB; white-space: inherit;}
          a:hover {color:#BBDDFF; white-space: inherit;}
          a:active a:visited {color:#BBFFDD; white-space: inherit;}

          #infoHeader {
              text-align: right;
          }
          ]]>
        </style>
      </head>
			<body>
				<div id="infoHeader" class="info">
					Asheron's Call log file created by <span class="highlight"><xsl:value-of select="log/@generator"/></span><br/>
					Visit <a class="info" href="http://decal.acasylum.com">http://decal.acasylum.com</a> for updates.
				</div>
				<h1><xsl:value-of select="log/@date"/></h1>
				<xsl:apply-templates/>
			</body>
		</html>
  </xsl:template>

  <xsl:template match="session[@character]">
    <h3>
      <xsl:value-of select="@character"/>&#160;
      <xsl:if test="@server">
        <span class="server"><xsl:value-of select="@server"/></span>
      </xsl:if>
    </h3>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="m[@c]">
    <xsl:if test="@t">
      <span class="timestamp">[<xsl:value-of select="@t"/>] </span>
    </xsl:if>
    <xsl:element name="span">
      <xsl:attribute name="class">c<xsl:value-of select="@c"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
    <br/>
  </xsl:template>

  <xsl:template match="info">
    <span class="info"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="continueFrom[@href]">
    <xsl:element name="a">
      <xsl:attribute name="class">info</xsl:attribute>
      <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
			<xsl:choose>
				<xsl:when test="@text">
					&#171; Log continued from <xsl:value-of select="@text"/>
				</xsl:when>
				<xsl:otherwise>
					&#171; Log continued from <xsl:value-of select="@href"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
    <br/>
  </xsl:template>

  <xsl:template match="continueTo[@href]">
    <xsl:element name="a">
      <xsl:attribute name="class">info</xsl:attribute>
      <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
			<xsl:choose>
				<xsl:when test="@text">
					Log continued on <xsl:value-of select="@text"/> &#187;
				</xsl:when>
				<xsl:otherwise>
					Log continued on <xsl:value-of select="@href"/> &#187;
				</xsl:otherwise>
			</xsl:choose>
    </xsl:element>
    <br/>
  </xsl:template>

  <xsl:template match="a[@href]">
    <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
      <xsl:if test="@style">
        <xsl:attribute name="style"><xsl:value-of select="@style"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@class">
        <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="br">
    <br/>
  </xsl:template>

  <xsl:template match="hr">
    <hr/>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
  
</xsl:stylesheet>
