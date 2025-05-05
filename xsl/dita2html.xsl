<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot" version="2.0" exclude-result-prefixes="xs dita-ot">
	<xsl:import href="plugin:org.dita.html5:xsl/dita2html5Impl.xsl"></xsl:import>

	<xsl:output method="html" encoding="UTF-8" indent="no" omit-xml-declaration="yes"></xsl:output>

	<xsl:param name="commit"></xsl:param>
	<xsl:param name="layout" select="'base'" as="xs:string"></xsl:param>

	<xsl:template match="/">
		<xsl:apply-templates select="*" mode="front-matter"></xsl:apply-templates>
		<xsl:apply-templates select="*" mode="chapterBody"></xsl:apply-templates>
	</xsl:template>

	<xsl:template match="node()" mode="front-matter">
		<xsl:text>---&#xA;</xsl:text>
		<xsl:text># Generated from DITA source&#xA;</xsl:text>
		<xsl:call-template name="yaml-string">
			<xsl:with-param name="key" select="'layout'"></xsl:with-param>
			<xsl:with-param name="value">
				<xsl:apply-templates select="." mode="jekyll-layout"></xsl:apply-templates>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="yaml-string">
			<xsl:with-param name="key" select="'title'"></xsl:with-param>
			<xsl:with-param name="value">
				<xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="text-only"></xsl:apply-templates>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:variable name="shortdescs" as="element()*" select="
				*[contains(@class, ' topic/shortdesc ')] |
				*[contains(@class, ' topic/abstract ')]/*[contains(@class, ' topic/shortdesc ')]"></xsl:variable>
		<xsl:if test="exists($shortdescs)">
			<xsl:call-template name="yaml-string">
				<xsl:with-param name="key" select="'description'"></xsl:with-param>
				<xsl:with-param name="value">
					<xsl:value-of>
						<xsl:for-each select="$shortdescs">
							<xsl:if test="position() ne 1">
								<xsl:text> </xsl:text>
							</xsl:if>
							<xsl:apply-templates select="." mode="text-only"></xsl:apply-templates>
						</xsl:for-each>
					</xsl:value-of>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="metadata" as="element()*" select="//category"></xsl:variable>
		<xsl:if test="exists($metadata)">
			<xsl:call-template name="yaml-string">
				<xsl:with-param name="key" select="'category'"></xsl:with-param>
				<xsl:with-param name="value">
					<xsl:value-of select="string-join($metadata, ', ')"></xsl:value-of>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="keyword" as="element()*" select="//keyword"></xsl:variable>
		<xsl:if test="exists($keyword)">
			<xsl:call-template name="yaml-string">
				<xsl:with-param name="key" select="'keywords'"></xsl:with-param>
				<xsl:with-param name="value">
					<xsl:value-of select="string-join($keyword, ', ')"></xsl:value-of>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="audience" as="element()*" select="//audience"></xsl:variable>
		<xsl:if test="exists($audience)">
			<xsl:call-template name="yaml-string">
				<xsl:with-param name="key" select="'audience'"></xsl:with-param>
				<xsl:with-param name="value">
					<xsl:value-of select="string-join($audience, ', ')"></xsl:value-of>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="yaml-string">
			<xsl:with-param name="key" select="'index'"></xsl:with-param>
			<xsl:with-param name="value" select="concat($PATH2PROJ, 'toc', $OUTEXT)"></xsl:with-param>
		</xsl:call-template>
		<xsl:if test="normalize-space($commit)">
			<xsl:call-template name="yaml-string">
				<xsl:with-param name="key" select="'commit'"></xsl:with-param>
				<xsl:with-param name="value" select="normalize-space($commit)"></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="yaml-string">
			<xsl:with-param name="key" select="'src'"></xsl:with-param>
			<xsl:with-param name="value" select="concat($FILEDIR, '/', $FILENAME)"></xsl:with-param>
		</xsl:call-template>
		<xsl:if test="(/* | /*/*[contains(@class, ' topic/title ')])[tokenize(@outputclass, '\s+') = 'generated']">
			<xsl:call-template name="yaml-boolean">
				<xsl:with-param name="key" select="'generated'"></xsl:with-param>
				<xsl:with-param name="value" select="true()"></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:text>---&#xA;&#xA;</xsl:text>
	</xsl:template>

