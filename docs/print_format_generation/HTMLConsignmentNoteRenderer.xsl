<?xml version="1.0" encoding="iso-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:lookup="lookup" exclude-result-prefixes="lookup">
  <!-- Version 3.0.1  22-12-2017 11:10 Draft version for Infosys -->
  <!-- Version 3.0.2  03-01-2018 11:18 Simple Dangerous Goods logic -->
  <!-- Version 3.0.3  03-01-2018 13:17 Simple Dangerous Goods logic minor correction -->
  <!-- Version 3.0.4  09-02-2018 09:26 CTS Rendering change -->
  <!-- Version 3.0.5  27-02-2018 15:19 CTS Rendering change separated to new stylesheet as it is not identical to stored stylesheet on server -->
  <!-- Version 3.1.0  04-03-2018 18:39 Changed to using DIV instead of tables + other improvements - Server version -->
  <!-- Version 3.1.1  08-03-2018 10:04 Removal of term country - Server version -->
  <!-- Version 3.1.2  12-03-2018 14:41 Fixing browser compatibility issues - Server version -->
  <!-- Version 3.1.3  11-05-2018 15:35 Updated to fix UK Consignment Note issues. Server version -->
  <!-- Version 3.1.4  22-05-2018 12:10 Update to fix browser compatibility issues. Server version -->
  <!-- Version 3.1.5  16-10-2018 11:44 Fix to support FR customer. Server version -->
  <!-- Version 3.1.6  14-01-2019 16:13 Fixing delivery address issue + IE rendering issues. Server version -->

  <!-- Used only for CTS Rendering
  <xsl:param name="code39Barcode_url"/>
  <xsl:param name="hostName"/>
  <xsl:param name="images_dir"/>
  -->

  <xsl:param name="code39Barcode_url" select="CONSIGNMENTBATCH/BARCODEURL" />
  <xsl:param name="hostName" select="CONSIGNMENTBATCH/HOST" />
  <xsl:param name="images_dir" select="CONSIGNMENTBATCH/IMAGESDIR" />

  <!-- DG Options functionality -->
  <xsl:key name="option-lookup" match="lookup:option" use="lookup:optionCode"/>

  <!-- Dangerous Goods Lookup Table -->
  <lookup:options>
    <lookup:option>
      <lookup:optionCode>LB</lookup:optionCode>
      <lookup:dangerous>Y</lookup:dangerous>
    </lookup:option>
    <lookup:option>
      <lookup:optionCode>DI</lookup:optionCode>
      <lookup:dangerous>Y</lookup:dangerous>
    </lookup:option>
    <lookup:option>
      <lookup:optionCode>BB</lookup:optionCode>
      <lookup:dangerous>Y</lookup:dangerous>
    </lookup:option>
    <lookup:option>
      <lookup:optionCode>GM</lookup:optionCode>
      <lookup:dangerous>Y</lookup:dangerous>
    </lookup:option>
    <lookup:option>
      <lookup:optionCode>HZ</lookup:optionCode>
      <lookup:dangerous>Y</lookup:dangerous>
    </lookup:option>
    <lookup:option>
      <lookup:optionCode>LQ</lookup:optionCode>
      <lookup:dangerous>Y</lookup:dangerous>
    </lookup:option>
    <lookup:option>
      <lookup:optionCode>EQ</lookup:optionCode>
      <lookup:dangerous>Y</lookup:dangerous>
    </lookup:option>
    <lookup:option>
      <lookup:optionCode>XP</lookup:optionCode>
      <lookup:dangerous>Y</lookup:dangerous>
    </lookup:option>
    <lookup:default>
      <lookup:dangerous>N</lookup:dangerous>
    </lookup:default>
  </lookup:options>

  <xsl:variable name="options-table" select="document('')/*/lookup:options"/>

  <xsl:template match="/">
    <html>
      <head>
        <META http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title>TNT Consignment Note</title>
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

        <!-- please notice commented sections-->
        <style>
          <![CDATA[
          div.pagebreak {
              page-break-before: always;
          }

          .body {
              width: 750px;
              border: 1px solid black;
              padding: 2px;
              padding-top: 4px;
              min-height: 522px;
          }

          .column1 {
              width: 370px;
              float: left;
              padding-left: 2px;
              padding-right: 2px;
          }

          .column2 {
              width: 370px;
              float: right;
              padding-left: 2px;
              padding-right: 2px;
          }

          .row {
              width: 100%;
              float: left;
          }

          .rowright {
              width: 99%;
              float: right;
          }

          .rowheight {
              height: 121px;
          }

          .addressheight {
              height: 107px;
          }

          .goodsheight {
              height: 102px;
          }

          .serviceheight {
              height: 189px;
          }

          .dutyheight {
              height: 79px;
          }

          .instructionsheight {
              height: 64px;
          }

          .custrefheight {
              height: 38px;
          }

          .header {
              padding-left: 2px;
              padding-bottom: 2px;
              background-color: #000000;
              height: 15px;
              border: 2px solid #000000;
              width: 99%;
          }

          .separatorheight {
              line-height: 25%;
          }

          .Line30fixed {
              height: 9px;
              line-height: 30%;
              padding-left: 2px;
          }

          .Line80fixed12 {
              height: 12px;
              line-height: 80%;
              padding-left: 2px;
          }

          .Line80fixed17 {
              height: 17px;
              line-height: 80%;
              padding-left: 2px;
          }
          
          .Line80fixed21 {
              height: 21px;
              line-height: 80%;
              padding-left: 2px;
              padding-top: 4px;
          }

          .Line21fixed {
              height: 21px;
              margin: 2px;
          }

          .signatureBox {
              line-height: 2%;
          }

          .barcode {
              line-height: 85%;
          }

          .addressHeader {
              width: 14%;
              float: left;
          }

          .addressData {
              width: 85%;
              float: left;
              overflow: hidden;
          }

          .addressAccHeader {
              width: 32%;
              float: left;
          }

          .addressAccData {
              width: 66%;
              float: left;
          }

          .addressLMFColumnLeft {
              width: 57%;
              float: left;
          }

          .addressLMFColumnRight {
              width: 42%;
              float: right;
          }

          .addressLMFHeaderLLeft1 {
              width: 24.6%;
              float: left;
          }

          .addressLMFDataLLeft1 {
              width: 74%;
              float: left;
          }

          .addressLMFDataLLeft2 {
              width: 63.6%;
              float: left;
              overflow: hidden;
          }

          .addressLMFHeaderLLeft2 {
              width: 35%;
              float: left;
          }

          .addressLMFHeaderRRight1 {
              width: 54%;
              float: left;
          }

          .addressLMFDataRRight1 {
              width: 42%;
              margin-right: 2px;
              float: left;
              text-align: right;
              padding-right: 2px;
          }

          .addressLMFHeaderRRight2 {
              width: 31%;
              float: left;
          }

          .addressLMFDataRRight2 {
              width: 65%;
              margin-right: 2px;
              float: left;
              overflow: hidden;
              padding-right: 2px;
          }

          .HtsColumnLeft {
              width: 36%;
              float: left;
          }

          .HtsColumnRight {
              width: 63%;
              float: right;
          }

          .PackColumn {
              width: 27%;
              float: left;
          }

          .WeightColumn {
              width: 35%;
              float: left;
          }

          .VolumeColumn {
              width: 37%;
              float: left;
          }

          .ServColumnHeader {
              width: 12%;
              float: left;
          }

          .ServColumnData {
              width: 48%;
              float: left;
          }

          .ServGenColumnRight {
              width: 39%;
              float: left;
          }

          .centered {
              text-align: center;
          }

          .CurColumnHeader {
              width: 28%;
              float: left;
          }

          .padded2 {
              padding-top: 2px;
              padding-right: 2px;
              padding-bottom: 2px;
          }

          .CurColumnData {
              width: 32%;
              float: left;
              overflow: hidden;
          }

          .AmountColumnHeader {
              width: 10%;
              float: left;
          }

          .AmountColumnData {
              width: 22%;
              float: left;
          }

          .conColumnLeft {
              width: 60%;
              float: left;
              padding-right: 2px;
          }

          .conColumnRight {
              width: 35%;
              float: right;
              padding-left: 2px;
          }

          .bordered {
              border: 1px solid #000000;
          }

          .separator {
              width: 2px;
              padding-left: 2px;
              padding-right: 2px;
              float: left;
          }

          .textright {
              text-align: right;
          }

          .footorcolumn {
              width: 50%;
              float: left;
          }

          .signatureheight {
              height: 25px;
          }

          font.invertedCelldata {
              color: #FFFFFF;
              font-weight: bold;
              font-family: arial, "sans-serif";
              font-size: 8pt;
          }

          font {
              color: black;
          }

          font.newheader {
              font-weight: bold;
              font-family: arial, "sans-serif";
              font-size: 7pt;
          }

          font.newdata {
              font-family: arial, "sans-serif";
              font-size: 7pt;
          }

          font.signature {
              font-weight: bold;
              font-family: arial, "sans-serif";
              font-size: 7pt;
              line-height: 30px;
          }

          font.carrierTerms {
              font-family: arial, helvetica "sans-serif";
              font-size: 4pt;
              line-height: 80%;
          }

          font.newbarcode {
              color: black;
              font-weight: bold;
              font-family: "arial";
              font-size: 7pt;
              letter-spacing: 0.05cm
          }

          font.newlargeheader {
              font-weight: bold;
              font-family: arial, "sans-serif";
              font-size: 12pt;
              line-height: 100%;
          }

          font.newsmalldata {
              font-family: arial, "sans-serif";
              font-size: 5pt;
          }

          font.UKsmallprint {
              font-family: arial, "sans-serif";
              font-size: 6pt;
          }

          font.UKdata {
              font-family: arial, "sans-serif";
              font-size: 8pt;
          }

          .UKdataBold {
              font-weight: bold;
          }

          font.UKheader {
              font-weight: bold;
              font-family: arial, helvetica "sans-serif";
              font-size: 8pt;
          }

          img.center {
              display: block;
              margin-bottom: 7px;
              margin-left: auto;
              margin-right: auto;
              margin-top: 8px;
          }
				
          .UKoutertable {
              background-color: #FF6600;
              border: 0px;
              border-spacing: 1px;
              padding: 2px;
              width: 596px;
              overflow: hidden;
              min-height: 766px;
          }

          .UKleftside {
              float: left;
              width: 263px;
              min-height: 740px;
              border-color: #33FF33;
          }

          .UKrightside {
              float: right;
              width: 326px;
              min-height: 740px;
              border-color: #33FF33;
          }

          .whitebordered {
              border: 1px solid #656566;
              padding: 1px;
              background-color: #FFFFFF;
          }

          .UKleftrow1height {
              height: 84px;
          }

          .UKrightrow1height {
              height: 142px;
          }

          .UKrightrow1column1 {
              float: left;
              width: 64%;
          }

          .UKrightrow1column2 {
              float: right;
              width: 32%;
          }

          .greenbordered {
              border: 1px solid #656566;
              border-collapse: collapse;
              padding: 1px;
              background-color: #FDBA8D;
          }

          .UKleftrow3height {
              height: 40px;
          }

          .bottommargin {
              margin-bottom: 2px;
          }

          .UKrightrow3height {
              height: 18px;
          }

          .UKleftrow8height {
              height: 42px;
          }

          .UKlogo {
              float: left;
              width: 61%;
              padding-left: 1px;
              height: 100%;
          }

          .UKcopyfor {
              float: left;
              width: 26%;
              height: 100%;
          }

          .UKdiv {
              float: left;
              width: 10%;
              border-left: 1px solid #656566;
              height: 100%;
              padding-left: 1px;
          }

          .UKimageheight {
              height: 20px;
          }

          .UKacc1 {
              float: left;
              width: 65%;
          }

          .UKacc2 {
              float: left;
              width: 15%;
          }

          .UKacc3 {
              float: left;
              width: 20%;
          }

          .UKaddress {
              height: 170px;
          }

          .UKaddressline {
              height: 17px;
              line-height: 16px;
          }

          .UKmultiaddressline {
              line-height: 16px;
          }

          .UKsendersignheight {
              height: 71px;
          }

          .UKssign1a {
              float: left;
              width: 66%;
          }

          .UKssign1b {
              float: right;
              width: 33%;
              text-align: right;
              padding-right: 2px;
          }

          .UKssign2height {
              height: 30px;
          }

          .UKssign3height {
              height: 21px;
          }

          .UKserviceheight {
              min-height: 22px;
          }

          .UKdglineheight {
              height: 22px;
          }

          .UKdgimg {
              float: left;
              width: 54%;
              height: 100%;
          }

          .UKdgun {
              float: right;
              width: 44%;
              height: 100%;
          }

          .borderedrowgrey {
              border-top: 1px solid #CCCCCC;
              border-bottom: 1px solid #CCCCCC;
          }

          .borderedrowgrey + .borderedrowgrey {
              border-top: 0px solid #CCCCCC;
          }

          .borderedrowgrey:last-child {
              border-bottom: 0px solid #CCCCCC;
          }

          .borderedcolumn {
              border-right: 1px solid #CCCCCC;
              height: 100%;
          }

          .borderedcolumn:last-child {
              border-right: 0px solid #CCCCCC;
          }

          .borderedinternalrowgrey {
              border-bottom: 1px solid #CCCCCC;
          }

          .UKgoods {
              padding: 0px;
              min-height: 154px;
          }

          .UKgoodstotalheight {
              height: 61px;
          }

          .UKgoodscol1 {
              float: left;
              width: 38%;
          }

          .UKgoodscol2 {
              float: left;
              width: 12%;
          }

          .UKgoodscolr {
              float: left;
              width: 37%;
              height: 100%;
          }

          .UKpdfheight {
              height: 101px;
              padding-bottom: 7px;
          }

          .UKtc {
              padding: 2px;
              width: 594px;
              overflow: hidden;
}                 ]]>
        </style>
      </head>
      <body>
        <!-- Loop through each consignment -->
        <xsl:apply-templates select="/CONSIGNMENTBATCH/CONSIGNMENT" mode="loop"/>
      </body>
    </html>
  </xsl:template>

  <!-- Template to select what layout to use for a consignment -->
  <xsl:template match="CONSIGNMENT" mode="loop">
    <xsl:choose>
      <xsl:when test="@marketType='DOMESTIC'">
        <xsl:choose>
          <xsl:when test="@originCountry='GB'">
            <xsl:apply-templates mode="UKDomesticConNote" select=".">
              <xsl:with-param name="copyFor">C</xsl:with-param>
              <xsl:with-param name="returns">false</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates mode="UKDomesticConNote" select=".">
              <xsl:with-param name="copyFor">P</xsl:with-param>
              <xsl:with-param name="returns">false</xsl:with-param>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="InternationalConnote" select =".">
              <xsl:with-param name="whosCopy" select="'C'" />
            </xsl:apply-templates>
            <xsl:apply-templates mode="InternationalConnote" select=".">
              <xsl:with-param name="whosCopy" select="'R'" />
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="InternationalConnote" select =".">
          <xsl:with-param name="whosCopy" select="'C'" />
        </xsl:apply-templates>
        <xsl:apply-templates mode="InternationalConnote" select=".">
          <xsl:with-param name="whosCopy" select="'R'" />
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Template to use for an interntional consignment -->
  <xsl:template match="CONSIGNMENT" mode="InternationalConnote">
    <xsl:param name="whosCopy" />

    <script>includePageBreak();</script>
    <!-- Master section -->

    <div class="body">
      <!-- left table column start -->
      <div class="column1">
        <!-- Sender element -->
        <xsl:choose>
          <xsl:when test="HEADER/COLLECTION/COMPANYNAME/text()">
            <xsl:apply-templates select ="HEADER/COLLECTION" mode="IntAddress">
              <xsl:with-param name="Heading">
                <xsl:text>1.From (Collection Address)</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="SenderAccount" select="HEADER/SENDER/ACCOUNT"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select ="HEADER/SENDER" mode="IntAddress">
              <xsl:with-param name="Heading">
                <xsl:text>1.From (Collection Address)</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="SenderAccount" select="HEADER/SENDER/ACCOUNT"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Receiver element -->
        <xsl:apply-templates select="RECEIVER" mode="IntAddress">
          <xsl:with-param name="Heading">
            <xsl:text>2.To (Receiver Address)</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
        <!-- Goods element -->
        <xsl:apply-templates select="." mode="IntGoods"/>
        <!-- Services element -->
        <xsl:apply-templates select="." mode="IntService">
          <xsl:with-param name="whosCopy" select="$whosCopy"/>
        </xsl:apply-templates>
      </div>
      <!-- left table column end -->
      <!-- right table column start -->
      <div class="column2">
        <!-- Barcode element -->
        <xsl:apply-templates select="CONNUMBER" mode="IntBarcode"/>
        <!-- DELIVERY element -->
        <xsl:choose>
          <xsl:when test ="DELIVERY/COMPANYNAME/text()">
            <xsl:apply-templates select="DELIVERY" mode="IntAddress">
              <xsl:with-param name="Heading">
                <xsl:text>A. Delivery Address</xsl:text>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="InternationalAddress">
              <xsl:with-param name="Heading">
                <xsl:text>A. Delivery Address</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Dutiable details element -->
        <xsl:apply-templates select="." mode="IntDuty">
          <xsl:with-param name="whosCopy" select="$whosCopy"/>
        </xsl:apply-templates>
        <!-- Special Instructions element -->
        <xsl:choose>
          <xsl:when test="DELIVERYINST/text()">
            <xsl:apply-templates select="DELIVERYINST" mode="intSpecialInstructions"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="CONNUMBER" mode="intSpecialInstructions">
              <xsl:with-param name="IsEmpty">
                <xsl:text>Y</xsl:text>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Customer reference section -->
        <xsl:choose>
          <xsl:when test="CUSTOMERREF/text()">
            <xsl:apply-templates select="CUSTOMERREF" mode="intCustomerReference"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="CONNUMBER" mode="intCustomerReference">
              <xsl:with-param name="IsEmpty">
                <xsl:text>Y</xsl:text>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Receiver Account element -->
        <xsl:choose>
          <xsl:when test ="PAYMENTIND = 'R'">
            <xsl:choose>
              <xsl:when test="RECEIVER/ACCOUNT/text()">
                <xsl:apply-templates select="RECEIVER/ACCOUNT" mode="intReceiverPays"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="CONNUMBER" mode="intReceiverPays">
                  <xsl:with-param name="IsEmpty">
                    <xsl:text>Y</xsl:text>
                  </xsl:with-param>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="CONNUMBER" mode="intReceiverPays">
              <xsl:with-param name="IsEmpty">
                <xsl:text>Y</xsl:text>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Signatory section -->
        <xsl:apply-templates select="CONNUMBER" mode="IntSign">
          <xsl:with-param name="whosCopy" select="$whosCopy"/>
        </xsl:apply-templates>
        <!-- Stylesheet id -->
        <div class="Line30fixed textright">
          <font class="carrierTerms">
            ExpressConnect 3
          </font>
        </div>
      </div>
      <!-- right table column end -->
    </div>
  </xsl:template>

  <!-- Template to match international addresses -->
  <xsl:template match="SENDER | RECEIVER | COLLECTION | DELIVERY" name="InternationalAddress" mode ="IntAddress">
    <xsl:param name="SenderAccount">
      <xsl:text>&#160;</xsl:text>
    </xsl:param>
    <xsl:param name="Heading">
      <xsl:text>&#160;</xsl:text>
    </xsl:param>

    <div>
      <xsl:choose>
        <xsl:when test="name(.) = 'SENDER' or name(.) = 'COLLECTION'">
          <xsl:attribute name="class">row rowheight</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">row addressheight</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="COMPANYNAME/text()">
          <xsl:apply-templates select="COMPANYNAME" mode="InternationalConnote">
            <xsl:with-param name="HeaderText" select="$Heading"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="../CONNUMBER/text()">
          <xsl:apply-templates select="../CONNUMBER" mode="InternationalConnote">
            <xsl:with-param name="HeaderText" select="$Heading"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="CONNUMBER" mode="InternationalConnote">
            <xsl:with-param name="HeaderText" select="$Heading"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="name(.) = 'SENDER' or name(.) = 'COLLECTION'">
        <div class="row Line80fixed12">
          <div class="addressAccHeader">
            <font class="newheader">
              Sender's Account No :
            </font>
          </div>
          <div class="addressAccData">
            <font class="newdata">
              <xsl:value-of select="$SenderAccount" />
            </font>
          </div>
        </div>
      </xsl:if>
      <xsl:call-template name="InternationalBaseAddress"></xsl:call-template>
    </div>
  </xsl:template>

  <!-- General address template -->
  <xsl:template name="InternationalBaseAddress">
    <div class="row Line80fixed12">
      <div class="addressHeader">
        <font class="newheader">
          Name :
        </font>
      </div>
      <div class="addressData">
        <font class="newdata">
          <xsl:value-of select="COMPANYNAME" />
        </font>
      </div>
    </div>
    <div class="row Line80fixed12">
      <div class="addressHeader">
        <font class="newheader">
          Address :
        </font>
      </div>
      <div class="addressData">
        <font class="newdata">
          <xsl:value-of select="STREETADDRESS1" />
        </font>
      </div>
    </div>
    <div class="row Line80fixed12">
      <div class="addressHeader">
        <font class="newheader">
          &#160;
        </font>
      </div>
      <div class="addressData">
        <font class="newdata">
          <xsl:choose>
            <xsl:when test="STREETADDRESS2/text()">
              <xsl:value-of select="STREETADDRESS2" />
              <xsl:if test="STREETADDRESS3/text()">
                ,
                <xsl:value-of select="STREETADDRESS3" />
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              &#160;
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
    </div>
    <div class="row separatorheight">
      &#160;
    </div>
    <div class="row Line80fixed12">
      <div class="addressLMFColumnLeft">
        <div class="addressLMFHeaderLLeft1">
          <font class="newheader">
            City :
          </font>
        </div>
        <div class="addressLMFDataLLeft1">
          <font class="newdata">
            <xsl:value-of select="CITY" />
          </font>
        </div>
      </div>
      <div class="addressLMFColumnRight">
        <div class="addressLMFHeaderRRight1">
          <font class="newheader">
            Postal/Zip Code :
          </font>
        </div>
        <div class="addressLMFDataRRight1">
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
      </div>
    </div>
    <div class="row Line80fixed12">
      <div class="addressLMFColumnLeft">
        <div class="addressLMFHeaderLLeft1">
          <font class="newheader">
            Province :
          </font>
        </div>
        <div class="addressLMFDataLLeft1">
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
      </div>
      <div class="addressLMFColumnRight">
        <div class="addressLMFHeaderRRight2">
          <font class="newheader">
            Location :
          </font>
        </div>
        <div class="addressLMFDataRRight2">
          <font class="newdata">
            <xsl:value-of select="COUNTRY" />
          </font>
        </div>
      </div>
    </div>
    <div class="row separatorheight">
      &#160;
    </div>
    <div class="row Line80fixed12">
      <div class="addressLMFColumnLeft">
        <div class="addressLMFHeaderLLeft2">
          <font class="newheader">
            Contact Name :
          </font>
        </div>
        <div class="addressLMFDataLLeft2">
          <font class="newdata">
            <xsl:choose>
              <xsl:when test="CONTACTNAME/text()">
                <xsl:value-of select="CONTACTNAME" />
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
            </xsl:choose>
          </font>
        </div>
      </div>
      <div class="addressLMFColumnRight">
        <div class="addressLMFHeaderRRight2">
          <font class="newheader">
            Tel no :
          </font>
        </div>
        <div class="addressLMFDataRRight2">
          <font class="newdata">
            <xsl:choose>
              <xsl:when test="CONTACTTELEPHONE/text()">
                <xsl:value-of select="concat(CONTACTDIALCODE, ' ', CONTACTTELEPHONE)" />
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
            </xsl:choose>
          </font>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match Goods section -->
  <xsl:template match="CONSIGNMENT" mode="IntGoods">
    <div class="row goodsheight">
      <xsl:apply-templates select="CONNUMBER" mode="InternationalConnote">
        <xsl:with-param name="HeaderText">
          <xsl:text>3.Goods</xsl:text>
        </xsl:with-param>
      </xsl:apply-templates>
      <div class="row Line80fixed12">
        <font class="newheader">
          General Description :
        </font>
      </div>
      <div class="row Line80fixed12">
        <font class="newdata">
          <xsl:value-of select="GOODSDESC1" />
        </font>
      </div>
      <div class="row Line80fixed12">
        <font class="newdata">
          <xsl:if test="GOODSDESC2/text()">
            <xsl:value-of select="GOODSDESC2" />
          </xsl:if>
        </font>
      </div>
      <div class="row Line80fixed12">
        <font class="newdata">
          <xsl:if test="GOODSDESC3/text()">
            <xsl:value-of select="GOODSDESC3" />
          </xsl:if>
        </font>
      </div>
      <div class="row Line80fixed12">
        <div class="HtsColumnLeft">
          <font class="newheader">
            Harmonized Tariff Code :
          </font>
        </div>
        <div class="HtsColumnRight">
          <font class="newdata">
            <xsl:value-of select="STATCODE" />
          </font>
        </div>
      </div>
      <div class="row separatorheight">
        <br/>
      </div>
      <div class="row Line80fixed12">
        <div class="PackColumn">
          <font class="newheader">
            Total Packages :&#160;
          </font>
          <font class="newdata">
            <xsl:value-of select="TOTALITEMS" />
          </font>
        </div>
        <div class="WeightColumn">
          <font class="newheader">
            Total Weight :&#160;
          </font>
          <font class="newdata">
            <xsl:value-of select="concat(format-number(TOTALWEIGHT, '####0.000'), ' ', TOTALWEIGHT/@units)" />
          </font>
        </div>
        <div class="VolumeColumn">
          <font class="newheader">
            Total Volume :&#160;
          </font>
          <font class="newdata">
            <xsl:value-of select="concat(format-number(TOTALVOLUME, '##0.000'), ' ', TOTALVOLUME/@units)" />
          </font>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match Services section -->
  <xsl:template match="CONSIGNMENT" mode="IntService">
    <xsl:param name="whosCopy" />

    <!-- Variables used with DG functionality -->
    <xsl:variable name="DG-Option1">
      <xsl:apply-templates select="$options-table">
        <xsl:with-param name="look-for">
          <xsl:choose>
            <xsl:when test="contains(OPTION1, ' ')">
              <xsl:value-of select="substring-before(OPTION1, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="OPTION1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="DG-Option2">
      <xsl:apply-templates select="$options-table">
        <xsl:with-param name="look-for">
          <xsl:choose>
            <xsl:when test="contains(OPTION2, ' ')">
              <xsl:value-of select="substring-before(OPTION2, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="OPTION2"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="DG-Option3">
      <xsl:apply-templates select="$options-table">
        <xsl:with-param name="look-for">
          <xsl:choose>
            <xsl:when test="contains(OPTION3, ' ')">
              <xsl:value-of select="substring-before(OPTION3, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="OPTION3"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="DG-Option4">
      <xsl:apply-templates select="$options-table">
        <xsl:with-param name="look-for">
          <xsl:choose>
            <xsl:when test="contains(OPTION4, ' ')">
              <xsl:value-of select="substring-before(OPTION4, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="OPTION4"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="DG-Option5">
      <xsl:apply-templates select="$options-table">
        <xsl:with-param name="look-for">
          <xsl:choose>
            <xsl:when test="contains(OPTION5, ' ')">
              <xsl:value-of select="substring-before(OPTION5, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="OPTION5"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>

    <div class="row serviceheight">
      <xsl:apply-templates select="CONNUMBER" mode="InternationalConnote">
        <xsl:with-param name="HeaderText">
          <xsl:text>4. Services</xsl:text>
        </xsl:with-param>
      </xsl:apply-templates>
      <div class="row Line80fixed12">
        <div class="ServColumnHeader">
          <font class="newheader">
            Service :
          </font>
        </div>
        <div class="ServColumnData">
          <font class="newdata">
            <xsl:value-of select="SERVICE" />
          </font>
        </div>
        <div class="ServGenColumnRight centered">
          <font class="newheader">
            &#160;
          </font>
        </div>
      </div>
      <div class="row Line80fixed12">
        <div class="ServColumnHeader">
          <font class="newheader">
            Options :
          </font>
        </div>
        <div class="ServColumnData">
          <font class="newdata">
            <xsl:choose>
              <xsl:when test="string-length(normalize-space(OPTION1)) != 0">
                <xsl:value-of select="OPTION1" />
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
            </xsl:choose>
          </font>
        </div>
        <div class="ServGenColumnRight centered">
          <font class="newheader">
            <!-- Simple DG logic -->
            <xsl:choose>
              <xsl:when test="$DG-Option1 = 'Y' or $DG-Option2 = 'Y' or $DG-Option3 = 'Y' or $DG-Option4 = 'Y' or $DG-Option5 = 'Y'">
                DANGEROUS GOODS
              </xsl:when>
              <xsl:otherwise>
                NON DANGEROUS GOODS
              </xsl:otherwise>
            </xsl:choose>
          </font>
        </div>
      </div>
      <div class="row Line80fixed12">
        <div class="ServColumnHeader">
          <font class="newheader">
            &#160;
          </font>
        </div>
        <div class="ServColumnData">
          <font class="newdata">
            <xsl:choose>
              <xsl:when test="string-length(normalize-space(OPTION2)) != 0">
                <xsl:value-of select="OPTION2" />
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
            </xsl:choose>
          </font>
        </div>
        <div class="ServGenColumnRight centered">
          <font class="newheader">
            &#160;
          </font>
        </div>
      </div>
      <div class="row Line80fixed12">
        <div class="ServColumnHeader">
          <font class="newheader">
            &#160;
          </font>
        </div>
        <div class="ServColumnData">
          <font class="newdata">
            <xsl:choose>
              <xsl:when test="string-length(normalize-space(OPTION3)) != 0">
                <xsl:value-of select="OPTION3" />
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
            </xsl:choose>
          </font>
        </div>
        <div class="ServGenColumnRight centered">
          <font class="newheader">
            &#160;
          </font>
        </div>
      </div>
      <div class="row Line80fixed12">
        <div class="ServColumnHeader">
          <font class="newheader">
            &#160;
          </font>
        </div>
        <div class="ServColumnData">
          <font class="newdata">
            <xsl:choose>
              <xsl:when test="string-length(normalize-space(OPTION4)) != 0">
                <xsl:value-of select="OPTION4" />
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
            </xsl:choose>
          </font>
        </div>
        <div class="ServGenColumnRight centered">
          <font class="newheader">
            <xsl:choose>
              <xsl:when test="PAYMENTIND = 'S'">
                SENDER PAYS
              </xsl:when>
              <xsl:otherwise>
                RECEIVER PAYS
              </xsl:otherwise>
            </xsl:choose>
          </font>
        </div>
      </div>
      <div class="row Line80fixed12">
        <div class="ServColumnHeader">
          <font class="newheader">
            &#160;
          </font>
        </div>
        <div class="ServColumnData">
          <font class="newdata">
            <xsl:choose>
              <xsl:when test="string-length(normalize-space(OPTION5)) != 0">
                <xsl:value-of select="OPTION5" />
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
            </xsl:choose>
          </font>
        </div>
        <div class="ServGenColumnRight">
          <font class="newheader">
            &#160;
          </font>
        </div>
      </div>
      <div class="row Line80fixed21">
        <xsl:choose>
          <xsl:when test="$whosCopy = 'C'">
            <div class="CurColumnHeader padded2">
              <font class="newheader">
                Insurance Currency :
              </font>
            </div>
            <div class="CurColumnData padded2">
              <font class="newdata">
                <xsl:choose>
                  <xsl:when test="INSURANCECURRENCY/text()">
                    <xsl:value-of select="INSURANCECURRENCY" />
                  </xsl:when>
                  <xsl:otherwise>
                    &#160;
                  </xsl:otherwise>
                </xsl:choose>
              </font>
            </div>
            <div class="AmountColumnHeader padded2">
              <font class="newheader">
                Value :
              </font>
            </div>
            <div class="AmountColumnData padded2">
              <font class="newdata">
                <xsl:if test="INSURANCEVALUE/text()">
                  <xsl:value-of select="format-number(INSURANCEVALUE, '##########0.00')" />
                </xsl:if>
              </font>
            </div>
          </xsl:when>
          <xsl:otherwise>
            &#160;
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="row Line80fixed21">
        <div class="CurColumnHeader">
          <font class="signature">
            Sender's Signature :
          </font>
        </div>
        <div class="CurColumnData">
          <font class="signature">
            _____________________
          </font>
        </div>
        <div class="AmountColumnHeader">
          <font class="signature">
            Date :
          </font>
        </div>
        <div class="AmountColumnData">
          <font class="signature">
            <u>
              <xsl:value-of select="HEADER/SHIPMENTDATE"/>
            </u>
          </font>
        </div>
      </div>
      <div class="row signatureheight">
        &#160;
      </div>
      <div class="row signatureBox">
        <font class="carrierTerms">
          OUR LIABILITY FOR LOSS, DAMAGE AND DELAY IS LIMITED BY THE CMR CONVENTION OR THE WARSAW CONVENTION WHICHEVER IS APPLICABLE. THE SENDER AGREES THAT CARRIAGE OF THIS CONSIGNMENT IS SUBJECT TO THE TERMS AND CONDITIONS WHICH CAN BE VIEWED AT WWW.TNT.COM. IF NO SERVICES OR BILLING OPTIONS ARE SELECTED THE FASTEST AVAILABLE SERVICE WILL BE CHARGED TO THE SENDER.
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match Barcode section-->
  <xsl:template match="CONNUMBER" mode="IntBarcode">
    <div class="row rowheight">
      <div class="row centered">
        <img class="center" src="{$hostName}{$images_dir}/logo-small.gif" />
      </div>
      <div class="row barcode">
        <div class="centered">
          <img class="center" height="47" width="350">
            <xsl:attribute name="src">
              <xsl:value-of select="concat($hostName, $code39Barcode_url, .)" />
            </xsl:attribute>
          </img>
        </div>
        <div class="centered">
          <font class="newdata">
            Please quote this Number if you have an enquiry.
          </font>
          <font class="newbarcode">
            *
            <xsl:value-of select="." />
            *
          </font>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match Dutiables section-->
  <xsl:template match="CONSIGNMENT" mode="IntDuty">
    <xsl:param name="whosCopy" />

    <div class="row dutyheight">
      <xsl:apply-templates select="CONNUMBER" mode="InternationalConnote">
        <xsl:with-param name="HeaderText">
          <xsl:text>B. Dutiable Shipment Details</xsl:text>
        </xsl:with-param>
      </xsl:apply-templates>
      <div class="row Line80fixed12">
        <font class="newheader">
          Receivers VAT/TVA/BTW/MWST No. :
        </font>
      </div>
      <div class="row Line80fixed12">
        <font class="newdata">
          <xsl:value-of select="RECEIVER/VAT" />
        </font>
      </div>
      <div class="row Line80fixed12">
        <font class="newheader">
          <xsl:choose>
            <xsl:when test="$whosCopy = 'C'">
              Invoice Value of Dutiables
            </xsl:when>
            <xsl:otherwise>
              &#160;
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
      <div class="row Line80fixed12">
        <xsl:choose>
          <xsl:when test="$whosCopy = 'C'">
            <div class="CurColumnHeader padded2">
              <font class="newheader">
                Currency :
              </font>
            </div>
            <div class="CurColumnData padded2">
              <font class="newdata">
                <xsl:choose>
                  <xsl:when test="CURRENCY/text()">
                    <xsl:value-of select="CURRENCY" />
                  </xsl:when>
                  <xsl:otherwise>
                    &#160;
                  </xsl:otherwise>
                </xsl:choose>
              </font>
            </div>
            <div class="AmountColumnHeader padded2">
              <font class="newheader">
                Value :
              </font>
            </div>
            <div class="AmountColumnData padded2">
              <font class="newdata">
                <xsl:value-of select="GOODSVALUE" />
              </font>
            </div>
          </xsl:when>
          <xsl:otherwise>
            &#160;
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match Signatory section -->
  <xsl:template match="node()" mode="IntSign">
    <xsl:param name="whosCopy" />

    <div class="row">
      <div class="conColumnLeft instructionsheight bordered">
        <div class="topfooterrow">
          <div class="row Line80fixed12">
            <font class="newdata">
              Received by TNT
            </font>
          </div>
          <div class="row Line80fixed12">
            <font class="newdata">
              by (Name) :
            </font>
          </div>
        </div>
        <div class="footorcolumn">
          <div class="row Line80fixed21 centered">
            <font class="signature">
              Date : ____/____/____
            </font>
          </div>
        </div>
        <div class="footorcolumn">
          <div class="row Line80fixed21 centered">
            <font class="signature">
              Time : ____:____
            </font>
          </div>
        </div>
      </div>
      <div class="separator instructionsheight">
        &#160;
      </div>
      <div class="conColumnRight instructionsheight bordered">
        <div class="row Line21fixed centered">
          <font class="newlargeheader">
            <xsl:choose>
              <xsl:when test="$whosCopy = 'C'">
                CUSTOM'S
              </xsl:when>
              <xsl:otherwise>
                RECEIVER'S
              </xsl:otherwise>
            </xsl:choose>
          </font>
        </div>
        <div class="row Line21fixed centered">
          <font class="newlargeheader">
            COPY
          </font>
        </div>
        <div class="row Line30fixed centered">
          <font class="newsmalldata">
            Please Keep For Reference
          </font>
        </div>
      </div>
    </div>

  </xsl:template>

  <!-- Template to match header sections -->
  <xsl:template match="node()" mode="InternationalConnote">
    <xsl:param name="HeaderText"/>
    <div class="header">
      <font class="invertedCelldata">
        <xsl:value-of select="$HeaderText"/>
      </font>
    </div>
  </xsl:template>

  <!-- Template to match Special Instrutions section -->
  <xsl:template match="node()" mode="intSpecialInstructions">
    <xsl:param name="IsEmpty">
      <xsl:text>N</xsl:text>
    </xsl:param>
    <div class="row instructionsheight">
      <xsl:apply-templates select="../CONNUMBER" mode="InternationalConnote">
        <xsl:with-param name="HeaderText">
          <xsl:text>C. Special Delivery Instructions</xsl:text>
        </xsl:with-param>
      </xsl:apply-templates>
      <div class="row Line80fixed12">
        <font class="newdata">
          <xsl:value-of select="." />
        </font>
      </div>
      <div class="row Line80fixed12">
        <font class="newdata">
          &#160;
        </font>
      </div>
      <div class="row Line80fixed12">
        <font class="newdata">
          &#160;
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match Customer Reference section -->
  <xsl:template match="node()" mode="intCustomerReference">
    <xsl:param name="IsEmpty">
      <xsl:text>N</xsl:text>
    </xsl:param>
    <div class="row custrefheight">
      <xsl:apply-templates select="../CONNUMBER" mode="InternationalConnote">
        <xsl:with-param name="HeaderText">
          <xsl:text>D. Customer Reference</xsl:text>
        </xsl:with-param>
      </xsl:apply-templates>
      <div class="row Line80fixed17">
        <font class="newdata">
          <xsl:choose>
            <xsl:when test="$IsEmpty = 'N'">
              <xsl:value-of select="." />
            </xsl:when>
            <xsl:otherwise>
              &#160;
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match Receiver Pays section -->
  <xsl:template match="node()" mode="intReceiverPays">
    <xsl:param name="IsEmpty">
      <xsl:text>N</xsl:text>
    </xsl:param>
    <div class="row custrefheight">
      <xsl:choose>
        <xsl:when test="$IsEmpty = 'N'">
          <xsl:apply-templates select="../../CONNUMBER" mode="InternationalConnote">
            <xsl:with-param name="HeaderText">
              <xsl:text>E. Invoice Receiver (Receiver's Account Number)</xsl:text>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="../CONNUMBER" mode="InternationalConnote">
            <xsl:with-param name="HeaderText">
              <xsl:text>E. Invoice Receiver (Receiver's Account Number)</xsl:text>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
      <div class="row Line80fixed17">
        <font class="newdata">
          <xsl:choose>
            <xsl:when test="$IsEmpty = 'N'">
              <xsl:value-of select="." />
            </xsl:when>
            <xsl:otherwise>
              &#160;
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Determining if option is DG -->
  <xsl:template match="lookup:options">
    <!-- This template updated to add a default value -->
    <xsl:param name="look-for"/>
    <xsl:variable name="default" select="lookup:default/lookup:dangerous"/>
    <xsl:variable name="result" select="key('option-lookup', $look-for)/lookup:dangerous"/>
    <xsl:choose>
      <xsl:when test="$result">
        <xsl:value-of select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$default"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Template to use for a UK Domestic consignment -->
  <xsl:template match="CONSIGNMENT" mode="UKDomesticConNote">
    <xsl:param name="copyFor"/>
    <xsl:param name="returns"/>


    <script>includePageBreak();</script>

    <div class="UKoutertable">
      <!-- LEFT HAND COLUMN -->
      <div class="UKleftside">
        <xsl:apply-templates select="CONNUMBER" mode="UKheader">
          <xsl:with-param name="copyfor" select="$copyFor"/>
        </xsl:apply-templates>
        <div class="row UKimageheight">
          <img src="{$hostName}{$images_dir}/1x1.gif" width="1" height="1"/>
          &#160;
        </div>
        <xsl:choose>
          <xsl:when test="HEADER/SENDER/ACCOUNT/text()">
            <xsl:apply-templates select="HEADER/SENDER/ACCOUNT" mode="UKaccount"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="CONNUMBER" mode="UKaccount">
              <xsl:with-param name="IsBlank">
                <xsl:text>Y</xsl:text>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
        <div class="row UKimageheight">
          <img src="{$hostName}{$images_dir}/1x1.gif" width="1" height="1"/>
          &#160;
        </div>
        <div class="row UKimageheight">
          <div class="row Line80fixed21">
            <font class="UKheader">FROM (Sender)</font>
          </div>
        </div>
        <xsl:choose>
          <xsl:when test="$returns != 'true'">
            <xsl:choose>
              <xsl:when test="HEADER/COLLECTION/COMPANYNAME/text()">
                <xsl:apply-templates select="HEADER/COLLECTION" mode="UKAddress"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="HEADER/SENDER" mode="UKAddress"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <!-- Reverse the Collection/delivery and Sender/Receiver addresses for a returns consignment -->
            <xsl:choose>
              <xsl:when test="DELIVERY/COMPANYNAME/text()">
                <xsl:apply-templates select="DELIVERY" mode="UKAddress"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="RECEIVER" mode="UKAddress"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <div class="row UKimageheight">
          <img src="{$hostName}{$images_dir}/1x1.gif" width="1" height="1"/>
          &#160;
        </div>
        <xsl:choose>
          <xsl:when test="CUSTOMERREF/text()">
            <xsl:apply-templates select="CUSTOMERREF" mode="UKreference"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="CONNUMBER" mode="UKreference">
              <xsl:with-param name="IsBlank">
                <xsl:text>Y</xsl:text>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
        <div class="row UKimageheight">
          <img src="{$hostName}{$images_dir}/1x1.gif" width="1" height="1"/>
          &#160;
        </div>
        <div class="row UKimageheight">
          <div class="row Line80fixed21">
            <font class="UKheader">TO (Receiver)</font>
          </div>
        </div>
        <xsl:choose>
          <xsl:when test="$returns != 'true'">
            <xsl:choose>
              <xsl:when test="DELIVERY/COMPANYNAME/text()">
                <xsl:apply-templates select="DELIVERY" mode="UKAddress"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="RECEIVER" mode="UKAddress"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="HEADER/COLLECTION/COMPANYNAME/text()">
                <xsl:apply-templates select="HEADER/COLLECTION" mode="UKAddress"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="HEADER/SENDER" mode="UKAddress"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <div class="row UKimageheight">
          <img src="{$hostName}{$images_dir}/1x1.gif" width="1" height="1"/>
          &#160;
        </div>
        <xsl:apply-templates select="CONNUMBER" mode="UKsignature">
          <xsl:with-param name="Sender-Receiver">
            <xsl:text>Sender</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
        <!-- END OF LEFT HAND COLUMN -->
      </div>
      <!-- RIGHT HAND COLUMN -->
      <div class="UKrightside">
        <xsl:apply-templates select="CONNUMBER" mode="UKDomesticConNote"/>
        <div class="row UKimageheight">
          <img src="{$hostName}{$images_dir}/1x1.gif" width="1" height="1"/>
          <br/>
        </div>
        <div class="rowright UKrightrow3height greenbordered centered bottommargin">
          <div class="row Line80fixed21">
            <font class="UKheader">
              UK
              DELIVERY OPTIONS
            </font>
          </div>
        </div>
        <xsl:apply-templates select="." mode="UKservice"/>
        <div class="row UKimageheight">
          <img src="{$hostName}{$images_dir}/1x1.gif" width="1" height="1"/>
          <br/>
        </div>
        <xsl:choose>
          <xsl:when test="UKDOMESTICITLLOPTION">
            <xsl:apply-templates select="UKDOMESTICITLLOPTION" mode="UKitll">
              <xsl:with-param name="HasItll">
                <xsl:text>Y</xsl:text>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="CONNUMBER" mode="UKitll"/>
          </xsl:otherwise>
        </xsl:choose>
        <div class="row UKimageheight">
          <img src="{$hostName}{$images_dir}/1x1.gif" width="1" height="1"/>
          <br/>
        </div>
        <xsl:apply-templates select="." mode="UKdg"/>
        <div class="row UKimageheight">
          <img src="{$hostName}{$images_dir}/1x1.gif" width="1" height="1"/>
          <br/>
        </div>
        <xsl:apply-templates select="PACKAGES" mode="UKDomesticConNote"/>
        <div class="row UKimageheight">
          <img src="{$hostName}{$images_dir}/1x1.gif" width="1" height="1"/>
          <br/>
        </div>
        <div class="rowright UKpdfheight whitebordered bottommargin">
          <img class="center" src="{$hostName}/barbecue/barcode?type=pdf417&amp;data={PDFBARCODEDATA}" width="296"/>
        </div>
        <xsl:apply-templates select="CONNUMBER" mode="UKsignature">
          <xsl:with-param name="Sender-Receiver">
            <xsl:text>Receiver</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
        <!-- END OF RIGHT HAND COLUMN -->
      </div>
      <!-- FOOTER SECTION-->
      <div class="row UKdglineheight whitebordered" style="width: 99.3%;">
        <font class="UKsmallprint">
          ALL
          CONSIGNMENTS ARE CARRIED SUBJECT TO TNT EXPRESS SERVICES CONDITIONS OF
          CARRIAGE, THE PRINCIPAL CONDITIONS ARE SHOWN BELOW.
        </font>
      </div>
    </div>
    <p class=""/>
    <!--  T&C SECTION -->
    <div class="UKtc bordered">
      <div class="row Line80fixed21">
        <font class="UKheader">
          TNT Express Services Principal Conditions
          of Carriage
        </font>
      </div>
      <div class="row UKmultiaddressline">
        <font class="UKdata">
          All goods are carried subject to our Conditions
          of Carriage which are available on request. It is in your interest
          to read them as your rights may be affected.
        </font>
      </div>
      <div class="row UKmultiaddressline">
        <font class="UKdata">
          Under these conditions our liability is limited
          to £15.00 per Kilo up to 1,000 kilos per consignment and is excluded
          in certain circumstances. For European Road Service carriage of
          goods is governed by the Convention on the Contract for the International
          Carriage of Goods by Road 1956 (CMR). Our liability for loss or
          damage to your goods is limited to 8.33 SDR&apos;s per kilo or £15.00
          per kilo whichever is the greater.
        </font>
      </div>
      <div class="row UKmultiaddressline">
        <font class="UKdata">
          We recommend that you arrange sufficient insurance
          cover to protect your interest.We can arrange increased transit
          liability cover on your behalf on request.
        </font>
      </div>
      <div class="row UKmultiaddressline">
        <font class="UKdata">
          We are not responsible for loss to you of any
          profit, loss of customer, or indirect loss of a monetary or consequential
          nature.
        </font>
      </div>
      <div class="row UKmultiaddressline">
        <font class="UKdata">
          Payment for carriage charges is due no later
          than the 15th day of the month following the month of invoice.
        </font>
      </div>
      <div class="row UKmultiaddressline">
        <font class="UKdata">
          Next working days do not include Saturdays
          or public holidays.Our Saturday delivery service is available on
          days which are not public holidays.
        </font>
      </div>
      <div class="row UKmultiaddressline">
        <font class="UKdata">
          PLEASE NOTE THE FOLLOWING INFORMATION
          <ul style="margin-top: 1px;">
            <li>
              Please give the items and the consignment note to the collection
              driver.
            </li>
          </ul>
        </font>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="CONNUMBER" mode="UKheader">
    <xsl:param name="copyfor"/>
    <div class="row UKleftrow1height whitebordered">
      <div class="UKlogo">
        <img src="{$hostName}{$images_dir}\lg_tnt_uk_sml.gif" width="52" height="20"/>
        <div class="row Line80fixed12">
          &#160;
        </div>
        <font class="UKsmallprint">
          <div class="row UKaddressline">
            TNT EXPRESS HOUSE, HOLLY LANE,
          </div>
          <div class="row UKaddressline">
            ATHERSTONE, WARWICKSHIRE CV9 2RY
          </div>
          <div class="row UKaddressline">
            TELEPHONE : 01827 303030
          </div>
        </font>
      </div>
      <div class="row UKcopyfor centered">
        <div class="row Line80fixed21">
          <font class="UKheader">EXPRESS</font>
        </div>
        <div class="row Line80fixed12">
          &#160;
        </div>
        <div class="row Line80fixed12">
          <xsl:choose>
            <xsl:when test="$copyfor = 'C'">
              <font class="UKdata">Customer</font>
            </xsl:when>
            <xsl:otherwise>
              <font class="UKdata">Pricing</font>
            </xsl:otherwise>
          </xsl:choose>
        </div>
        <div class="row Line80fixed12">
          <font class="UKdata">Copy</font>
        </div>
      </div>
      <div class="row UKdiv">
        <div class="row Line80fixed21">
          <font class="UKdata">Div</font>
        </div>
        <div class="row Line80fixed12">
          <font class="UKdataBold">010</font>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="node()" mode="UKaccount">
    <xsl:param name="IsBlank">
      <xsl:text>N</xsl:text>
    </xsl:param>
    <div class="row UKleftrow3height greenbordered">
      <div class="row Line80fixed21">
        <div class="UKacc1">
          <font class="UKheader">SENDER&apos;S ACCOUNT NUMBER</font>
        </div>
        <div class="UKacc2">
          <font class="UKdata">
            <xsl:choose>
              <xsl:when test="$IsBlank='N'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
            </xsl:choose>
          </font>
        </div>
        <div class="UKacc3">
          &#160;
        </div>
      </div>
    </div>

  </xsl:template>

  <xsl:template match="node()" mode="UKreference">
    <xsl:param name="IsBlank">
      <xsl:text>N</xsl:text>
    </xsl:param>
    <div class="row UKleftrow8height greenbordered">
      <div class="row Line80fixed21">
        <font class="UKheader">CUSTOMER REFERENCE</font>
      </div>
      <div class="UKref">
        <div class="row Line80fixed12">
          <font class="UKdata">
            <xsl:choose>
              <xsl:when test="$IsBlank='N'">
                <xsl:value-of select="substring(., 1, 15)"/>
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
            </xsl:choose>
          </font>
        </div>
      </div>
    </div>

  </xsl:template>

  <xsl:template match="node()" mode="UKitll">
    <xsl:param name="HasItll">
      <xsl:text>N</xsl:text>
    </xsl:param>
    <div class="row UKdglineheight whitebordered">
      <div class="Line80fixed21">
        <xsl:choose>
          <xsl:when test="$HasItll='Y'">
            <font class="UKheader">IMPORTANT:</font>
            <font class="UKdata">increased transit liability cover is required</font>
          </xsl:when>
          <xsl:otherwise>
            <font class="UKdata">increased transit liability cover is not required</font>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="CONNUMBER" mode="UKsignature">
    <xsl:param name="Sender-Receiver"/>
    <div>
      <xsl:choose>
        <xsl:when test="$Sender-Receiver = 'Sender'">
          <xsl:attribute name="class">row UKsendersignheight whitebordered bottommargin</xsl:attribute>
        </xsl:when>
        <xsl:when test="$Sender-Receiver = 'Receiver'">
          <xsl:attribute name="class">rowright UKsendersignheight whitebordered bottommargin</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <div class="UKssign1a">
        <div class="Line80fixed21">
          <xsl:choose>
            <xsl:when test="$Sender-Receiver = 'Sender'">
              <font class="UKheader">SENDER&apos;S SIGNATURE</font>
            </xsl:when>
            <xsl:when test="$Sender-Receiver = 'Receiver'">
              <font class="UKheader">RECEIVED BY TNT</font>
            </xsl:when>
          </xsl:choose>
        </div>
      </div>
      <div class="UKssign1b">
        <font class="UKheader">(Please Print)</font>
      </div>
      <div class="row UKssign2height">
        &#160;
      </div>
      <div class="row UKssign3height">
        <font class="UKheader">Date</font>
        <font class="UKsmallPrint">&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;/&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;</font>
        <font class="UKsmallprint">(Day/Month/Year)</font>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="CONNUMBER" mode="UKDomesticConNote">
    <div class="UKrightrow1height UKrightrow1column1 whitebordered">
      <font class="UKheader">
        <div class="row Line80fixed21">
          &#160;
        </div>
        <div class="row Line80fixed21 centered">
          CONSIGNMENT NOTE NUMBER
        </div>
        <img class="center" src="{$hostName}/barbecue/barcode?data={.}&amp;type=Code128&amp;height=70" width="160"/>
        <div class="row Line80fixed21 centered">
          <xsl:value-of select="."/>
        </div>
      </font>
    </div>
    <div class="UKrightrow1height UKrightrow1column2 whitebordered centered">
      <img src="{$hostName}{$images_dir}/lg_tnt_uk_sml.gif" width="52" height="20"/>
      <div class="row UKaddressline">
        <font class="UKsmallprint">
          BOOK COLLECTIONS
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKsmallprint">
          ONLINE
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKsmallprint">
          www.tnt.co.uk<br class=""/>
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKsmallprint">
          OR CALL CUSTOMER
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKsmallprint">
          SERVICES ON
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKsmallprint">
          0800 100 600
        </font>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="CONSIGNMENT" mode="UKservice">
    <div class="rowright UKserviceheight whitebordered">
      <div class="row Line80fixed21">
        <xsl:choose>
          <xsl:when test="HEADER/CARRIAGEFORWARD='Y'">
            <font class="UKheader">Service (Carriage Forward) : &#160;</font>
          </xsl:when>
          <xsl:otherwise>
            <font class="UKheader">Service : &#160;</font>
          </xsl:otherwise>
        </xsl:choose>
        <font class="UKdata">
          <xsl:value-of select="SERVICE"/>
        </font>
      </div>
      <xsl:if test="OPTION1/text()">
        <div class="row Line80fixed12">
          <font class="UKdata">
            <xsl:value-of select="OPTION1"/>
          </font>
        </div>
      </xsl:if>
      <xsl:if test="OPTION2/text()">
        <div class="row Line80fixed12">
          <font class="UKdata">
            <xsl:value-of select="OPTION2"/>
          </font>
        </div>
      </xsl:if>
      <xsl:if test="OPTION3/text()">
        <div class="row Line80fixed12">
          <font class="UKdata">
            <xsl:value-of select="OPTION3"/>
          </font>
        </div>
      </xsl:if>
      <xsl:if test="OPTION4/text()">
        <div class="row Line80fixed12">
          <font class="UKdata">
            <xsl:value-of select="OPTION4"/>
          </font>
        </div>
      </xsl:if>
      <xsl:if test="../Header/DangerousGoodsOption/Code/text()">
        <div class="row Line80fixed12">
          <font class="UKdata">
            <xsl:value-of select="../Header/DangerousGoodsOption/Code"/>&#160;
            <xsl:value-of select="../Header/DangerousGoodsOption/Name"/>
          </font>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="CONSIGNMENT" mode="UKdg">
    <div class="rowright instructionsheight whitebordered">
      <div class="row UKdglineheight">
        <div class="Line80fixed21">
          <font class="UKdata">
            DOES THE CONSIGNMENT CONTAIN <font class="UKheader">DANGEROUS GOODS?</font>
          </font>
        </div>
      </div>
      <div class="row UKdglineheight">
        <div class="Line80fixed21">
          <div class="UKdgimg">
            <xsl:choose>
              <xsl:when test="DANGEROUSGOODS = 'Y'">
                &#160;<img src="{$hostName}{$images_dir}/uk_domestic_dangerous_goods_off.gif" width="14" height="13"/>
                <font class="UKdata">&#160;NO&#160;</font>
                <img src="{$hostName}{$images_dir}/uk_domestic_dangerous_goods_on.gif" width="14" height="13"/>
                <font class="UKdata">&#160;YES</font>
              </xsl:when>
              <xsl:otherwise>
                &#160;<img src="{$hostName}{$images_dir}/uk_domestic_dangerous_goods_on.gif" width="14" height="13"/>
                <font class="UKdata">&#160;NO&#160;</font>
                <img src="{$hostName}{$images_dir}/uk_domestic_dangerous_goods_off.gif" width="14" height="13"/>
                <font class="UKdata">&#160;YES</font>
              </xsl:otherwise>
            </xsl:choose>
          </div>
          <div class="UKdgun">
            <font class="UKdata">UN NUMBER : &#160;</font>
            <font class="UKdata">
              <xsl:value-of select="UNNUMBER"/>
            </font>
          </div>
        </div>
      </div>
      <div class="row UKdglineheight centered">
        <div class="Line80fixed21">
          <font class="UKdata">DANGEROUS GOODS DELIVERIES ARE NOT GUARANTEED</font>
        </div>
      </div>
    </div>

  </xsl:template>

  <xsl:template match="CONSIGNMENT" mode="UKblankRow">
    <div class="row UKdglineheight borderedrowgrey">
      <div class="UKgoodscol1 borderedcolumn">
        &#160;
      </div>
      <div class="UKgoodscol2 borderedcolumn">
        &#160;
      </div>
      <div class="UKgoodscol2 borderedcolumn">
        &#160;
      </div>
      <div class="UKgoodscol2 borderedcolumn">
        &#160;
      </div>
      <div class="UKgoodscol2 borderedcolumn">
        &#160;
      </div>
      <div class="UKgoodscol2 borderedcolumn">
        &#160;
      </div>
    </div>
  </xsl:template>

  <xsl:template match="PACKAGES" mode="UKDomesticConNote">
    <div class="rowright UKgoods whitebordered">
      <div class ="row UKdglineheight">
        <div class="UKgoodscol1 borderedcolumn">
          <div class="Line80fixed21">
            <font class="UKheader">Goods Description</font>
          </div>
        </div>
        <div class="UKgoodscol2 borderedcolumn centered">
          <div class="Line80fixed21">
            <font class="UKheader">Number</font>
          </div>
        </div>
        <div class="UKgoodscol2 borderedcolumn centered">
          <div class="Line80fixed21">
            <font class="UKheader">Weight</font>
          </div>
        </div>
        <div class="UKgoodscolr borderedcolumn borderedinternalrowgrey centered">
          <div class="Line80fixed21">
            <font class="UKheader">Dimensions (cms)</font>
          </div>
        </div>
      </div>
      <div class ="row UKdglineheight">
        <div class="UKgoodscol1 borderedcolumn">
          &#160;
        </div>
        <div class="UKgoodscol2 borderedcolumn centered">
          <div class="Line80fixed21">
            <font class="UKheader">of items</font>
          </div>
        </div>
        <div class="UKgoodscol2 borderedcolumn centered">
          <div class="Line80fixed21">
            <font class="UKheader">Kilos</font>
          </div>
        </div>
        <div class="UKgoodscol2 borderedcolumn centered">
          <div class="Line80fixed21">
            <font class="UKheader">Length</font>
          </div>
        </div>
        <div class="UKgoodscol2 borderedcolumn centered">
          <div class="Line80fixed21">
            <font class="UKheader">Width</font>
          </div>
        </div>
        <div class="UKgoodscol2 borderedcolumn centered">
          <div class="Line80fixed21">
            <font class="UKheader">Height</font>
          </div>
        </div>
      </div>
      <xsl:apply-templates select="PACKAGE" mode="UKPackage"/>
      <xsl:choose>
        <xsl:when test="count(PACKAGE) = 1">
          <xsl:apply-templates select="../." mode="UKblankRow"/>
          <xsl:apply-templates select="../." mode="UKblankRow"/>
        </xsl:when>
        <xsl:when test="count(PACKAGE) = 2">
          <xsl:apply-templates select="../." mode="UKblankRow"/>
        </xsl:when>
      </xsl:choose>
      <div class="row UKgoodstotalheight borderedrowgrey">
        <div class="UKgoodscol1 borderedcolumn">
          <div class="Line80fixed21">
            <font class="UKheader">
              Total number of items and weight
            </font>
          </div>
        </div>
        <div class="UKgoodscol2 borderedcolumn centered">
          <div class="Line80fixed21">
            <font class="UKdata">
              <xsl:value-of select="../TOTALITEMS"/>
            </font>
          </div>
        </div>
        <div class="UKgoodscol2 borderedcolumn centered">
          <div class="Line80fixed21">
            <font class="UKdata">
              <xsl:value-of select="../TOTALWEIGHT"/>
            </font>
          </div>
        </div>
        <div class="UKgoodscolr borderedcolumn centered">
          <div class="Line80fixed12">
            <font class="UKdata" size="-2">
              &#160;
            </font>
          </div>
          <div class="Line80fixed12">
            <font class="UKdata" size="-2">
              Consignment subject
            </font>
          </div>
          <div class="Line80fixed12">
            <font class="UKdata" size="-2">
              to volumetric
            </font>
          </div>
          <div class="Line80fixed12">
            <font class="UKdata" size="-2">
              measurement
            </font>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="SENDER | RECEIVER | COLLECTION | DELIVERY" mode="UKAddress">
    <div class="row UKaddress whitebordered">
      <div class="row UKaddressline">
        <font class="UKdata">
          <xsl:value-of select="COMPANYNAME"/>
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKdata">
          <xsl:value-of select="STREETADDRESS1"/>
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKdata">
          <xsl:choose>
            <xsl:when test="STREETADDRESS2/text()">
              <xsl:value-of select="STREETADDRESS2"/>
            </xsl:when>
            <xsl:otherwise>
              <br/>
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKdata">
          <xsl:choose>
            <xsl:when test="STREETADDRESS3/text()">
              <xsl:value-of select="STREETADDRESS3"/>
            </xsl:when>
            <xsl:otherwise>
              <br/>
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKdata">
          <xsl:value-of select="CITY"/>
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKdata">
          <xsl:choose>
            <xsl:when test="PROVINCE/text()">
              <xsl:value-of select="PROVINCE"/>
            </xsl:when>
            <xsl:otherwise>
              <br/>
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKdata">
          <xsl:choose>
            <xsl:when test="POSTCODE/text()">
              <xsl:value-of select="POSTCODE"/>
            </xsl:when>
            <xsl:otherwise>
              <br/>
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKdata">
          <xsl:value-of select="COUNTRY"/>
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKheader">CONTACT NAME : </font>&#160;
        <font class="UKdata">
          <xsl:value-of select="CONTACTNAME"/>
          <br/>
        </font>
      </div>
      <div class="row UKaddressline">
        <font class="UKheader">TEL NO : </font>&#160;
        <font class="UKdata">
          <xsl:value-of select="CONTACTDIALCODE"/>&#160;
          <xsl:value-of select="CONTACTTELEPHONE"/>
        </font>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="PACKAGE" mode="UKPackage">
    <div class="row UKdglineheight borderedrowgrey">
      <div class="UKgoodscol1 borderedcolumn">
        <font class="UKdata">
          <xsl:value-of select="GOODSDESC"/>
        </font>
      </div>
      <div class="UKgoodscol2 borderedcolumn centered">
        <font class="UKdata">
          <xsl:value-of select="ITEMS"/>
        </font>
      </div>
      <div class="UKgoodscol2 borderedcolumn centered">
        <font class="UKdata">
          <xsl:value-of select="WEIGHT"/>
        </font>
      </div>
      <div class="UKgoodscol2 borderedcolumn centered">
        <font class="UKdata">
          <xsl:value-of select="LENGTH"/>
        </font>
      </div>
      <div class="UKgoodscol2 borderedcolumn centered">
        <font class="UKdata">
          <xsl:value-of select="WIDTH"/>
        </font>
      </div>
      <div class="UKgoodscol2 borderedcolumn centered">
        <font class="UKdata">
          <xsl:value-of select="HEIGHT"/>
        </font>
      </div>
    </div>
  </xsl:template>
</xsl:stylesheet>
