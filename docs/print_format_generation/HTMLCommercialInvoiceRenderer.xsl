<?xml version="1.0" encoding="iso-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
  <xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

  <!-- Version 3.0.1  03-01-2018 12:21 Draft version for Infosys -->
  <!-- Version 3.1.0  07-03-2018 09:51 Switch to DIV technology. -->
  <!-- Version 3.1.1  08-03-2018 10:25 Removal of term country. -->
  <!-- Version 3.1.2  09-03-2018 14:46 Substituting <hr> with <div>s -->
  <!-- Version 3.1.3  11-03-2018 17:18 Adjusting for better cross browser compatibility -->
  <!-- Version 3.1.4  12-03-2018 15:08 Fitting Country/Location of Origin -->
  <!-- Version 3.1.5  24-05-2018 12:39 Simplifying styles and fixing browser compatibility -->
  <!-- Version 3.1.6  19-12-2018 16:10 Correcting UK request issue -->
  <!-- Version 3.1.7  14-01-2019 15:25 Correcting Delivery address issue -->

  <xsl:variable name="linesHeader">
    <div class="row hr"/>
    <div class="row invoiceHeaderLineheight">
      <div class="invoiceLinecolumn1 paddedleft">
        <font class="newsmallheader">Quantity</font>
      </div>
      <div class="invoiceLinehead2 paddedleft">
        <font class="newsmallheader">Units</font>
      </div>
      <div class="invoiceLinehead3 paddedleft">
        <font class="newsmallheader">Total Weight</font>
      </div>
      <div class="invoiceLinehead4 paddedleft">
        <font class="newsmallheader">Description of Goods</font>
      </div>
      <div class="invoiceLinehead5 paddedleft">
        <font class="newsmallheader">HS Tariff Code</font>
      </div>
      <div class="invoiceLinehead6 paddedleft">
        <font class="newsmallheader">Location of Origin</font>
      </div>
      <div class="invoiceLinehead7 paddedleft textright">
        <font class="newsmallheader">Unit Value</font>
      </div>
      <div class="invoiceLinecolumn8 paddedleft textright">
        <font class="newdata">
          <font class="newsmallheader">Total Value</font>
        </font>
      </div>
    </div>
    <div class="row hr"/>
  </xsl:variable>

  <xsl:variable name="MaxLinesFirstPage" select="25"/>
  <xsl:variable name="MaxLinesNextPage" select="39"/>

  <xsl:template match="/">
    <html>
      <head>
        <title>TNT Commercial Invoice</title>
        <script type="text/javascript">
          <![CDATA[         
           var firstPagePrinted = false;
         
           function includePageBreak() {
             if (firstPagePrinted) {
               document.writeln('<div class="pagebreak">');
               document.writeln('<font size="1" color="#FFFFFF">.</font>');
                 document.writeln('</div>');
             } else {
               firstPagePrinted = true;
             }
           }
         ]]>
        </script>
        <style>
          <![CDATA[
          .pageFrame {
              width: 750px;
              padding: 1px;
              height: 1020px;
          }

          .row {
              width: 100%;
              float: left;
          }

          .row99 {
              width: 98.5%;
              float: left;
          }
          
          .halfrow {
              width: calc(50% - 1px);
              float: left;
          }

          .rowbordered {
              width: calc(100% - 2px);
              float: left;
          }

          .page1 {}

          .column {
              width: 49.7%;
          }

          .totalsheight {
              height: 253px;
          }

          .cellheight {
              height: 18px;
          }

          .celldoubleheight {
              height: 36px;
          }
          
          .cell-filler {
              width: 1px;
              float: left;
          }
          
          .cell {
              width: 180px;
              float: left;
              padding-left: 4px;
              padding-right: 2px;
          }

          .celldoublewidth {
              width: 366px;
              float: left;
              padding-left: 4px;
              padding-right: 2px;
          }

          .padded2 {
              padding: 2px;
          }

          .paddedleft {
              padding-left: 2px;
          }

          .bordered {
              border: 1px solid #000000;
          }

          .borderedrow {
              border: 1px solid #000000;
          }

          .borderedhalfrow {
              border-left: 1px solid #000000;
              border-right: 1px solid #000000;
          }

          .borderedhalfrow ~ .borderedhalfrow {
              border-top: 1px solid #000000;
          }

          .borderedrow + .borderedrow {
              border-top: 0px solid #000000;
          }

          .borderedcolumn {
              border-right: 1px solid #000000;
              height: 100%;
          }

          .borderedcolumn:last-child {
              border-right: 0px solid #000000;
          }
          
          .verticalcenter {
              margin-top: 8px;
          }

          .centered {
              text-align: center;
          }

          .textright {
              text-align: right;
          }

          .Line32 {
              line-height: 32px;
          }

          .Line80fixed13 {
              height: 13px;
              line-height: 80%;
          }

          .Line80fixed17 {
              height: 17px;
              line-height: 80%;
          }

          .declarationheight {
              margin-left: 2px;
              height: 84px;
          }

          .subtotalborder {
              border-bottom: 3px double #000000;
              border-top: 1px solid #000000;
          }

          .subtotalheight {
              height: 23px;
          }

          .contcolumn1 {
              width: 83%;
              float: left;
          }

          .contcolumn2 {
              width: 13.5%;
              float: left;
          }

          .pagecolumn1 {
              width: 86%;
              float: left;
              line-height: 15px;
              vertical-align: bottom;
          }

          .pagecolumn2 {
              width: 9%;
              float: left;
              line-height: 15px;
              vertical-align: bottom;
          }

          .addressLeft {
              float: left;
          }

          .addressRight {
              float: right;
          }
          
          .addressheight {
              height: 132px;
          }

          .contactheight {
              height: 63px;
          }

          .addressHeader {
              padding-left: 2px;
              padding-bottom: 2px;
              height: 16px;
          }

          .addressContentline {
              padding-left: 2px;
              height: 14px;
          }

          .contactcolumn1 {
              width: 26%;
              float: left;
          }

          .contactcolumn2 {
              width: 70%;
              float: left;
          }

          .fullheaderheight {
              height: 217px;
              overflow: hidden;              
          }

          .titleheight {
              height: 30px;
          }

          .headerheight {
              overflow: hidden;
              height: 164px;
          }

          .headerline {
              width: 99%;
              float: left;
              height: 23px;
              padding-left: 2px;
          }

          .headercolumn {
              width: 49%;
              float: left;
          }

          .invoiceFrameheight {
              height: 567px;
          }
          
          .page1 + .invoiceFrameheight {
              height: 378px;
          }

          .invoiceHeaderLineheight {
              height: 18px;
          }

          .invoiceLineheight {
              height: 12px;
              line-height: 70%;
          }

          .invoiceLinecolumn1 {
              width: 6%;
              float: left;
          }

          .invoiceLinecolumn2 {
              width: 3.5%;
              float: left;
          }

          .invoiceLinecolumn3, .invoiceLinehead5, .invoiceLinecolumn5 {
              width: 11.6%;
              float: left;
              overflow: hidden;
          }

          .invoiceLinecolumn4 {
              width: 21.8%;
              float: left;
          }

          .invoiceLinehead2 {
              width: 4.8%;
              float: left;
              padding-left: 2px;
          }

          .invoiceLinehead3 {
              width: 9.5%;
              float: left;
              overflow: hidden;
          }

          .invoiceLinehead4 {
              width: 18.5%;
              float: left;
          }

          .invoiceLinehead6 {
              width: 20.4%;
              float: left;
          }

          .invoiceLinehead7 {
              width: 10.2%;
              float: left;
          }

          .invoiceLinecolumn6, .invoiceLinecolumn8 {
              width: 13.6%;
              float: left;
          }

          .invoiceLinecolumn7 {
              width: 12.9%;
              float: left;
          }

          .hr {
              height: 4px;
              border-top: 3px solid #C0C0C0;
          }

          .bottomfiller {
              height: 230px;
          }

          .separatorheight {
              height: 4px;
          }

          div.pagebreak {
              page-break-before: always;
          }

          font {
              color: black;
          }

          font.newtitle {
              font-weight: bold;
              font-family: arial, "sans-serif";
              font-size: 12pt;
              text-decoration: underline;
          }

          font.newheader {
              font-weight: bold;
              font-family: arial, helvetica "sans-serif";
              font-size: 9pt;
              text-decoration: underline;
          }

          font.borderedheader {
              font-weight: bold;
              font-family: arial, helvetica "sans-serif";
              font-size: 9pt;
          }

          font.newdata {
              font-family: arial, "sans-serif";
              font-size: 8pt;
          }

          font.newsmallheader {
              font-weight: bold;
              font-family: arial, "sans-serif";
              font-size: 8pt;
          }

          font.newsmalldata {
              font-family: arial, "sans-serif";
              font-size: 4pt;
          }

          font.newitalicdata {
              font-family: arial, "sans-serif";
              font-size: 8pt;
              font-style: italic;
          }

          font.carrierTerms {
              font-family: arial, helvetica "sans-serif";
              font-size: 5pt;
          }
            ]]>
        </style>
      </head>
      <body>
        <xsl:for-each select ="CONSIGNMENTBATCH/CONSIGNMENT">
          <!-- Prepared for future enhancements (using a copies attribute) -->
          <xsl:choose>
            <xsl:when test="CONSIGNMENT/@copies">
              <xsl:apply-templates select="." mode="copy">
                <xsl:with-param name="Copies" select="CONSIGNMENT/@copies" />
              </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="copy">
                <xsl:with-param name="Copies" select="'1'" />
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>

  <!-- Main template for each consignment -->
  <xsl:template match="CONSIGNMENT" mode="copy">
    <xsl:param name="Copies" />
    <xsl:param name="Copy" select="1" />
    <xsl:param name="PageNo" select="1"/>
    <xsl:param name="SubTotal" select="0"/>

    <!-- Variables to hold calculate consignment level information for each page. 
    Logic has been made to be able to print an invoice even ARTICLES has not been used. 
    As ARTICLE information is not validated we take into consideration that there might be variances -->
    <xsl:variable name="PackagesNoArticles" select="count(PACKAGE[not(ARTICLE)])"/>
    <xsl:variable name="PackagesNoArticlesTotalItems" select="sum(PACKAGE[not(ARTICLE)]/ITEMS)"/>
    <xsl:variable name="ArticleLines" select="count(PACKAGE/ARTICLE)"/>
    <xsl:variable name="ArticleTotal" select="sum(PACKAGE/ARTICLE/INVOICEVALUE)"/>

    <!-- Below section contain vital logic to calculate invoice lines if no articles exists for a package -->
    <xsl:variable name="SinglePackageValue">
      <xsl:choose>
        <!-- If no value is provided at all use 0 as value -->
        <xsl:when test="not(GOODSVALUE/text()) or not(number(GOODSVALUE) = number(GOODSVALUE))">
          <xsl:value-of select="0"/>
        </xsl:when>
        <!-- If no packages without articles exists it's simple -->
        <xsl:when test="$PackagesNoArticles = 0">
          <xsl:value-of select="0"/>
        </xsl:when>
        <!-- If the total value is higher than the sum of the article values we divide the rest amount between the packages with no articles -->
        <xsl:when test="GOODSVALUE > $ArticleTotal">
          <xsl:value-of select="(GOODSVALUE - $ArticleTotal) div ($PackagesNoArticlesTotalItems)"/>
        </xsl:when>
        <!-- If the total value is lower than the sum of the article values (must be a data error) we divide total value between all packages to get average and use that -->
        <xsl:otherwise>
          <xsl:value-of select="GOODSVALUE div TOTALITEMS"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Variables to track current position of article lines -->
    <xsl:variable name="PositionStart">
      <xsl:choose>
        <xsl:when test="$PageNo = 1">
          <xsl:value-of select="0"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$MaxLinesFirstPage + ($PageNo - 2) * $MaxLinesNextPage"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="PositionEnd">
      <xsl:choose>
        <xsl:when test="$PageNo = 1">
          <xsl:value-of select="$MaxLinesFirstPage"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$MaxLinesFirstPage + ($PageNo - 1) * $MaxLinesNextPage"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name ="TotalPages">
      <xsl:choose>
        <xsl:when test="$PackagesNoArticles + $ArticleLines &lt;= $MaxLinesFirstPage">
          <xsl:value-of select ="1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ceiling(($PackagesNoArticles + $ArticleLines - $MaxLinesFirstPage) div $MaxLinesNextPage) + 1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- A subtotal per page is calculated -->
    <xsl:variable name="CalculateSubTotal">
      <xsl:choose>
        <xsl:when test="$ArticleLines &lt;= $PositionStart">
          <xsl:value-of select="($SinglePackageValue * sum((PACKAGE[not(ARTICLE)]/ITEMS)[position() > ($PositionStart - $ArticleLines) and position() &lt;= $PositionEnd - $ArticleLines]))"/>
        </xsl:when>
        <xsl:when test="$ArticleLines &lt;= $PositionEnd and $PackagesNoArticles = 0">
          <xsl:value-of select="sum((PACKAGE/ARTICLE/INVOICEVALUE)[position() > $PositionStart and position() &lt;= $PositionEnd])"/>
        </xsl:when>
        <xsl:when test="$ArticleLines &lt;= $PositionEnd and $PackagesNoArticles > 0">
          <xsl:value-of select="sum((PACKAGE/ARTICLE/INVOICEVALUE)[position() > $PositionStart and position() &lt;= $PositionEnd]) + ($SinglePackageValue * sum((PACKAGE[not(ARTICLE)]/ITEMS)[position() > 0 and position() &lt;= $PositionEnd - $ArticleLines]))"/>
        </xsl:when>
        <xsl:when test="$ArticleLines > $PositionEnd">
          <xsl:value-of select="sum((PACKAGE/ARTICLE/INVOICEVALUE)[position() > $PositionStart and position() &lt;= $PositionEnd])"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$Copy &lt;= $Copies">
      <script>includePageBreak();</script>

      <!-- Master table -->
      <div class="pageFrame">
        <!-- always print header -->
        <xsl:apply-templates select="HEADER"/>

        <!-- call subheader if page 1 else start invoice lines section -->
        <xsl:if test="$PageNo = 1">
          <xsl:apply-templates select="." mode="SubHeader"/>
        </xsl:if>

        <div class="row invoiceFrameheight padded2">
          <xsl:apply-templates select="." mode="invoiceLines">
            <xsl:with-param name="ArticleLines" select="$ArticleLines"/>
            <xsl:with-param name="CalculateSubTotal" select="$CalculateSubTotal"/>
            <xsl:with-param name="PackagesNoArticles" select="$PackagesNoArticles"/>
            <xsl:with-param name="PageNo" select="$PageNo"/>
            <xsl:with-param name="PositionEnd" select="$PositionEnd"/>
            <xsl:with-param name="PositionStart" select="$PositionStart"/>
            <xsl:with-param name="SinglePackageValue" select="$SinglePackageValue"/>
            <xsl:with-param name="SubTotal" select="$SubTotal"/>
            <xsl:with-param name="TotalPages" select="$TotalPages"/>
          </xsl:apply-templates>
        </div>

        <!-- Footer section -->

        <!-- Determine if on last page -->
        <xsl:choose>

          <!-- If yes, then we do the totals section -->
          <xsl:when test="$TotalPages = $PageNo">
            <xsl:apply-templates select="." mode="totals-and-sign-off">
              <xsl:with-param name="subtotal" select="$SubTotal + $CalculateSubTotal"/>
            </xsl:apply-templates>
          </xsl:when>

          <!-- If no, then we do a continuation section -->
          <xsl:otherwise>
            <div class="row bottomfiller">
              &#160;
            </div>
            <xsl:apply-templates select="." mode="endcontinuation">
              <xsl:with-param name ="pageNumber" select="$PageNo"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>


        <!-- Page footer -->
        <xsl:apply-templates select ="." mode="pageFooter">
          <xsl:with-param name="pageNumber" select="$PageNo"/>
          <xsl:with-param name="totalPages" select="$TotalPages"/>
        </xsl:apply-templates>
      </div>

      <!-- Call next page -->
      <xsl:if test="$TotalPages > $PageNo">
        <xsl:apply-templates select="." mode="copy">
          <xsl:with-param name="Copy" select="$Copy" />
          <xsl:with-param name="Copies" select="$Copies" />
          <xsl:with-param name="PageNo" select ="$PageNo + 1"/>
          <xsl:with-param name="SubTotal" select="$SubTotal + $CalculateSubTotal"/>
        </xsl:apply-templates>
      </xsl:if>

      <!-- Call next copy -->
      <xsl:if test="$TotalPages = $PageNo">
        <xsl:apply-templates select="." mode="copy">
          <xsl:with-param name="Copy" select="$Copy + 1" />
          <xsl:with-param name="Copies" select="$Copies" />
        </xsl:apply-templates>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Template for invoice lines section -->
  <xsl:template match="CONSIGNMENT" mode="invoiceLines">
    <xsl:param name="PageNo"/>
    <xsl:param name="TotalPages"/>
    <xsl:param name="SubTotal"/>
    <xsl:param name="CalculateSubTotal"/>
    <xsl:param name="ArticleLines"/>
    <xsl:param name="PositionStart"/>
    <xsl:param name="PositionEnd"/>
    <xsl:param name="SinglePackageValue"/>
    <xsl:param name="PackagesNoArticles"/>

    <!-- Header first -->
    <xsl:copy-of select="$linesHeader"/>

    <!-- Continued from previous page? -->
    <xsl:if test="$PageNo > 1">
      <xsl:apply-templates select="." mode="begincontinuation">
        <xsl:with-param name ="pageNumber" select="$PageNo"/>
        <xsl:with-param name="subTotal" select="$SubTotal"/>
      </xsl:apply-templates>
    </xsl:if>

    <!-- Article Lines -->
    <!-- We first print all article lines -if any - then produce lines for packages without articles -->
    <!-- Below log is applied to keep track of our current position -->
    <xsl:choose>
      <!-- Articles have been finalized -->
      <xsl:when test="$ArticleLines &lt;= $PositionStart">
        <xsl:apply-templates select="(PACKAGE[not(ARTICLE)])[position() > ($PositionStart - $ArticleLines) and position() &lt;= $PositionEnd - $ArticleLines]">
          <xsl:with-param name="SinglePackageValue" select="$SinglePackageValue"/>
        </xsl:apply-templates>
      </xsl:when>
      <!-- Articles have not been finalized, but there are only enough left to print on this page - no packages without articles exist -->
      <xsl:when test="$ArticleLines &lt;= $PositionEnd and $PackagesNoArticles = 0">
        <xsl:apply-templates select="(PACKAGE/ARTICLE)[position() > $PositionStart and position() &lt;= $PositionEnd]"/>
      </xsl:when>
      <!-- Articles have not been finalized, but there are only enough left to print on this page - packages without articles do exist -->
      <xsl:when test="$ArticleLines &lt;= $PositionEnd and $PackagesNoArticles > 0">
        <xsl:apply-templates select="(PACKAGE/ARTICLE)[position() > $PositionStart and position() &lt;= $PositionEnd]"/>
        <xsl:apply-templates select="(PACKAGE[not(ARTICLE)])[position() > 0 and position() &lt;= $PositionEnd - $ArticleLines]">
          <xsl:with-param name="SinglePackageValue" select="$SinglePackageValue"/>
        </xsl:apply-templates>
      </xsl:when>
      <!-- Articles have not been finalized, but there are so many left to print that they will need another page page - packages without articles may or may not exist -->
      <xsl:when test="$ArticleLines > $PositionEnd">
        <xsl:apply-templates select="(PACKAGE/ARTICLE)[position() > $PositionStart and position() &lt;= $PositionEnd]"/>
      </xsl:when>
    </xsl:choose>

    <!-- If not last page do a subtotal -->
    <xsl:if test="$TotalPages > $PageNo">
      <xsl:apply-templates select="." mode="subtotal">
        <xsl:with-param name ="pageNumber" select="$PageNo"/>
        <xsl:with-param name="subTotal" select="$SubTotal + $CalculateSubTotal"/>
      </xsl:apply-templates>
    </xsl:if>

  </xsl:template>

  <!-- Template for article lines -->
  <xsl:template match="ARTICLE">
    <div class="row invoiceLineheight">
      <div class="invoiceLinecolumn1 paddedleft">
        <font class="newdata">
          <xsl:value-of select="ITEMS"/>
        </font>
      </div>
      <div class="invoiceLinecolumn2 paddedleft">
        <font class="newdata">
          <br/>
        </font>
      </div>
      <div class="invoiceLinecolumn3 paddedleft centered">
        <font class="newdata">
          <xsl:value-of select="concat(format-number(WEIGHT, '####0.000'), ' ', WEIGHT/@units)"/>
        </font>
      </div>
      <div class="invoiceLinecolumn4 paddedleft">
        <font class="newdata">
          <xsl:choose>
            <xsl:when test="INVOICEDESC/text()">
              <xsl:value-of select="INVOICEDESC"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="DESCRIPTION"/>
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
      <div class="invoiceLinecolumn5 paddedleft">
        <font class="newdata">
          <xsl:value-of select="HTS"/>
        </font>
      </div>
      <div class="invoiceLinecolumn6 paddedleft centered">
        <font class="newdata">
          <xsl:value-of select="ORIGINCOUNTRY"/>
        </font>
      </div>
      <div class="invoiceLinecolumn7 paddedleft textright">
        <font class="newdata">
          <xsl:value-of select="format-number(INVOICEVALUE div ITEMS, '##########0.00')"/>
        </font>
      </div>
      <div class="invoiceLinecolumn8 paddedleft textright">
        <font class="newdata">
          <xsl:value-of select="format-number(INVOICEVALUE, '##########0.00')"/>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for packages that have no articles -->
  <xsl:template match="PACKAGE">
    <xsl:param name="SinglePackageValue" select="0"/>

    <div class="row invoiceLineheight">
      <div class="invoiceLinecolumn1 paddedleft">
        <font class="newdata">
          <xsl:value-of select="ITEMS"/>
        </font>
      </div>
      <div class="invoiceLinecolumn2 paddedleft">
        <font class="newdata">
          <br/>
        </font>
      </div>
      <div class="invoiceLinecolumn3 paddedleft centered">
        <font class="newdata">
          <xsl:value-of select="concat(format-number(WEIGHT, '####0.000'), ' ', WEIGHT/@units)"/>
        </font>
      </div>
      <div class="invoiceLinecolumn4 paddedleft">
        <font class="newdata">
          <xsl:value-of select="GOODSDESC"/>
        </font>
      </div>
      <div class="invoiceLinecolumn5 paddedleft">
        <font class="newdata">
          <xsl:choose>
            <xsl:when test="../STATCODE/text()">
              <xsl:value-of select="../STATCODE"/>
            </xsl:when>
            <xsl:otherwise>
              <br/>
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
      <div class="invoiceLinecolumn6 paddedleft centered">
        <font class="newdata">
          <br/>
        </font>
      </div>
      <div class="invoiceLinecolumn7 paddedleft textright">
        <font class="newdata">
          <xsl:value-of select="format-number($SinglePackageValue, '##########0.00')"/>
        </font>
      </div>
      <div class="invoiceLinecolumn8 paddedleft textright">
        <font class="newdata">
          <xsl:value-of select="format-number($SinglePackageValue * ITEMS, '##########0.00')"/>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for Header section -->
  <xsl:template match="HEADER">
    <div class="row fullheaderheight">
      <div class="column addressLeft">
        <xsl:apply-templates select="SENDER" mode="address"/>
      </div>
      <div class="column addressRight">
        <div class="row99 titleheight centered padded2 bordered">
          <font class="newtitle">
            <b>INVOICE</b>
          </font>
        </div>
        <div class="row99 separatorheight">
          &#160;
        </div>
        <div class="row99 headerheight padded2 bordered">
          <div class="headercolumn">
            <div class="row headerline">
              <font class="newheader">Invoice Number</font>
            </div>
            <div class="row headerline">
              <font class="newheader">Shipping Date</font>
            </div>
            <div class="row headerline">
              <font class="newheader">Consignment Number</font>
            </div>
            <div class="row headerline">
              <font class="newheader">Purchase Order Number</font>
            </div>
            <div class="row headerline">
              <font class="newheader">Invoice Currency</font>
            </div>
            <div class="row headerline">
              <font class="newheader">Sender VAT number</font>
            </div>
            <div class="row headerline">
              <font class="newheader">
                Receiver VAT Number
              </font>
            </div>
          </div>
          <div class="headercolumn">
            <div class="row headerline">
              <font class="newdata">:
			  <xsl:value-of select="../INVOICENUMBER"/>
			  </font>
            </div>
            <div class="row headerline">
              <font class="newdata">
                :
                <xsl:value-of select="SHIPMENTDATE"/>
              </font>
            </div>
            <div class="row headerline">
              <font class="newdata">
                :
                <xsl:value-of select="../CONNUMBER" />
              </font>
            </div>
            <div class="row headerline">
              <font class="newdata">:
			  <xsl:value-of select="../PURCHASEORDERNUMBER" />
			  </font>
            </div>
            <div class="row headerline">
              <font class="newdata">
                :
                <xsl:value-of select="../CURRENCY" />
              </font>
            </div>
            <div class="row headerline">
              <font class="newdata">
                :
                <xsl:value-of select="SENDER/VAT"/>
              </font>
            </div>
            <div class="row headerline">
              <font class="newdata">
                :
                <xsl:value-of select="../RECEIVER/VAT"/>
              </font>
            </div>
            <!--<font class="newdata">
              :
              <br/>
              :
              <xsl:value-of select="SHIPMENTDATE"/>
              <br/>
              :
              <xsl:value-of select="../CONNUMBER" />
              <br/>
              :
              <br/>
              :
              <xsl:value-of select="../CURRENCY" />
              <br/>
              :
              <xsl:value-of select="SENDER/VAT"/>
              <br/>
              :
              <xsl:value-of select="../RECEIVER/VAT"/>
            </font>-->
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Sub header section -->
  <xsl:template match="CONSIGNMENT" mode="SubHeader">
    <div class="row fullheaderheight page1">
      <div class="column addressLeft">
        <xsl:apply-templates select="RECEIVER" mode="address"/>
      </div>
      <div class="column addressRight">
        <xsl:choose>
          <xsl:when test="DELIVERY">
            <xsl:apply-templates select="DELIVERY" mode="address"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="Address">
              <xsl:with-param name="IsEmpty" select="Y"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>

  <!-- Address section -->
  <xsl:template match="SENDER | RECEIVER | DELIVERY" name="Address" mode="address">
    <xsl:param name="IsEmpty" select="'N'">
    </xsl:param>

    <div class="row99 bordered addressheight padded2">
      <xsl:choose>
        <xsl:when test="$IsEmpty = 'N'">
          <xsl:apply-templates select="." mode="addressHeader">
            <xsl:with-param name="Address-Contact">
              <xsl:text>ADDRESS</xsl:text>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="AddressHeader">
            <xsl:with-param name="Address-Contact">
              <xsl:text>ADDRESS</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="addressType" select="'DELIVERY'"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <div class="row addressContentline">
        <font class="newdata">
          <xsl:value-of select="COMPANYNAME" />
        </font>
      </div>
      <div class="row addressContentline">
        <font class="newdata">
          <xsl:value-of select="STREETADDRESS1" />
        </font>
      </div>
      <div class="row addressContentline">
        <font class="newdata">
          <xsl:choose>
            <xsl:when test="STREETADDRESS2/text()">
              <xsl:value-of select="STREETADDRESS2" />
            </xsl:when>
            <xsl:otherwise>
              &#160;
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
      <div class="row addressContentline">
        <font class="newdata">
          <xsl:choose>
            <xsl:when test="STREETADDRESS3/text()">
              <xsl:value-of select="STREETADDRESS3" />
            </xsl:when>
            <xsl:otherwise>
              &#160;
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
      <div class="row addressContentline">
        <font class="newdata">
          <xsl:value-of select="CITY" />
        </font>
      </div>
      <div class="row addressContentline">
        <font class="newdata">
          <xsl:choose>
            <xsl:when test="PROVINCE/text()">
              <xsl:value-of select="PROVINCE" />
            </xsl:when>
            <xsl:otherwise>
              &#160;
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
      <div class="row addressContentline">
        <font class="newdata">
          <xsl:choose>
            <xsl:when test="POSTCODE/text()">
              <xsl:value-of select="POSTCODE" />
            </xsl:when>
            <xsl:otherwise>
              &#160;
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
      <div class="row addressContentline">
        <font class="newdata">
          <xsl:value-of select="COUNTRY" />
        </font>
      </div>
    </div>
    <div class="row99 separatorheight">
      <br/>
    </div>
    <div class="row99 bordered contactheight padded2">
      <xsl:choose>
        <xsl:when test="$IsEmpty = 'N'">
          <xsl:apply-templates select="." mode="addressHeader">
            <xsl:with-param name="Address-Contact">
              <xsl:text>CONTACT</xsl:text>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="AddressHeader">
            <xsl:with-param name="Address-Contact">
              <xsl:text>CONTACT</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="addressType" select="'DELIVERY'"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <div class="contactcolumn1">
        <div class="row addressContentline">
          <font class="newsmallheader">
            Name
          </font>
        </div>
        <div class="row addressContentline">
          <font class="newsmallheader">
            Telephone
          </font>
        </div>
        <div class="row addressContentline">
          <font class="newsmallheader">
            Email
          </font>
        </div>
      </div>
      <div class="contactcolumn2">
        <div class="row addressContentline">
          <font class="newdata">
            :
            <xsl:value-of select="CONTACTNAME" />
          </font>
        </div>
        <div class="row addressContentline">
          <font class="newdata">
            :
            <xsl:value-of select="concat(CONTACTDIALCODE, ' ', CONTACTTELEPHONE)" />
          </font>
        </div>
        <div class="row addressContentline">
          <font class="newdata">
            :
            <xsl:value-of select="CONTACTEMAIL" />
          </font>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Generate section header for addresses and contacts -->
  <xsl:template match="SENDER | RECEIVER | DELIVERY" name="AddressHeader" mode="addressHeader">
    <xsl:param name="addressType">
      <xsl:value-of select="name(.)"/>
    </xsl:param>
    <xsl:param name="Address-Contact" />
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

    <div class="row addressHeader">
      <xsl:choose>
        <xsl:when test="$addressType = 'SENDER'">
          <font class="newheader">
            <xsl:value-of select="concat($addressType, ' ', translate($Address-Contact, $lowercase, $uppercase), ' (Seller/Exporter)')"/>
          </font>
        </xsl:when>
        <xsl:when test="$addressType = 'RECEIVER'">
          <font class="newheader">
            <xsl:value-of select="concat($addressType, ' ', translate($Address-Contact, $lowercase, $uppercase), ' (Buyer/Importer)')"/>
          </font>
        </xsl:when>
        <xsl:when test="$addressType = 'DELIVERY'">
          <font class="newheader">
            <xsl:value-of select="concat(substring($addressType, 1, 7), ' TO ', translate($Address-Contact, $lowercase, $uppercase), ' (if different from RECEIVER)')"/>
          </font>
        </xsl:when>
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- Page footer section -->
  <xsl:template match="CONSIGNMENT" mode="pageFooter">
    <xsl:param name ="pageNumber"/>
    <xsl:param name ="totalPages"/>

    <div class="row subtotalheight">
      <div class="pagecolumn1 centered">
        <font class="newsmalldata">
          <xsl:value-of select="concat('Page ', $pageNumber, ' of ', $totalPages)"/>
        </font>
      </div>
      <div class="pagecolumn2 textright">
        <font class="carrierTerms">
          ExpressConnect 3
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- 'Continued on next page' section -->
  <xsl:template match="CONSIGNMENT" mode="endcontinuation">
    <xsl:param name ="pageNumber"/>

    <div class="row subtotalheight textright">
      <font class="newitalicdata">
        <xsl:value-of select="concat('Continued on page ', $pageNumber + 1)"/>
        <br/>
      </font>
      <div class="row hr"/>
    </div>
  </xsl:template>

  <!-- 'Continued from previous page' section -->
  <xsl:template match="CONSIGNMENT" mode="begincontinuation">
    <xsl:param name ="pageNumber"/>
    <xsl:param name="subTotal"/>

    <div class="row subtotalheight">
      <div class="contcolumn1 textright">
        <font class="newitalicdata">
          <xsl:value-of select="concat('Subtotal transport from page ', $pageNumber - 1)"/>
        </font>
      </div>
      <div class="contcolumn2 textright">
        <font class="newitalicdata">
          <xsl:value-of select="format-number($subTotal, '##########0.00')"/>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Subtotal section -->
  <xsl:template match="CONSIGNMENT" mode="subtotal">
    <xsl:param name="subTotal"/>

    <div class="row invoiceLineheight">
      &#160;
    </div>
    <div class="row subtotalheight">
      <div class="contcolumn1 textright">
        <font class="newitalicdata">
          <xsl:value-of select="'Subtotal for page '"/>
        </font>
      </div>
      <div class="contcolumn2 textright">
        <font class="newitalicdata">
          <xsl:value-of select="format-number($subTotal, '##########0.00')"/>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Invoice Totals section -->
  <xsl:template match="CONSIGNMENT" mode="totals-and-sign-off">
    <xsl:param name="subtotal"/>

    <div class="row totalsheight">
      <div class="rowbordered cellheight borderedrow">
        <div class="cell borderedcolumn">
          <div class="Line80fixed17">
            <font class="borderedheader">
              Total Weight
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn">
          <div class="Line80fixed17">
            <font class="borderedheader">
              <xsl:value-of select="concat(format-number(TOTALWEIGHT, '####0.000'), ' ', TOTALWEIGHT/@units)"/>
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn">
          <div class="Line80fixed17">
            <font class="borderedheader">
              Discount
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn textright">
          <div class="Line80fixed17">
            <font class="borderedheader">
              <xsl:value-of select="DISCOUNT"/>
            </font>
          </div>
        </div>
      </div>
      <div class="halfrow cellheight"/>
      <div class="halfrow cellheight borderedhalfrow">
        <div class="cell borderedcolumn">
          <div class="Line80fixed17">
            <font class="borderedheader">
              Invoice Sub-Total
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn textright">
          <div class="Line80fixed17">
            <font class="borderedheader">
              <xsl:value-of select ="format-number($subtotal, '##########0.00')"/>
            </font>
          </div>
        </div>
      </div>
      <div class="halfrow cellheight"/>
      <div class="halfrow cellheight borderedhalfrow">
        <div class="cell borderedcolumn">
          <div class="Line80fixed17">
            <font class="borderedheader">
              Freight Charges
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn textright">
          <div class="Line80fixed17">
            <font class="borderedheader">
				<xsl:value-of select="FREIGHTCHARGES"/>
            </font>
          </div>
        </div>
      </div>
      <div class="halfrow cellheight"/>
      <div class="halfrow cellheight borderedhalfrow">
        <div class="cell borderedcolumn">
          <div class="Line80fixed17">
            <font class="borderedheader">
              Insurance Charges
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn textright">
          <div class="Line80fixed17">
            <font class="borderedheader">
              <xsl:value-of select="INSURANCECHARGES"/>
            </font>
          </div>
        </div>
      </div>
      <div class="halfrow cellheight"/>
      <div class="halfrow cellheight borderedhalfrow">
        <div class="cell borderedcolumn">
          <div class="Line80fixed17">
            <font class="borderedheader">
              Other Charges
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn textright">
          <div class="Line80fixed17">
            <font class="borderedheader">
               <xsl:value-of select="OTHERCHARGES"/>
            </font>
          </div>
        </div>
      </div>
      <div class="rowbordered cellheight borderedrow">
        <div class="cell borderedcolumn">
          <div class="Line80fixed17">
            <font class="borderedheader">
              INCO Terms
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn">
          <div class="Line80fixed17">
            <font class="borderedheader">
                <xsl:value-of select="INCOTERMS"/>
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn">
          <div class="Line80fixed17">
            <font class="borderedheader">
              Invoice Total
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn textright">
          <div class="Line80fixed17">
            <font class="borderedheader">
              <xsl:value-of select="INVOICETOTAL + format-number($subtotal, '##########0.00')"/>
            </font>
          </div>
        </div>
      </div>
      <!-- Declaration text -->
      <div class="row declarationheight">
        <font class="borderedheader">
          &#160;
        </font>
      </div>
      <!-- Signature -->
      <div class="rowbordered cellheight borderedrow">
        <div class="celldoublewidth borderedcolumn">
          <div class="Line80fixed17">
            <font class="borderedheader">
              Shipper Name and Job Title
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn">
          <div class="Line80fixed17">
            <font class="borderedheader">
              Shipper Signature
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn centered">
          <div class="Line80fixed17">
            <font class="borderedheader">
              Date
            </font>
          </div>
        </div>
      </div>
      <div class="rowbordered celldoubleheight borderedrow">
        <div class="celldoublewidth borderedcolumn ">
          <div class="Line80fixed17 verticalcenter">
            <font class="newdata">
              <xsl:value-of select="HEADER/SENDER/CONTACTNAME"/>
              <br/>
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn">
          <div class="Line80fixed17">
            <font class="newdata">
              <br/>
            </font>
          </div>
        </div>
        <div class="cell borderedcolumn centered">
          <div class="Line80fixed17 verticalcenter">
            <font class="borderedheader">
              <script type="text/javascript">var d = new Date(); document.write(d.getDate()); document.write("/"); document.write(d.getMonth() + 1); document.write("/"); document.write(d.getFullYear());</script>
            </font>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>
