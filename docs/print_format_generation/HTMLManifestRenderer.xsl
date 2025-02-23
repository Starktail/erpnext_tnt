<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:lookup="lookup" exclude-result-prefixes="lookup">
  <!-- Version 3.0.1  22-12-2017 11:10 Draft version for Infosys -->
  <!-- Version 3.0.2  22-12-2017 11:35 InvoiceDescription section corrected -->
  <!-- Version 3.0.3  03-01-2017 11:07 Simple Dangerous Goods improvements and Options presentation -->
  <!-- Version 3.0.4  03-01-2018 13:19 Simple Dangerous Goods logic minor correction -->
  <!-- Version 3.1.0  06-03-2018 13:02 Split into CTS version and server version. Going to DIV technology. This is server version -->
  <!-- Version 3.1.1  08-03-2018 09:49 Removal of term country. Server version -->
  <!-- Version 3.1.2  13-03-2018 11:03 Corrections to fix browser compatibility. Server version -->
  <!-- Version 3.1.3  13-05-2018 15:37 UK Manifest updated to fix issues. Server version -->
  <!-- Version 3.2.0  18-05-2018 15:14 Styles reviewed and simplified to ensure correct rendering in both IE and Firefox. Server version -->
  <!-- Version 3.2.1  16-10-2018 11:52 Styles reviewed and simplified to ensure correct rendering in both IE and Firefox. Server version -->
  <!-- Version 3.2.2  14-01-2019 15:36 Fixing delivery address issue. Server version -->
  <!-- Version 3.2.3  05-04-2019 15:17 Fixing image centering issue by Fernand Alves. Server version -->

  <!-- Parameter used in CTS version 
  <xsl:param name="code39Barcode_url" select="/CONSIGNMENTBATCH/BARCODEURL" />
  <xsl:param name="hostName" select="/CONSIGNMENTBATCH/HOST" />
  <xsl:param name="images_dir" select="/CONSIGNMENTBATCH/IMAGESDIR" />
  -->

  <xsl:param name="code39Barcode_url" select="/CONSIGNMENTBATCH/BARCODEURL" />
  <xsl:param name="hostName" select="/CONSIGNMENTBATCH/HOST" />
  <xsl:param name="images_dir" select="/CONSIGNMENTBATCH/IMAGESDIR" />

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
        <title>TNT Manifest</title>
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
              width: 604px;
              min-height: 794px;
              overflow: hidden;
          }

          .headerborder {
              width: 99%;
              display: table;
              border-collapse: collapse;
              border: 2px solid #000000;
          }
          
          .headerborder + .headerborder {
              border-top: 0px;
          }
          
          .headercolumn1 {
              width: 25%;
              float: left;
              padding-left: 2px;
          }

          .headercolumn2 {
              width: 2%;
              float: left;
          }

          .headercolumn3 {
              width: 72%;
              float: right;
              padding-right: 2px;
          }

          .printdaterow {
              float: right;
              text-align: right;
              padding-right: 10px;
          }

          .row {
              width: 100%;
              float: left;
         }

          .centered {
              text-align: center;
          }

          .Line80 {
              line-height: 80%;
              padding-top: 2px;
          }

          .Line6 {
              height: 6px;
          }

          .Line20 {
              line-height: 40%;
              padding: 2px;
          }

          .Line80fixed13 {
              height: 13px;
              line-height: 80%;
          }

          .Line80fixed15 {
              height: 15px;
              line-height: 80%;
          }

          .Line160 {
              line-height: 160%;
              padding-top: 2px;
          }

          .Line100 {
              line-height: 100%;
              padding-top: 2px;
          }
          
          .detail {
              min-height: 94px;
          }

          .barcode {
              width: 41%;
              float: left;
          }

          .specinstructions {
              width: 29%;
              float: left;
          }

          .dgsection {
              width: 29%;
              float: left;
          }

          .servicescolumn1 {
              width: 10%;
              float: left;
          }

          .servicescolumn2 {
              width: 90%;
              float: left;
          }

          .totalscolumn1 {
              width: 17%;
              float: left;
          }

          .totalscolumn2 {
              width: 21%;
              float: left;
          }

          .totalscolumn3 {
              width: 29%;
              float: left;
          }

          .totalscolumn4 {
              width: 33%;
              float: left;
          }

          .addresscolumn1 {
              width: 17%;
              float: left;
          }

          .addresscolumn2 {
              width: 83%;
              float: left;
          }

          .contactcolumn1 {
              width: 17%;
              float: left;
          }

          .contactcolumn2 {
              width: 40%;
              float: left;
          }

          .contactcolumn3 {
              width: 42%;
              float: left;
          }
          
          .rowpart {
              float: left;
          }

          .packages {
              min-height: 57px;
          }

          .packagescolumn1 {
              width: 39%;
              overflow: hidden;
              float: left;
          }

          .packagescolumn2 {
              width: 25%;
              float: left;
          }

          .packagescolumn3 {
              width: 36%;
              float: left;
          }

          .hr {
              width: 100%;
              height: 3px;
              border-bottom: 3px solid #C0C0C0;
              margin-bottom: 2px;
          }

          .separator {
              width: 100%;
              height: 20px;
              float: left;
          }

          .signcolumn1 {
              width: 62%;
              float: left;
          }

          .signcolumn2 {
              width: 37%;
              float: left;
          }

          .UK {
              border-spacing: 3px;
          }

          .padded3 {
              padding: 3px;
          }

          .title {
              width: 370px;
              margin: 0 auto;
              overflow: hidden;
          }


          .UKheaderrow1column1 {
              width: 44%;
              float: left;
          }

          .UKheaderrow1column2 {
              width: 51%;
              float: left;
              text-align: right;
          }

          .UKheaderrow2column1 {
              width: 37%;
              float: left;
          }

          .UKheadercolumn3 {
              width: 20%;
              float: left;
          }

          .padded5 {
              padding: 5px;
          }

          .rowbordered {
              float: left;
              border-spacing: 0px;
              padding: 0px;
              width: 99%;
              border: 2px solid #656566;
          }

          .rowbordered + .rowbordered {
              border-top: 0px solid #656566;
          }

          .internalrowbordered {
              border-spacing: 0px;
              padding: 0px;
              border-bottom: 2px solid #656566;
              overflow: hidden;
          }

          .internalrowbordered:last-child {
              border-bottom: 0px;
          }

          .columnbordered {
              border-spacing: 0px;
              padding: 0px;
              border-right: 2px solid #656566;
          }

          .columnbordered:last-child {
              border-right: 0px;
          }

          .UKcolumn1 {
              float: left;
              width: 325px;
          }

          .UKcolumn2 {
              float: left;
              width: 126px;
          }

          .UKcolumn3 {
              float: left;
              width: 84px;
          }

          .UKcolumn2a {
              float: left;
              width: 65px;
          }

          .UKcolumn3a {
              float: left;
              width: 145px;
          }

          .UKcolumn1b {
              float: left;
              width: 428px;
          }

          .UKcolumn2b {
              float: left;
              width: 167px;
          }

          .UKcolumn3b {
              float: left;
              width: 542px;
          }

          .UKcolumn4 {
              float: left;
              width: 53px;
          }

          .UKbarcodeheight {
              min-height: 93px;
          }

          .UKcontactheight {
              min-height: 40px;
          }

          .UKcontactcolumn1 {
              width: 39%;
              float: left;
          }

          .UKcontactcolumn2 {
              width: 59%;
              float: left;
          }

          .UKrowheight {
              height: 20px;
          }

          .UKserviceheight {
              min-height: 206px;
          }

          img {
              display: inline-block;
              margin: auto;
          }

          img.center {
              margin-top: 9px;
          }

          img.barcodecenter {
              margin-top: 8px;
          }          
          
          font {
              color: black;
          }

          .bold {
              font-weight: bold;
          }

          font.newtitle {
              font-weight: bold;
              font-family: arial, helvetica, "sans-serif";
              font-size: 9pt;
              text-decoration: underline;
          }

          font.newdata {
              font-family: arial, helvetica, "sans-serif";
              font-size: 8pt;
          }

          font.newheader {
              font-weight: bold;
              font-family: arial, helvetica, "sans-serif";
              font-size: 8pt;
          }

          font.carrierTerms {
              font-family: arial, helvetica "sans-serif";
              font-size: 5pt;
          }

          font.newbarcode {
              font-weight: bold;
              font-family: arial, "sans-serif";
              font-size: 8pt;
              letter-spacing: 0.1cm;
          }
          ]]>
        </style>
      </head>
      <body>
        <!-- Loop through each consignment -->
        <xsl:apply-templates select="/CONSIGNMENTBATCH/CONSIGNMENT" mode="loop"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="CONSIGNMENT" mode="loop">
    <xsl:choose>
      <xsl:when test="@marketType='DOMESTIC'">
        <xsl:choose>
          <xsl:when test="@originCountry='GB'">
            <xsl:apply-templates select="." mode="ukDomesticManifest" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="." mode="defaultManifest" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- Prepared for future enhancements (using a copies attribute) -->
        <xsl:choose>
          <xsl:when test="CONSIGNMENTBATCH/CONSIGNMENT/@copies">
            <xsl:apply-templates select="." mode="internationalManifest">
              <xsl:with-param name="Copies" select="/CONSIGNMENTBATCH/CONSIGNMENT/@copies" />
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="." mode="internationalManifest">
              <xsl:with-param name="Copies" select="'1'" />
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="CONSIGNMENT" mode="ukDomesticManifest">
    <script type="text/Javascript">includePageBreak();</script>

    <div class="body UK">
      <xsl:apply-templates select="HEADER/SENDER" mode="UKAddress">
        <xsl:with-param name="ShippingDate" select="HEADER/SHIPMENTDATE"/>
      </xsl:apply-templates>
      <div class="rowbordered">
        <div class="UKcolumn1 columnbordered">
          <xsl:apply-templates select="CONNUMBER" mode="ukDomesticManifest"/>
          <xsl:apply-templates select="CONNUMBER" mode="UKheading">
            <xsl:with-param name="HeightClass">
              <xsl:text>UKcontactheight</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="Heading">
              <xsl:text>Sender Contact : </xsl:text>
            </xsl:with-param>
          </xsl:apply-templates>
          <xsl:apply-templates select="CONNUMBER" mode="UKheading">
            <xsl:with-param name="Heading">
              <xsl:text>Sender Ref : </xsl:text>
            </xsl:with-param>
          </xsl:apply-templates>
          <xsl:apply-templates select="CONNUMBER" mode="UKheading">
            <xsl:with-param name="Heading">
              <xsl:text>Receiver's VAT No : </xsl:text>
            </xsl:with-param>
          </xsl:apply-templates>
        </div>
        <div class="UKcolumn2 columnbordered">
          <xsl:choose>
            <xsl:when test="DELIVERYINST/text()">
              <xsl:apply-templates select="DELIVERYINST" mode="ukDomesticManifest"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="HEADER/SENDER/COMPANYNAME" mode="ukDomesticManifest"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="HEADER/SENDER" mode="UKContact"/>
          <xsl:choose>
            <xsl:when test="CUSTOMERREF/text()">
              <xsl:apply-templates select="CUSTOMERREF" mode="UKcontent"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="HEADER/SENDER/COMPANYNAME" mode="UKcontent">
                <xsl:with-param name="DontUse">
                  <xsl:text>Y</xsl:text>
                </xsl:with-param>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="RECEIVER/VAT/text()">
              <xsl:apply-templates select="RECEIVER/VAT" mode="UKcontent"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="HEADER/SENDER/COMPANYNAME" mode="UKcontent">
                <xsl:with-param name="DontUse">
                  <xsl:text>Y</xsl:text>
                </xsl:with-param>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </div>
        <xsl:apply-templates select="SERVICE" mode="ukDomesticManifest">
          <xsl:with-param name="PaymentInd">
            <xsl:value-of select="PAYMENTIND"/>
          </xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="CONNUMBER" mode="UKverify">
          <xsl:with-param name="Heading">
            <xsl:text>Ops Verify</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
      </div>
      <div class="rowbordered">
        <xsl:apply-templates select="." mode="UKtandc"/>
        <xsl:apply-templates select="RECEIVER" mode="UKAddress"/>
        <xsl:apply-templates select="." mode="UKoption"/>
        <xsl:apply-templates select="TOTALWEIGHT" mode="UKverify">
          <xsl:with-param name="Heading">
            <xsl:text>Weight</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
      </div>
      <div class="rowbordered">
        <div class="UKcolumn3b columnbordered">
          <div class="row internalrowbordered">
            <xsl:apply-templates select="PACKAGES" mode="ukTotalItems"/>
            <xsl:apply-templates select="PACKAGES" mode="ukTotalWeight"/>
            <xsl:apply-templates select="PACKAGES" mode="ukDomesticManifest"/>
          </div>
          <div class="row internalrowbordered">
            <xsl:choose>
              <xsl:when test="INSURANCEVALUE/text()">
                <xsl:apply-templates select="CONNUMBER" mode="ukInsurance">
                  <xsl:with-param name="Amount" select="INSURANCEVALUE"/>
                  <xsl:with-param name="Currency" select="CURRENCY"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="CONNUMBER" mode="ukInsurance"/>
              </xsl:otherwise>
            </xsl:choose>
          </div>
          <div class="row internalrowbordered">
            <xsl:apply-templates select="PACKAGES" mode="ukGoods"/>
          </div>
        </div>
        <xsl:apply-templates select="TOTALVOLUME" mode="UKverify">
          <xsl:with-param name="Heading">
            <xsl:text>Volume</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
      </div>
      <div class="rowbordered">
        <div class="UKcolumn1b columnbordered">
          <xsl:apply-templates select="CONNUMBER" mode="UKheading">
            <xsl:with-param name="HeightClass">
              <xsl:text>UKcontactheight</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="Heading">
              <xsl:text>&#160;</xsl:text>
            </xsl:with-param>
          </xsl:apply-templates>
        </div>
        <xsl:apply-templates select="TOTALVOLUME" mode="ukDomesticManifest"/>
      </div>
    </div>
  </xsl:template>

  <!-- Template for UK weight section -->
  <xsl:template match="PACKAGES" mode="ukTotalWeight">
    <div class="UKcolumn2a columnbordered">
      <div class="Line80fixed13 padded5">
        <font class="newheader">Weight : </font>
      </div>
      <div class="Line80fixed13 padded3">
        <font class="newdata">
          <xsl:value-of select="concat(format-number(../TOTALWEIGHT, '####0.000'), ' ', ../TOTALWEIGHT/@units)" />
        </font>
      </div>
      <xsl:apply-templates select="PACKAGE[position() > 1]" mode="ukBlankLine"/>
    </div>
  </xsl:template>

  <!-- Template for UK items section -->
  <xsl:template match="PACKAGES" mode="ukTotalItems">
    <div class="UKcolumn1 columnbordered">
      <div class="Line80fixed13 padded5">
        <font class="newheader">Items : &#160;</font>
        <font class="newdata">
          <xsl:value-of select="../TOTALITEMS" />
        </font>
      </div>
      <xsl:apply-templates select="PACKAGE" mode="ukBlankLine"/>
    </div>
  </xsl:template>

  <!-- Template for UK Packages dimensions section -->
  <xsl:template match="PACKAGES" mode="ukDomesticManifest">
    <div class="UKcolumn3a columnbordered">
      <div class="Line80fixed13 padded5">
        <font class="newheader">Dimensions (HxWxD)</font>
      </div>
      <xsl:apply-templates select="PACKAGE" mode="ukDomesticManifest"/>
    </div>
  </xsl:template>

  <!-- Template for UK Package dimensions subsection -->
  <xsl:template match="PACKAGE" mode="ukDomesticManifest">
    <div class="Line80fixed13 padded3">
      <font class="newdata">
        <xsl:value-of select="HEIGHT" />
        &#160;x&#160;
        <xsl:value-of select="LENGTH" />
        &#160;x&#160;
        <xsl:value-of select="WIDTH" />
      </font>
    </div>
  </xsl:template>

  <!-- Template for UK Goods description section -->
  <xsl:template match="PACKAGES" mode="ukGoods">
    <div class="UKcolumn3a columnbordered">
      <div class="Line80fixed13 padded5">
        <font class="newheader">Goods Description : </font>
      </div>
      <xsl:apply-templates select="PACKAGE" mode="ukDomesticManifest"/>
    </div>
  </xsl:template>

  <!-- Template for UK Goods description subsection -->
  <xsl:template match="PACKAGE" mode="ukGoods">
    <div class="Line80fixed13 padded3">
      <font class="newdata">
        <xsl:value-of select="PACKAGECODE" />
      </font>
    </div>
  </xsl:template>

  <!-- Template for UK Package blank line subsection -->
  <xsl:template match="PACKAGE" mode="ukBlankLine">
    <div class="Line80fixed13 padded3">
      <font class="newdata">
        &#160;
      </font>
    </div>
  </xsl:template>

  <!-- Template for matching UK Insurance section -->
  <xsl:template match="node()" mode="ukInsurance">
    <xsl:param name="Amount" select="0"/>
    <xsl:param name="Currency"/>
    <div class="Line80 UKrowheight padded5">
      <font class="newheader">Insurance Value : &#160;</font>
      <font class="newdata">
        <xsl:choose>
          <xsl:when test="$Amount > 0">
            <xsl:value-of select="concat(format-number($Amount, '####0.00'), ' ', $Currency)"/>
          </xsl:when>
          <xsl:otherwise>
            &#160;
          </xsl:otherwise>
        </xsl:choose>
      </font>
    </div>
  </xsl:template>

  <!-- Template for UK Options section -->
  <xsl:template match="CONSIGNMENT" mode="UKoption">
    <div class="UKcolumn3 columnbordered">
      <div class="Line80 UKserviceheight padded5">
        <font class="newheader">Options : </font>
        <font class="newdata">
          <xsl:if test="OPTION1/text()">
            <br class="" />
            <xsl:value-of select="OPTION1" />
          </xsl:if>
          <xsl:if test="OPTION2/text()">
            <br class="" />
            <xsl:value-of select="OPTION2" />
          </xsl:if>
          <xsl:if test="OPTION3/text()">
            <br class="" />
            <xsl:value-of select="OPTION3" />
          </xsl:if>
          <xsl:if test="OPTION4/text()">
            <br class="" />
            <xsl:value-of select="OPTION4" />
          </xsl:if>
          <xsl:if test="OPTION5/text()">
            <br class="" />
            <xsl:value-of select="OPTION5" />
          </xsl:if>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for matching UK Receiver section -->
  <xsl:template match="RECEIVER" mode="UKAddress">
    <div class="UKcolumn2 UKserviceheight padded5 columnbordered ">
      <div class="Line80fixed15 padded3">
        <font class="newdata">
          <xsl:value-of select="COMPANYNAME" />
        </font>
      </div>
      <div class="Line80fixed15 padded3">
        <font class="newdata">
          <xsl:value-of select="STREETADDRESS1" />
        </font>
      </div>
      <div class="Line80fixed15 padded3">
        <font class="newdata">
          <xsl:if test="STREETADDRESS2/text()">
            <xsl:value-of select="STREETADDRESS2" />
          </xsl:if>
        </font>
      </div>
      <div class="Line80fixed15 padded3">
        <font class="newdata">
          <xsl:if test="STREETADDRESS3/text()">
            <xsl:value-of select="STREETADDRESS3" />
          </xsl:if>
        </font>
      </div>
      <div class="Line80fixed15 padded3">
        <font class="newdata">
          <xsl:value-of select="CITY" />
        </font>
      </div>
      <div class="Line80fixed15 padded3">
        <font class="newdata">
          <xsl:if test="PROVINCE/text()">
            <xsl:value-of select="PROVINCE" />
          </xsl:if>
        </font>
      </div>
      <div class="Line80fixed15 padded3">
        <font class="newdata">
          <xsl:if test="POSTCODE/text()">
            <xsl:value-of select="POSTCODE" />
          </xsl:if>
        </font>
      </div>
      <div class="Line80fixed15 padded3">
        <font class="newdata">
          <xsl:value-of select="COUNTRY" />
        </font>
      </div>
      <div class="Line80fixed15 padded3">
        <font class="newheader">Receiver Contact : </font>
      </div>
      <div class="Line80fixed15 padded3">
        <font class="newdata">
          <xsl:value-of select="CONTACTNAME" />
        </font>
      </div>
      <div class="Line6">
        &#160;
      </div>
    </div>
  </xsl:template>

  <!-- Template for UK Terms & Conditions -->
  <xsl:template match="CONSIGNMENT" mode="UKtandc">
    <div class="UKcolumn1 columnbordered">
      <div class="Line80 UKserviceheight padded5">
        <font class="newheader">
          Receiver Name &amp; Address
          <br class="" />
          <br class="" />
          <div class="Line160">
            THE SENDER AGREES THAT THE GENERAL CONDITIONS, ACCESSIBLE VIA THE HELP TEXT, ARE ACCEPTABLE AND GOVERN THIS CONTRACT. IF NO SERVICE OR BILLING OPTION IS SELECTED THE FASTEST AVAILABLE SERVICE WILL BE CHARGED TO THE SENDER.
          </div>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for creating UK heading section -->
  <xsl:template match="node()" mode="UKheading">
    <xsl:param name="Heading"/>
    <xsl:param name="HeightClass">UKrowheight</xsl:param>
    <div class="internalrowbordered">
      <div>
        <xsl:attribute name="class">
          <xsl:value-of select="concat('Line80', ' ',$HeightClass, ' ', 'padded5')"/>
        </xsl:attribute>
        <font class="newheader">
          <xsl:value-of select="$Heading"/>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for creating UK Volume section -->
  <xsl:template match="TOTALVOLUME" mode="ukDomesticManifest">
    <div class="UKcolumn2b columnbordered">
      <div class="Line80fixed13 padded5">
        <font class="newheader">
          <font class="newheader">Total Consignment Volume : </font>
        </font>
      </div>
      <div class="Line80fixed13 padded3">
        <font class="newdata">
          <xsl:value-of select="concat(format-number(., '####0.000'), ' ', substring-before(./@units, '3'))" />
          <font size="1">
            <sup>
              <xsl:value-of select="substring-after(./@units, 'm')"/>
            </sup>
          </font>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for creating UK OPS verification section -->
  <xsl:template match="node()" mode="UKverify">
    <xsl:param name="Heading"/>
    <div class="UKcolumn4 columnbordered">
      <div class="Line80 padded5">
        <font class="newheader">
          <xsl:value-of select="$Heading"/>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for creating UK heading section -->
  <xsl:template match="node()" mode="UKcontent">
    <xsl:param name="DontUse">N</xsl:param>
    <xsl:param name="HeightClass">UKrowheight</xsl:param>
    <div class="internalrowbordered">
      <div>
        <xsl:attribute name="class">
          <xsl:value-of select="concat($HeightClass, ' ', 'padded5')"/>
        </xsl:attribute>
        <font class="newdata">
          <xsl:choose>
            <xsl:when test="$DontUse = 'Y'">
              &#160;
            </xsl:when>
            <xsl:when test="./text()">
              <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
              &#160;
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for creating UK service section -->
  <xsl:template match="SERVICE" mode="ukDomesticManifest">
    <xsl:param name="PaymentInd"/>
    <div class="UKcolumn3 columnbordered">
      <div class="internalrowbordered">
        <div class ="Line80 UKserviceheight padded5">
          <font class="newheader">Services : </font>
          <br class="" />
          <font class="newdata">
            <xsl:value-of select="." />
          </font>
          <br class="" />
          <br class="" />
          <font class="newheader">
            <xsl:choose>
              <xsl:when test="PAYMENTIND='R'">RECEIVER</xsl:when>
              <xsl:otherwise>SENDER</xsl:otherwise>
            </xsl:choose>
            PAYS
          </font>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Template for creating UK barcode section -->
  <xsl:template match="CONNUMBER" mode="ukDomesticManifest">
    <div class="internalrowbordered">
      <div class ="Line80 UKbarcodeheight padded5 centered">
        <br class="" />
        <img src="{$hostName}/barbecue/barcode?data={.}&amp;type=Code128&amp;height=70" width="160" />
        <br class="" />
        <font class="newheader">
          <xsl:value-of select="." />
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for creating UK special instructions section -->
  <xsl:template match="DELIVERYINST | COMPANYNAME" mode="ukDomesticManifest">
    <div class="internalrowbordered">
      <div class ="Line80 UKbarcodeheight padded5">
        <font class="newheader">Special Instructions : </font>
        <br class="" />
        <font class="newdata">
          <xsl:if test="./text()">
            <xsl:value-of select="substring(.,1,25)" />
          </xsl:if>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for matching UK sender contact details -->
  <xsl:template match="SENDER" mode="UKContact">
    <div class="internalrowbordered">
      <div class="UKcontactcolumn1 columnbordered">
        <div class ="Line80 UKcontactheight padded5">
          <font class="newdata">
            <xsl:value-of select="CONTACTNAME" />
          </font>
        </div>
      </div>
      <div class="UKcontactcolumn2 columnbordered">
        <div class="Line80 UKcontactheight padded5">
          <font class="newheader">Tel : </font>
          <font class="newdata">
            <xsl:if test="CONTACTDIALCODE/text()">
              <xsl:value-of select="CONTACTDIALCODE" />
              <br/>
            </xsl:if>
            <xsl:if test="CONTACTTELEPHONE/text()">
              <xsl:value-of select="CONTACTTELEPHONE" />
            </xsl:if>
          </font>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Template for matching UK Sender building whole header section -->
  <xsl:template match="SENDER" mode="UKAddress">
    <xsl:param name="ShippingDate"/>

    <div class="title centered padded3">
      <font class="bold" size="+1">COLLECTION MANIFEST</font>
    </div>
    <div class="title padded3">
      <div class="row">
        <div class="UKheaderrow1column1 padded3">
          <font class="newheader">Sender Account : </font>
          &#160;
          <font class="newdata">
            <xsl:value-of select="ACCOUNT" />
          </font>
        </div>
        <div class="UKheaderrow1column2 padded3">
          <font class="newheader">Shipment Date : </font>
          &#160;
          <font class="newdata">
            <xsl:value-of select="$ShippingDate" />
          </font>
        </div>
      </div>
      <div class="row">
        <div class="UKheaderrow2column1 padded3">
          <font class="newheader">
            Sender Name:
            <br class="" />
            &amp; Address
          </font>
        </div>
        <div class="UKheaderrow2column1 padded3">
          <div class="Line80fixed13 padded3">
            <font class="newdata">
              <xsl:value-of select="COMPANYNAME" />
            </font>
          </div>
          <div class="Line80fixed13 padded3">
            <font class="newdata">
              <xsl:value-of select="STREETADDRESS1" />
            </font>
          </div>
          <div class="Line80fixed13 padded3">
            <font class="newdata">
              <xsl:if test="STREETADDRESS2/text()">
                <xsl:value-of select="STREETADDRESS2" />
              </xsl:if>
            </font>
          </div>
          <div class="Line80fixed13 padded3">
            <font class="newdata">
              <xsl:if test="STREETADDRESS3/text()">
                <xsl:value-of select="STREETADDRESS3" />
              </xsl:if>
            </font>
          </div>
          <div class="Line80fixed13 padded3">
            <font class="newdata">
              <xsl:value-of select="CITY" />
            </font>
          </div>
          <div class="Line80fixed13 padded3">
            <font class="newdata">
              <xsl:if test="PROVINCE/text()">
                <xsl:value-of select="PROVINCE" />
              </xsl:if>
            </font>
          </div>
          <div class="Line80fixed13 padded3">
            <font class="newdata">
              <xsl:if test="POSTCODE/text()">
                <xsl:value-of select="POSTCODE" />
              </xsl:if>
            </font>
          </div>
          <div class="Line80fixed13 padded3">
            <font class="newdata">
              <xsl:value-of select="COUNTRY" />
            </font>
          </div>
        </div>
        <div class="UKheadercolumn3 padded3">
          <br/>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Template for selecting default manifest -->
  <xsl:template match="CONSIGNMENT" mode="defaultManifest">
    <!-- International Manifest prepared for future enhancements (using a copies attribute) -->
    <xsl:choose>
      <xsl:when test="CONSIGNMENTBATCH/CONSIGNMENT/@copies">
        <xsl:apply-templates select="." mode="internationalManifest">
          <xsl:with-param name="Copies" select="/CONSIGNMENTBATCH/CONSIGNMENT/@copies" />
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="internationalManifest">
          <xsl:with-param name="Copies" select="'1'" />
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Template for building international manifest -->
  <xsl:template match="CONSIGNMENT" mode="internationalManifest">
    <xsl:param name="Copies" />
    <xsl:param name="Copy" select="1"/>

    <xsl:if test="$Copy &lt;= $Copies">
      <script type="text/Javascript">includePageBreak();</script>

      <!-- Page element -->
      <div class="body">
        <!-- Header and sender elements -->
        <xsl:apply-templates select="HEADER/SENDER" mode="IntAddress">
          <xsl:with-param name="PaymentTerms" select="PAYMENTIND"/>
        </xsl:apply-templates>
        <!-- Subheader section including barcode and special instructions-->
        <xsl:apply-templates select="." mode="IntSubheader"/>
        <div class="row">
          <!-- Sender Contact details -->
          <xsl:apply-templates select="HEADER/SENDER" mode="IntContact"/>
          <!-- Customer Reference -->
          <xsl:apply-templates select="CUSTOMERREF" mode="IntContactCol3">
            <xsl:with-param name="header" select="'Sender Ref'"/>
          </xsl:apply-templates>
        </div>
        <!-- Receiver Details -->
        <xsl:apply-templates select="RECEIVER" mode="IntAddress"/>
        <div class="row">
          <!-- Receiver Contact Details -->
          <xsl:apply-templates select="RECEIVER" mode="IntContact"/>
          <!-- Receiver VAT -->
          <xsl:apply-templates select="RECEIVER/VAT" mode="IntContactCol3">
            <xsl:with-param name="header" select="'Receiver VAT Nr'"/>
          </xsl:apply-templates>
        </div>
        <!-- Collection and Receiver Details -->
        <xsl:apply-templates select="HEADER/COLLECTION" mode="IntAddress"/>
        <xsl:choose>
          <xsl:when test="DELIVERY">
            <xsl:apply-templates select="DELIVERY" mode="IntAddress"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="InternationalAddress">
              <xsl:with-param name="addressType" select="'DELIVERY'"></xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Service and options ; Consignment Totals -->
        <xsl:apply-templates select="." mode="IntServices"/>
        <xsl:apply-templates select="." mode="IntTotals"/>
        <xsl:apply-templates select="." mode="IntGoods"/>
        <!-- Packages section -->
        <xsl:apply-templates select="." mode="IntPacks"/>
        <!-- Signatory section -->
        <xsl:apply-templates select="." mode="IntSign"/>
      </div>

      <xsl:apply-templates select="." mode="internationalManifest">
        <xsl:with-param name="Copy" select="$Copy+1" />
        <xsl:with-param name="Copies" select="$Copies" />
      </xsl:apply-templates>
    </xsl:if>
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

  <!-- Template for matching Signatory section -->
  <xsl:template match="CONSIGNMENT" mode="IntSign">
    <div class="row">
      <div class="hr">
        &#160;
      </div>
      <div class="separator">
        &#160;
      </div>
      <div class="signcolumn1">
        <font class="newdata">
          <div class="Line160">
            Sender's Signature _________________________________
          </div>
          <div class="Line160">
            Received by TNT Services ________________________________
          </div>
        </font>
      </div>
      <div class="signcolumn2">
        <font class="newdata">
          <div class="Line160">
            Date ____/____/____
          </div>
          <div class="Line160">
            Date ____/____/____ Time ___:___ hrs
          </div>
        </font>
      </div>
      <div class="separator">
        &#160;
      </div>
      <div class="Line20">
        <font class="carrierTerms">
           OUR LIABILITY FOR LOSS, DAMAGE AND DELAY IS LIMITED BY THE CMR CONVENTION OR THE WARSAW CONVENTION WHICHEVER IS APPLICABLE. THE SENDER AGREES THAT CARRIAGE OF THIS CONSIGNMENT IS SUBJECT TO THE TERMS AND CONDITIONS WHICH CAN BE VIEWED AT WWW.TNT.COM. IF NO SERVICES OR BILLING OPTIONS ARE SELECTED THE FASTEST AVAILABLE SERVICE WILL BE CHARGED TO THE SENDER.
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for matching Packages Header section -->
  <xsl:template match="CONSIGNMENT" mode="IntPacks">
    <div class="row packages">
      <div class="packagescolumn1">
        <div class="Line100">
          <font class="newheader">
            Description (incl. packing and marks)
          </font>
        </div>
      </div>
      <div class="packagescolumn2">
        <div class="Line100">
          <font class="newheader">
            Dimensions (L x W x H)
          </font>
        </div>
      </div>
      <div class="packagescolumn3">
        <div class="Line100">
          <font class="newheader">
            Total Consignment Volume &#160;
          </font>
          <font class="newdata">
            <xsl:value-of select="concat(format-number(TOTALVOLUME, '##0.000'), ' ', PACKAGE/VOLUME/@units)" />
          </font>
        </div>
      </div>
      <xsl:apply-templates select="PACKAGE[position() >= 1 and position() &lt; 4]" mode="int"/>
    </div>
  </xsl:template>

  <!-- Template for matching Goods description -->
  <xsl:template match="CONSIGNMENT" mode="IntGoods">
    <div class="row">
      <div class="addresscolumn1">
        <div class="Line100">
          <font class="newheader">
            Goods Description
          </font>
        </div>
      </div>
      <div class="addresscolumn2">
        <div class="Line100">
          <font class="newdata">
            :
            &#160;
            <xsl:value-of select="GOODSDESC1" />
          </font>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Template for matching Services and Options -->
  <xsl:template match="CONSIGNMENT" mode="IntServices">
    <div class="row">
      <div class="servicescolumn1">
        <font class="newheader">
          <div class="Line160">
            Service
          </div>
          <div class="Line160">
            Options
          </div>
        </font>
      </div>
      <div class="servicescolumn2">
        <font class="newdata">
          <div class="Line160">
            : &#160;
            <xsl:value-of select="SERVICE" />
          </div>
          <div class="Line160">
            : &#160;
            <xsl:if test="string-length(normalize-space(OPTION1)) != 0">
              <xsl:value-of select="OPTION1" />
            </xsl:if>
            <xsl:if test="string-length(normalize-space(OPTION2)) != 0">
              , &#160;
              <xsl:value-of select="OPTION2" />
            </xsl:if>
            <xsl:if test="string-length(normalize-space(OPTION3)) != 0">
              , &#160;
              <xsl:value-of select="OPTION3" />
            </xsl:if>
            <xsl:if test="string-length(normalize-space(OPTION4)) != 0">
              , &#160;
              <xsl:value-of select="OPTION4" />
            </xsl:if>
            <xsl:if test="string-length(normalize-space(OPTION5)) != 0">
              , &#160;
              <xsl:value-of select="OPTION5" />
            </xsl:if>
          </div>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for matching Totals line -->
  <xsl:template match="CONSIGNMENT" mode="IntTotals">
    <div class="row">
      <div class="totalscolumn1">
        <div class="Line100">
          <font class="newheader">
            No Pieces
          </font>
          <font class="newdata">
            &#160;:&#160;
            <xsl:value-of select="TOTALITEMS" />
          </font>
        </div>
      </div>
      <div class="totalscolumn2">
        <div class="Line100">
          <font class="newheader">
            Weight
          </font>
          <font class="newdata">
            &#160;:&#160;
            <xsl:value-of select="concat(format-number(TOTALWEIGHT, '####0.000'), ' ', TOTALWEIGHT/@units)" />
          </font>
        </div>
      </div>
      <div class="totalscolumn3">
        <div class="Line100">
          <font class="newheader">
            Insurance Value
          </font>
          <font class="newdata">
            &#160;:&#160;
            <xsl:if test="INSURANCEVALUE/text()">
              <xsl:value-of select="concat(format-number(INSURANCEVALUE, '##########0.00'), ' ', INSURANCECURRENCY)" />
            </xsl:if>
          </font>
        </div>
      </div>
      <div class="totalscolumn4">
        <div class="Line100">
          <font class="newheader">
            Invoice Value
          </font>
          <font class="newdata">
            &#160;:&#160;
            <xsl:if test="GOODSVALUE/text()">
              <xsl:value-of select="concat(format-number(GOODSVALUE, '##########0.00'), ' ', CURRENCY)" />
            </xsl:if>
          </font>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Template for matching 'contactcolumn3' style - note this is not in full width, but must be preceeded by a Contact element : templates in mode 'IntContact'-->
  <xsl:template match="node()" mode="IntContactCol3">
    <xsl:param name="header" select="name(.)"/>

    <div class="contactcolumn3">
      <div class="rowpart">
        <font class="newheader">
          <div class="Line160">
            <br/>
          </div>
          <div class="Line160">
            <xsl:value-of select="concat($header, ' : ', '&#160;')" />
          </div>
        </font>
      </div>
      <div class="rowpart">
        <font class="newdata">
          <div class="Line160">
            <br/>
          </div>
          <div class="Line160">
            <xsl:value-of select="." />
          </div>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for matching Contacts section - note this is not in full width, but must be followed by an element using 'contactcolumn3' style : templates in mode 'IntContactCol3' -->
  <xsl:template match ="SENDER | RECEIVER" mode="IntContact">
    <xsl:variable name="addressType">
      <xsl:value-of select="name(.)"/>
    </xsl:variable>

    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />

    <div class="contactcolumn1">
      <font class="newheader">
        <div class="Line160">
          <xsl:value-of select="concat(substring($addressType, 1, 1), translate(substring($addressType, 2), $uppercase, $lowercase),' Contact')" />
        </div>
        <div class="Line160">
          &amp; Tel
        </div>
      </font>
    </div>
    <div class="contactcolumn2">
      <font class="newdata">
        <div class="Line160">
          : &#160;
          <xsl:value-of select="CONTACTNAME" />
        </div>
        <div class="Line160">
          : &#160;
          <xsl:value-of select="concat( CONTACTDIALCODE, ' ', CONTACTTELEPHONE)" />
        </div>
      </font>
    </div>
  </xsl:template>

  <!-- Template for matching Subheader section -->
  <xsl:template match="CONSIGNMENT" mode="IntSubheader">

    <!-- Variable used with DG functionality -->
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

    <div class="headerborder detail">
      <!-- Barcode section -->
      <div class="barcode centered">
        <img height="60" class="barcodecenter">
          <xsl:attribute name="src">
            <xsl:value-of select="concat($hostName, $code39Barcode_url, CONNUMBER)" />
          </xsl:attribute>
        </img>
        <div class="Line80">
          <font class="newbarcode">
            *
            <xsl:value-of select="CONNUMBER" />
            *
          </font>
        </div>
      </div>
      <!-- Special Instructions -->
      <div class="specinstructions centered">
        <div class="Line80">
          <font class="newtitle">
            Special Instructions
          </font>
        </div>
        <font class="newdata">
          <xsl:if test="DELIVERYINST/text()">
            <br/>
            <xsl:value-of select="DELIVERYINST"/>
          </xsl:if>
        </font>
      </div>
      <!-- Simple Dangerous Goods logic -->
      <div class="dgsection centered">
        <font class="newheader">
          <div class="Line160">
            <xsl:choose>
              <xsl:when test="$DG-Option1 = 'Y' or $DG-Option2 = 'Y' or $DG-Option3 = 'Y' or $DG-Option4 = 'Y' or $DG-Option5 = 'Y'">
                DANGEROUS
              </xsl:when>
              <xsl:otherwise>
                NON DANGEROUS
              </xsl:otherwise>
            </xsl:choose>
          </div>
          <div class="Line160">
            GOODS
            <br/>
          </div>
          <div class="Line160">
            <xsl:choose>
              <xsl:when test="PAYMENTIND/text() = 'S'">
                <br />
                SENDER PAYS
              </xsl:when>
              <xsl:otherwise>
                <br />
                RECEIVER PAYS
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template for matching Sender building whole header section -->
  <xsl:template match="SENDER" mode="IntAddress">
    <xsl:param name="PaymentTerms"/>

    <div class="headerborder">
      <!-- Header elements -->
      <div class="row">
        <div class="headercolumn1 centered">
          <img class="center" src="{$hostName}{$images_dir}\logo-small.gif" />
        </div>
        <div class="headercolumn2">
          &#160;
        </div>
        <div class="headercolumn3">
          <div class="Line80 centered">
            <font class="newtitle">
              COLLECTION MANIFEST (DETAIL) OTHERS
            </font>
          </div>
          <div class="Line80 centered">
            <font class="newtitle">
              <xsl:choose>
                <xsl:when test="$PaymentTerms = 'S'">
                  (SENDER PAYS)
                </xsl:when>
                <xsl:otherwise>
                  (RECEIVER PAYS)
                </xsl:otherwise>
              </xsl:choose>
            </font>
          </div>
          <div class="Line80fixed13 centered">
            <font class="newdata">
              TNT 
            </font>
          </div>
          <div class="Line80fixed13 centered">
            <font class="newheader">
              Shipment Date :
            </font>
            <font class="newdata">
              <xsl:value-of select="../SHIPMENTDATE" />
            </font>
          </div>
          <div class="Line80fixed13 centered">
            <font class="newheader">
              Pickup id :
            </font>
            <font class="newdata">
              ExpressConnect 3
            </font>
          </div>
          <div class="printdaterow Line80fixed13">
            <font class="newheader">
              Printed on :
            </font>
            <font class="newdata">
              <script type="text/javascript"><![CDATA[var d = new Date(); document.write(d.getDate()); document.write("/"); document.write(d.getMonth() + 1); document.write("/"); document.write(d.getFullYear());]]></script>
            </font>
          </div>
        </div>
      </div>
      <!-- Sender Details -->
      <div class="row">
        <div class="headercolumn1">
          <font class="newheader">
            <div class="Line160">
              Sender Account
            </div>
            <div class="Line160">
              Sender Name
            </div>
            <div class="Line160">
              &amp; Address
              <br />
            </div>
          </font>
        </div>
        <div class="headercolumn2">
          <font class="newheader">
            <div class="Line160">
              :
            </div>
            <div class="Line160">
              :
            </div>
            <div class="Line160">
              :
              <br/>
              :
            </div>
          </font>
        </div>
        <div class="headercolumn3">
          <font class="newdata">
            <div class="Line160">
              <xsl:value-of select="ACCOUNT" />
            </div>
            <div class="Line160">
              <xsl:value-of select="COMPANYNAME" />
            </div>
            <div class="Line160">
              <xsl:value-of select="STREETADDRESS1" />
              <xsl:if test="STREETADDRESS2/text()">
                ,
                <xsl:value-of select="STREETADDRESS2" />
              </xsl:if>
              <xsl:if test="STREETADDRESS3/text()">
                ,
                <xsl:value-of select="STREETADDRESS3" />
              </xsl:if>
              <br/>
              <xsl:if test="CITY/text()">
                <xsl:value-of select="CITY" />
                ,
              </xsl:if>
              <xsl:if test="PROVINCE/text()">
                <xsl:value-of select="PROVINCE" />
                ,
              </xsl:if>
              <xsl:if test="POSTCODE/text()">
                <xsl:value-of select="POSTCODE" />
                ,
              </xsl:if>
              <xsl:value-of select="COUNTRY" />
            </div>
          </font>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Tempate to match addresses sections -->
  <xsl:template match="RECEIVER | COLLECTION | DELIVERY" name="InternationalAddress" mode ="IntAddress">
    <xsl:param name="addressType">
      <xsl:value-of select="name(.)"/>
    </xsl:param>

    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />

    <div class="row">
      <div class="addresscolumn1">
        <font class="newheader">
          <div class="Line160">
            <xsl:value-of select="concat(substring($addressType, 1, 1), translate(substring($addressType, 2), $uppercase, $lowercase),' Name')" />
          </div>
          <div class="Line160">
            &amp; Address
          </div>
        </font>
      </div>
      <div class="addresscolumn2">
        <font class="newdata">
          <div class="Line160">
            : &#160;
            <xsl:if test="COMPANYNAME/text()">
              <xsl:value-of select="COMPANYNAME" />
            </xsl:if>
          </div>
          <div class="Line160">
            : &#160;
            <xsl:if test="STREETADDRESS1/text()">
              <xsl:value-of select="STREETADDRESS1" />
              ,
            </xsl:if>
            <xsl:if test="STREETADDRESS2/text()">
              <xsl:value-of select="STREETADDRESS2" />
              ,
            </xsl:if>
            <xsl:if test="STREETADDRESS3/text()">
              <xsl:value-of select="STREETADDRESS3" />
            </xsl:if>
          </div>
          <div class="Line160">
            : &#160;
            <xsl:if test="CITY/text()">
              <xsl:value-of select="CITY" />
              ,
            </xsl:if>
            <xsl:if test="PROVINCE/text()">
              <xsl:value-of select="PROVINCE" />
              ,
            </xsl:if>
            <xsl:if test="POSTCODE/text()">
              <xsl:value-of select="POSTCODE" />
              ,
            </xsl:if>
            <xsl:if test="COUNTRY/text()">
              <xsl:value-of select="COUNTRY" />
            </xsl:if>
          </div>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template to build package rows -->
  <xsl:template match="PACKAGE" mode="int">
    <div class="packagescolumn1">
      <div class="Line80fixed13">
        <font class="newdata">
          <xsl:choose>
            <xsl:when test="ARTICLE/INVOICEDESC/text()">
              <xsl:value-of select="ARTICLE/INVOICEDESC" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="ARTICLE/DESCRIPTION/text()">
                  <xsl:value-of select="ARTICLE/DESCRIPTION" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="GOODSDESC" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
    </div>
    <div class="packagescolumn2">
      <div class="Line80fixed13">
        <font class="newdata">
          <xsl:choose>
            <xsl:when test="LENGTH/@units = 'cm'">
              <xsl:value-of select="concat(format-number(LENGTH, '###'), ' ', LENGTH/@units)" />
              x
              <xsl:value-of select="concat(format-number(WIDTH, '###'), ' ', WIDTH/@units)" />
              x
              <xsl:value-of select="concat(format-number(HEIGHT, '###'), ' ', HEIGHT/@units)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(LENGTH, ' ', LENGTH/@units)" />
              x
              <xsl:value-of select="concat(WIDTH, ' ', WIDTH/@units)" />
              x
              <xsl:value-of select="concat(HEIGHT, ' ', HEIGHT/@units)" />
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
    </div>
    <div class="packagescolumn3">
      <div class="Line80fixed13">
        <font class="newdata">
          &#160;
        </font>
      </div>
    </div>
  </xsl:template>
</xsl:stylesheet>
