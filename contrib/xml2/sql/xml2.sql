CREATE EXTENSION xml2;

select query_to_xml('select 1 as x',true,false,'');

select xslt_process( query_to_xml('select x from generate_series(1,5) as
x',true,false,'')::text,
$$<xsl:stylesheet version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" />
<xsl:template match="*">
  <xsl:copy>
     <xsl:copy-of select="@*" />
     <xsl:apply-templates />
  </xsl:copy>
</xsl:template>
<xsl:template match="comment()|processing-instruction()">
  <xsl:copy />
</xsl:template>
</xsl:stylesheet>
$$::text);

CREATE TABLE xpath_test (id integer NOT NULL, t xml);
INSERT INTO xpath_test VALUES (1, '<doc><int>1</int></doc>');
SELECT * FROM xpath_table('id', 't', 'xpath_test', '/doc/int', 'true')
as t(id int4);
SELECT * FROM xpath_table('id', 't', 'xpath_test', '/doc/int', 'true')
as t(id int4, doc int4);

DROP TABLE xpath_test;
CREATE TABLE xpath_test (id integer NOT NULL, t text);
INSERT INTO xpath_test VALUES (1, '<doc><int>1</int></doc>');
SELECT * FROM xpath_table('id', 't', 'xpath_test', '/doc/int', 'true')
as t(id int4);
SELECT * FROM xpath_table('id', 't', 'xpath_test', '/doc/int', 'true')
as t(id int4, doc int4);

create table articles (article_id integer, article_xml xml, date_entered date);
insert into articles (article_id, article_xml, date_entered)
values (2, '<article><author>test</author><pages>37</pages></article>', now());
SELECT * FROM
xpath_table('article_id',
            'article_xml',
            'articles',
            '/article/author|/article/pages|/article/title',
            'date_entered > ''2003-01-01'' ')
AS t(article_id integer, author text, page_count integer, title text);

-- this used to fail when invoked a second time
select xslt_process('<aaa/>',$$<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="@*|node()">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>$$)::xml;

select xslt_process('<aaa/>',$$<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="@*|node()">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>$$)::xml;

create table t1 (id integer, xml_data xml);
insert into t1 (id, xml_data)
values
(1, '<attributes><attribute name="attr_1">Some
Value</attribute></attributes>');

create index idx_xpath on t1 ( xpath_string
('/attributes/attribute[@name="attr_1"]/text()', xml_data::text));

SELECT xslt_process('<employee><name>cim</name><age>30</age><pay>400</pay></employee>'::text, $$<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:param name="n1"/>
  <xsl:param name="n2"/>
  <xsl:param name="n3"/>
  <xsl:param name="n4"/>
  <xsl:param name="n5" select="'me'"/>
  <xsl:template match="*">
    <xsl:element name="samples">
      <xsl:element name="sample">
        <xsl:value-of select="$n1"/>
      </xsl:element>
      <xsl:element name="sample">
        <xsl:value-of select="$n2"/>
      </xsl:element>
      <xsl:element name="sample">
        <xsl:value-of select="$n3"/>
      </xsl:element>
      <xsl:element name="sample">
        <xsl:value-of select="$n4"/>
      </xsl:element>
      <xsl:element name="sample">
        <xsl:value-of select="$n5"/>
      </xsl:element>
      <xsl:element name="sample">
        <xsl:value-of select="$n6"/>
      </xsl:element>
      <xsl:element name="sample">
        <xsl:value-of select="$n7"/>
      </xsl:element>
      <xsl:element name="sample">
        <xsl:value-of select="$n8"/>
      </xsl:element>
      <xsl:element name="sample">
        <xsl:value-of select="$n9"/>
      </xsl:element>
      <xsl:element name="sample">
        <xsl:value-of select="$n10"/>
      </xsl:element>
      <xsl:element name="sample">
        <xsl:value-of select="$n11"/>
      </xsl:element>
      <xsl:element name="sample">
        <xsl:value-of select="$n12"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>$$::text, 'n1="v1",n2="v2",n3="v3",n4="v4",n5="v5",n6="v6",n7="v7",n8="v8",n9="v9",n10="v10",n11="v11",n12="v12"'::text);

-- xpath_nodeset()
SELECT xpath_nodeset(article_xml::text, '/article/author|/article/pages')
  FROM articles;
SELECT xpath_nodeset(article_xml::text, '/article/author|/article/pages',
                     'item_without_toptag')
  FROM articles;
SELECT xpath_nodeset(article_xml::text, '/article/author|/article/pages',
                     'result', 'item')
  FROM articles;

-- xpath_list()
SELECT xpath_list(article_xml::text, '/article/author|/article/pages')
  FROM articles;
SELECT xpath_list(article_xml::text, '/article/author|/article/pages', '|')
  FROM articles;

-- possible security exploit
SELECT xslt_process('<xml><foo>Hello from XML</foo></xml>',
$$<xsl:stylesheet version="1.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:sax="http://icl.com/saxon"
      extension-element-prefixes="sax">

  <xsl:template match="//foo">
    <sax:output href="0wn3d.txt" method="text">
      <xsl:value-of select="'0wn3d via xml2 extension and libxslt'"/>
      <xsl:apply-templates/>
    </sax:output>
  </xsl:template>
</xsl:stylesheet>$$);