<xsl:template name="yaml-string">
  <xsl:param name="key" as="xs:string"/>
  <xsl:param name="value" as="xs:string"/>
  <xsl:value-of select="$key"/>
  <xsl:text>: '</xsl:text>
  <xsl:value-of select="replace($value, '''', '''''')"/>
  <xsl:text>'&#xA;</xsl:text>
</xsl:template>



	<xsl:template name="yaml-boolean">
		<xsl:param name="key" as="xs:string"></xsl:param>
		<xsl:param name="value" as="xs:boolean"></xsl:param>
		<xsl:value-of select="$key"></xsl:value-of>
		<xsl:text>: </xsl:text>
		<xsl:value-of select="$value"></xsl:value-of>
		<xsl:text>&#xA;</xsl:text>
	</xsl:template>

	<!-- Base layout adds the <body> element, so skip that (and related ID/attributes/outputclass/aname) here -->
	<xsl:template match="*" mode="chapterBody">
		<!--
    <body>
      <xsl:apply-templates select="." mode="addAttributesToHtmlBodyElement"/>
      <xsl:call-template name="setaname"/>  <!-\- For HTML4 compatibility, if needed -\-> 
    -->
		<xsl:apply-templates select="." mode="addHeaderToHtmlBodyElement"></xsl:apply-templates>

		<!-- Include a user's XSL call here to generate a toc based on what's a child of topic -->
		<xsl:call-template name="gen-user-sidetoc"></xsl:call-template>

		<xsl:apply-templates select="." mode="addContentToHtmlBodyElement"></xsl:apply-templates>
		<xsl:apply-templates select="." mode="addFooterToHtmlBodyElement"></xsl:apply-templates>
		<!--
    </body>
    -->
		<xsl:text>&#xA;</xsl:text>
	</xsl:template>

	<xsl:template match="node()" mode="jekyll-layout" as="xs:string">
		<xsl:value-of select="$layout"></xsl:value-of>
	</xsl:template>

	<xsl:attribute-set name="main">
		<xsl:attribute name="class">col-lg-9</xsl:attribute>
		<xsl:attribute name="role">main</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="toc">
		<xsl:attribute name="class">col-lg-3 toc</xsl:attribute>
		<xsl:attribute name="role">navigation</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="nav.ul">
		<xsl:attribute name="class">nav nav-list</xsl:attribute>
	</xsl:attribute-set>

	<xsl:template match="*[contains(@class, ' topic/dt ')][empty(@id)]" mode="commonattributes">
		<xsl:param name="default-output-class"></xsl:param>
		<xsl:attribute name="id" select="replace(lower-case(normalize-space()), ' ', '-')"></xsl:attribute>
		<xsl:next-match>
			<xsl:with-param name="default-output-class" select="$default-output-class"></xsl:with-param>
		</xsl:next-match>
	</xsl:template>

	<!-- Retrofit commonattributes to use modes to allow extension -->

	<xsl:template name="commonattributes">
		<xsl:param name="default-output-class"></xsl:param>
		<xsl:apply-templates select="." mode="commonattributes">
			<xsl:with-param name="default-output-class" select="$default-output-class"></xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="@* | node()" mode="commonattributes">
		<xsl:param name="default-output-class"></xsl:param>
		<xsl:apply-templates select="@xml:lang"></xsl:apply-templates>
		<xsl:apply-templates select="@dir"></xsl:apply-templates>
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/@outputclass" mode="add-ditaval-style"></xsl:apply-templates>
		<xsl:apply-templates select="." mode="set-output-class">
			<xsl:with-param name="default" select="$default-output-class"></xsl:with-param>
		</xsl:apply-templates>
		<xsl:if test="exists($passthrough-attrs)">
			<xsl:for-each select="@*">
				<xsl:if test="
						$passthrough-attrs[@att = name(current()) and (empty(@val) or (some $v in tokenize(current(), '\s+')
							satisfies $v = @val))]">
					<xsl:attribute name="data-{name()}" select="."></xsl:attribute>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
