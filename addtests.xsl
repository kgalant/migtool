<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sf="antlib:com.salesforce">  <!-- exclude-result-prefixes="sf "   xmlns:sf="http://soap.sforce.com/2006/04/metadata"-->
	<xsl:output omit-xml-declaration="yes" indent="yes"/>


	<!-- 	<xsl:output method="spring:beans" doctype-system="http://www.springframework.org/dtd/spring-beans.dtd" doctype-public="-//SPRING//DTD BEAN//EN" indent="yes" /> -->

	<xsl:param name="testclasses"/>
	<xsl:param name="bldtarget"/>

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:output indent="yes"/>

    <xsl:template match="target/sf:deploy">
    	<xsl:if test="../@name=$bldtarget">
	    	<xsl:copy>
	    		<xsl:if test="$testclasses">
	    			<xsl:attribute name="testLevel">RunSpecifiedTests</xsl:attribute>
	   			</xsl:if>
				<xsl:apply-templates select="node()|@*"/>
				<xsl:for-each select="tokenize($testclasses,',')">
	                <RunTest><xsl:value-of select="normalize-space(.)"/></RunTest>
	            </xsl:for-each>
			</xsl:copy>
		</xsl:if>
    </xsl:template>

    <xsl:template match="target[@name='deployZip']">
    	<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
    </xsl:template>
</xsl:stylesheet>

