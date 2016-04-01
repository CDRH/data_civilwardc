<xsl:stylesheet version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
  <xsl:output indent="yes"/>
  <xsl:param name="date"/>
  <xsl:include href="../../../scripts/xslt/cdrh_to_solr/lib/common.xsl"/>
  <xsl:variable name="date_field">
    <xsl:choose>
      <xsl:when test="/TEI/teiHeader[1]/fileDesc[1]/sourceDesc[1]/bibl[1]/date[1]/@when">
        <xsl:value-of select="/TEI/teiHeader[1]/fileDesc[1]/sourceDesc[1]/bibl[1]/date[1]/@when"/>
      </xsl:when>
      <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@when">
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@when"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>
  <xsl:template match="/">
    <add>
      <doc>
        <field name="id">
          <!-- Get the filename -->
          <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
          <!-- Split the filename using '\.' -->
          <xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
          <!-- Remove the file extension -->
          <xsl:value-of select="$filenamepart"/>
        </field>
        <field name="type">
          <xsl:text>texts</xsl:text>
        </field>
        <field name="subtype">
          <!-- Get the filename -->
          <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()-1]"/>
          <xsl:value-of select="$filename"/>
        </field>
        <xsl:variable name="title">
          <xsl:choose>
            <!-- when letter -->
            <xsl:when test="//biblStruct[@xml:id='letter']">
              <xsl:choose>
                <xsl:when test="string(/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[@xml:id='letter']/analytic/title[1])">
                  <xsl:choose>
                    <!-- When there is a title main -->
                    <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[@xml:id='letter']/analytic/title[@type='main']">
                      <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[@xml:id='letter']/analytic/title[@type='main']">
                        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[@xml:id='letter']/analytic/title[@type='main']"/>
                      </xsl:if>
                      <xsl:text/>
                      <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[@xml:id='letter']/analytic/title[@type='sub']">
                        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[@xml:id='letter']/analytic/title[@type='sub']"/>
                      </xsl:if>
                    </xsl:when>
                    <!-- if there is not a title main, take the first title -->
                    <xsl:otherwise>
                      <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[@xml:id='letter']/analytic/title[1]"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  <!--/TEI/teiHeader[1]/fileDesc[1]/sourceDesc[1]/biblStruct[@xml:id='letter']/monogr[1]/imprint[1]/date[1]-->
                  <!-- if there is a date_field variable (set above), and it is not empty, add it at the end -->
                  <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint[1]/date[1] != ''">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="normalize-space(/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[@xml:id='letter']/monogr/imprint[1]/date[1])"/>
                  </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>No Title</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!-- other types -->
            <xsl:when test="//title[@type='main']">
              <xsl:value-of select="//title[@type='main' and not(@level='j')][1]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="//title">
                <xsl:if test="not(preceding::*[name() = 'title'])">
                  <xsl:value-of select="."/>
                </xsl:if>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <field name="title">
          <xsl:value-of select="$title"/>
        </field>
        <field name="titleOther">
          <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level='j'][1]">
            <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level='j']"/>
          </xsl:if>
        </field>
        <field name="person">
          <xsl:if test="/TEI/teiHeader/profileDesc/particDesc/person[@role='petitioner']/persName[1]">
            <xsl:value-of select="/TEI/teiHeader/profileDesc/particDesc/person[@role='petitioner']/persName"/>
          </xsl:if>
        </field>
        <!-- "date_field" set above -->
        <field name="date">
          <xsl:value-of select="$date_field"/>
        </field>
        <field name="dateNormalized">
          <xsl:call-template name="extractDate">
            <xsl:with-param name="date" select="$date_field"/>
          </xsl:call-template>
        </field>
        <xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@scheme='#medsurg']/term">
          <field name="keyword">
            <xsl:value-of select="."/>
          </field>
        </xsl:for-each>
        <xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/classCode/term">
          <field name="keyword">
            <xsl:value-of select="."/>
          </field>
        </xsl:for-each>
        <field name="text">
          <xsl:value-of select="//text"/>
        </field>
      </doc>
    </add>
  </xsl:template>
</xsl:stylesheet>
