<?xml version="1.0" encoding="iso-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:lookup="lookup" exclude-result-prefixes="lookup">
  <xsl:output method="html" encoding="ISO-8859-1" />
  <!-- Version 3.0.1  03-01-2018 13:38 Draft version for Infosys -->
  <!-- Version 3.0.2  03-01-2018 16:18 Minor fixes for service and options display -->
  <!-- Version 3.0.3  04-01-2018 08:13 Fixed page break issue -->
  <!-- Version 3.1.0  05-03-2018 13:48 Split into CTS version and server version. Going to DIV technology. This is server version -->
  <!-- Version 3.1.1  08-03-2018 09:47 Removal of term country - Server version -->
  <!-- Version 3.1.2  14-03-2018 10:22 Fixing browser compatiblity issues - Server version -->
  <!-- Version 3.1.3  28-05-2018 10:26 UK label updated and reviewed to newer standards - Server version -->
  <!-- Version 3.1.4  16-10-2018 11:49 Fixing FR customer issue with DG - Server version -->
  <!-- Version 3.1.5  05-04-2019 15:10 Image centering issue fixed by Fernand Alves - Server version -->

  <xsl:variable name="UKDomSysId" select="'6'" />
  <xsl:param name="code39Barcode_url" select="CONSIGNMENTBATCH/BARCODEURL" />
  <xsl:param name="hostName" select="CONSIGNMENTBATCH/HOST" />
  <xsl:param name="images_dir" select="CONSIGNMENTBATCH/IMAGESDIR" />
  <xsl:param name="itemcount" select="0" />

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
        <title>TNT Label</title>
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
          .outerLabel {
              width: 480px;
              height: 373px;
          }

          .row {
              width: 100%;
              float: left;
          }

          .bordered {
              border: 2px solid #000000;
          }

          .bordered + .bordered {
              border-top: 0px solid #000000;
          }

          .bordered > .bordered, .UKcolumn2 > .bordered {
              border-top: 0px solid #000000;
              border-left: 0px solid #000000;
              border-right: 0px solid #000000;
          }
          
          .bordered > .bordered:last-child, .UKcolumn2 > .bordered:last-child {
              border-bottom: 0px solid #000000;
          }          

          .bordered-right {
              height: 100%;
              border-right: 2px solid #000000;
          }

          .padded2 {
              padding: 2px;
          }

          .centered {
              text-align: center;
          }

          .innerLabelheight {
              height: 362px;
          }

          .firstrowheight {
              text-align: right;
              height: 7px;
          }

          .secondrowheight, .thirdrowheight {
              height: 123px;
          }

          .collection, .goods, .services {
              width: 44%;
              float: left;
              overflow: hidden;
          }

          .Line80 {
              height: 25px;
              line-height: 100%;
              padding-left: 2px;
          }

          .Line75 {
              height: 21px;
              line-height: 100%;
              padding-left: 2px;
          }

          .address {
              height: 12px;
              line-height: 80%;
              padding-left: 2px;
          }

          .custref {
              overflow: hidden;
              border-top: 2px solid #000000;
          }

          .senderheaderheight {
              height: 11px;
          }

          .senderheaderrow1 {
              width: 20%;
              float: left;
          }

          .senderheaderrow2 {
              width: 80%;
              float: left;
          }

          .contactsrow1 {
              width: 25%;
              float: left;
          }

          .contactsrow2 {
              width: 75%;
              float: left;
          }

          .barcode, .delivery {
              width: 55%;
              float: left;
          }

          .fourthrowheight {
              height : 30px;
          }

          .specinstructions {
              width: 64%;
              overflow: hidden;
              float: left;
          }

          .dgsection {
              width: 33%;
              overflow: hidden;
              line-height: 26px;
              float: left;
          }

          .fifthrowheight {
              height: 81px;
          }

          .packages {
              width: 24.5%;
              float: left;
              overflow: hidden;
          }

          .fifthrowmargin {
              margin-left: 2px;
              padding-top: 2px;
          }

          .TandC {
              width: 29.5%;
              float: left;
              overflow: hidden;
          }

          .separatorheight {
              height: 10px;
          }

          .Line70 {
              line-height: 70%;
              padding-left: 2px;
              padding-bottom: 2px;
          }

          .Line40 {
              line-height: 9px;
              padding-left: 2px;
              padding-bottom: 1px;
          }

          .Line30 {
              line-height: 6px;
          }

          font {
              color: black;
          }

          font.carrierLicence {
              font-family: "courier new";
              font-size: 7pt;
          }

          font.addressHeader {
              font-weight: bold;
              font-family: "arial";
              font-size: 6pt;
          }

          font.addressData {
              font-family: "courier new";
              font-size: 8pt;
          }

          font.addressDatasmall {
              font-family: "courier new";
              font-size: 6pt;
          }

          font.addressHeaderRec {
              font-weight: bold;
              font-family: "arial";
              font-size: 6pt;
          }

          font.addressDataRec {
              font-weight: bold;
              font-family: "courier new";
              font-size: 8pt;
          }

          font.addressHeaderCode {
              font-weight: bold;
              font-family: "arial";
              font-size: 8pt;
              letter-spacing: 0.2cm;
          }

          font.addressDataWeight {
              font-weight: bold;
              font-family: "courier new";
              font-size: 11pt;
          }

          font.addressSmallPrint {
              font-family: "courier new";
              font-size: 4pt;
          }

          img.center {
              display: inline-block;
              margin-bottom: 1px;
              margin-left: auto;
              margin-right: auto;
              margin-top: 1px;
          }

          div.pagebreak {
              page-break-before: always;
          }

          font.header {
              font-weight: bold;
              font-family: arial, helvetica "sans-serif";
              font-size: 8pt;
          }

          font.data {
              font-family: arial, "sans-serif";
              font-size: 8pt;
          }

          font.smallprint {
              font-family: arial, "sans-serif";
              font-size: 6pt;
          }

          .padded {
              padding: 1px;
          }
          
          .padded-top30 {
              padding-top: 30px;
          }

          .data {
          }

          .dataBold {
              font-weight: bold;
          }

          .deliveryDepot {
              padding-top: 8px;
              font-size: 96px;
          }

          .deliveryPostcode, .premiumService {
              font-size: xx-large;
              font-weight: bold;
          }

          .text {
              line-height: 54px;
              font-size: 36pt;
          }

          .normalService {
              font-size: x-large;
          }

          .tntTelephone {
              font-size: small;
          }

          .UKouterlabel  {
              height: 98%;
              width: 550px;
          }

          .UKinnerlabelheight {
              min-height: 625px;
          }

          .UKfirstrowheight {
              height: 90px;
          }

          .UKsecondrowheight {
              height: 130px;
          }

          .UKthirdrowheight {
              height: 244px;
          }

          .UKfourthrowheight {
              height: 150px;
          }

          .UKfifthrowheight {
              height: 115px;
          }

          .UKcolumn1 {
              width: 50%;
              float: left;
          }

          .UKcolumn2 {
              width: calc(50% - 8px);
              float: left;
              height: 100%;
          }

          .UKinnerrowheight {
              height: 31%;
          }

          .UKlogo {
              width: 62%;
              float: left;
          }

          .UKphone {
              width: 36%;
              float: left;
          }

          .label {
              width: 40%;
              float: left;
          }

          .UKlabel {
              width: 59%;
              float: left;
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

  <!-- Template to select what layout to use for a consignment -->
  <xsl:template match="CONSIGNMENT" mode="loop">
    <xsl:choose>
      <xsl:when test="@marketType='DOMESTIC'">
        <xsl:choose>
          <xsl:when test="@originCountry='GB'">
            <xsl:choose>
              <xsl:when test="./PACKAGE">
                <xsl:apply-templates select="./PACKAGE" mode="ukDomesticLabel">
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="." mode="ukDomesticLabel">
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="PACKAGE">
                <xsl:apply-templates select="PACKAGE" mode="defaultlLabel"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="." mode="defaultlLabel">
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="PACKAGE">
            <xsl:apply-templates select="PACKAGE" mode="internationalLabel"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="." mode="internationalLabel">
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- Default template for consignments with packages - points to the current default -->
  <xsl:template match="PACKAGE" mode="defaultlLabel">
    <xsl:apply-templates select="." mode="internationalLabel">
    </xsl:apply-templates>
  </xsl:template>

  <!-- Default template for consignments without packages - points to the current default -->
  <xsl:template match="CONSIGNMENT" mode="defaultlLabel">
    <xsl:apply-templates select="." mode="internationalLabel">
    </xsl:apply-templates>
  </xsl:template>

  <!-- Template for UK Domestic cons without packages - no changes to design, only ensuring correct selection of nodes and recursion logic -->
  <xsl:template match="CONSIGNMENT" mode="ukDomesticLabel">
    <xsl:param name="itemcount" select="1" />
    <xsl:variable name="collection-depot" select="format-number(HEADER/COLLECTIONDEPOTNAME/@depotCode, '000')" />
    <xsl:variable name="delivery-depot" select="format-number(DELIVERYDEPOTNAME/@depotCode, '000')" />
    <xsl:variable name="barcode" select="concat(HEADER/COLLECTIONDEPOTNAME/@depotCode, format-number(HEADER/SENDER/ACCOUNT, '0000000000'), substring(CONNUMBER, 1, 8), format-number($itemcount, '000'), DELIVERYDEPOTNAME/@depotCode)"/>

    <xsl:if test ="$itemcount &lt;= TOTALITEMS">
      <script type="text/Javascript">includePageBreak();</script>

      <div class="UKouterlabel">
        <div class="row UKinnerlabelheight bordered">
          <div class="row UKfirstrowheight bordered">
            <xsl:apply-templates select="SERVICE" mode="UK">
              <xsl:with-param name="Servicename" select="SERVICESHORTNAME"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="CONNUMBER" mode="UK"/>
          </div>
          <div class="row UKsecondrowheight bordered">
            <xsl:apply-templates select="." mode="UK">
              <xsl:with-param name="itemcount" select="$itemcount"/>
              <xsl:with-param name="Weight" select="TOTALWEIGHT"/>
            </xsl:apply-templates>
            <div class="row UKcolumn2 deliveryDepot centered">
              <xsl:value-of select="DELIVERYDEPOTNAME/@depotCode" />
            </div>
          </div>
          <div class="row UKthirdrowheight bordered">
            <xsl:choose>
              <xsl:when test="DELIVERY/COMPANYNAME/text()">
                <xsl:apply-templates select="DELIVERY" mode="UK"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="RECEIVER" mode="UK"/>
              </xsl:otherwise>
            </xsl:choose>
            <div class="UKcolumn2">
              <xsl:choose>
                <xsl:when test="DELIVERYINST/text()">
                  <xsl:apply-templates select="DELIVERYINST" mode="UKSpecInstr"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="CONNUMBER" mode="UKSpecInstr">
                    <xsl:with-param name="IsBlank">
                      <xsl:text>Y</xsl:text>
                    </xsl:with-param>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="CUSTOMERREF/text()">
                  <xsl:apply-templates select="CUSTOMERREF" mode="UKcustref"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="CONNUMBER" mode="UKcustref">
                    <xsl:with-param name="IsBlank">
                      <xsl:text>Y</xsl:text>
                    </xsl:with-param>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="DELIVERY/COMPANYNAME/text()">
                  <xsl:apply-templates select="DELIVERY/POSTCODE" mode="UK"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="RECEIVER/POSTCODE" mode="UK"/>
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </div>
          <div class="row UKfourthrowheight bordered centered padded2">
            <div class="row Line80 data padded2">
              <xsl:value-of select="$UKDomSysId" />
              <xsl:value-of select="$barcode" />
            </div>
            <img src="{$hostName}/barbecue/barcode?data={$barcode}&amp;type=UCC128&amp;appid=6&amp;height=105" />
          </div>
        </div>
        <xsl:apply-templates select="CONNUMBER" mode="UKtext"/>
      </div>

      <xsl:apply-templates select="." mode="ukDomesticLabel">
        <xsl:with-param name="itemcount" select="$itemcount + 1"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <!-- Template for UK Domestic cons with packages - no changes to design, only ensuring correct selection of nodes and recursion logic -->
  <xsl:template match="PACKAGE" mode="ukDomesticLabel">
    <xsl:param name="itemcount" select="0 + 1" />
    <xsl:param name="sectioncount" select="0 + ITEMS" />
    <xsl:variable name="collection-depot" select="format-number(../HEADER/COLLECTIONDEPOTNAME/@depotCode, '000')" />
    <xsl:variable name="delivery-depot" select="format-number(../DELIVERYDEPOTNAME/@depotCode, '000')" />
    <xsl:variable name="barcode" select="concat(../HEADER/COLLECTIONDEPOTNAME/@depotCode, format-number(../HEADER/SENDER/ACCOUNT, '0000000000'), substring(../CONNUMBER, 1, 8), format-number($itemcount, '000'), ../DELIVERYDEPOTNAME/@depotCode)"/>

    <xsl:if test="$itemcount &lt;= $sectioncount">
      <script type="text/Javascript">includePageBreak();</script>

      <div class="UKouterlabel">
        <div class="row UKinnerlabelheight bordered">
          <div class="row UKfirstrowheight bordered">
            <xsl:apply-templates select="../SERVICE" mode="UK">
              <xsl:with-param name="Servicename" select="../SERVICESHORTNAME"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="../CONNUMBER" mode="UK"/>
          </div>
          <div class="row UKsecondrowheight bordered">
            <xsl:apply-templates select="../." mode="UK">
              <xsl:with-param name="itemcount" select="$itemcount"/>
              <xsl:with-param name="Weight" select="WEIGHT"/>
            </xsl:apply-templates>
            <div class="row UKcolumn2 deliveryDepot centered">
              <xsl:value-of select="../DELIVERYDEPOTNAME/@depotCode" />
            </div>
          </div>
          <div class="row UKthirdrowheight bordered">
            <xsl:choose>
              <xsl:when test="../DELIVERY/COMPANYNAME/text()">
                <xsl:apply-templates select="../DELIVERY" mode="UK"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="../RECEIVER" mode="UK"/>
              </xsl:otherwise>
            </xsl:choose>
            <div class="UKcolumn2">
              <xsl:choose>
                <xsl:when test="../DELIVERYINST/text()">
                  <xsl:apply-templates select="../DELIVERYINST" mode="UKSpecInstr"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="../CONNUMBER" mode="UKSpecInstr">
                    <xsl:with-param name="IsBlank">
                      <xsl:text>Y</xsl:text>
                    </xsl:with-param>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="../CUSTOMERREF/text()">
                  <xsl:apply-templates select="../CUSTOMERREF" mode="UKcustref"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="../CONNUMBER" mode="UKcustref">
                    <xsl:with-param name="IsBlank">
                      <xsl:text>Y</xsl:text>
                    </xsl:with-param>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="../DELIVERY/COMPANYNAME/text()">
                  <xsl:apply-templates select="../DELIVERY/POSTCODE" mode="UK"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="../RECEIVER/POSTCODE" mode="UK"/>
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </div>
          <div class="row UKfourthrowheight bordered centered padded2">
            <div class="row Line80 data padded2">
              <xsl:value-of select="$UKDomSysId" />
              <xsl:value-of select="$barcode" />
            </div>
            <img src="{$hostName}/barbecue/barcode?data={$barcode}&amp;type=UCC128&amp;appid=6&amp;height=105" />
          </div>
        </div>
        <xsl:apply-templates select="../CONNUMBER" mode="UKtext"/>
      </div>

      <xsl:apply-templates select="." mode="ukDomesticLabel">
        <xsl:with-param name="itemcount" select="$itemcount + 1"/>
        <xsl:with-param name="sectioncount" select="$sectioncount"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <!-- Template to match UK instruction text section -->
  <xsl:template match="CONNUMBER" mode="UKtext">
    <div class="UKfifthrowheight">
      <div class="row centered">
        <font class="text">
          <b>Address Label</b>
        </font>
      </div>
      <div class="row Line80 centered">
        <font class="data">&#160;</font>
      </div>
      <div class="row Line80 centered">
        <font class="data">&#160;</font>
      </div>
      <div class="row Line80 centered">
        <font class="data">&#160;</font>
      </div>
      <div class="row Line80 centered">
        <font class="data">Please fold this page and attach it to your parcel</font>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match UK Special Instructions section -->
  <xsl:template match="node()" mode="UKSpecInstr">
    <xsl:param name="IsBlank">
      <xsl:text>N</xsl:text>
    </xsl:param>
    <div class="row UKinnerrowheight bordered padded2">
      <div class="row Line80 data">Special Instructions:</div>
      <div class="row Line80 dataBold">
        &#160;
        <xsl:if test="$IsBlank = 'N'">
          <xsl:value-of select="substring(., 1, 25)"/>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match UK Customer Reference section -->
  <xsl:template match="node()" mode="UKcustref">
    <xsl:param name="IsBlank">
      <xsl:text>N</xsl:text>
    </xsl:param>
    <div class="row UKinnerrowheight bordered padded2">
      <div class="row Line80 data">Customer Reference:</div>
      <div class="row Line80 dataBold">
        &#160;
        <xsl:if test="$IsBlank = 'N'">
          <xsl:value-of select="substring(., 1, 15)"/>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match UK Destination Postcode section -->
  <xsl:template match="POSTCODE" mode="UK">
    <div class="row UKinnerrowheight bordered padded2">
      <div class="row Line80 deliveryPostcode centered padded-top30">
        &#160;
        <xsl:value-of select="."/>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match UK Receiver / Delivery section -->
  <xsl:template match="RECEIVER | DELIVERY" mode="UK">
    <div class="UKcolumn1 bordered-right padded">
      <div class="row Line80 data">Deliver to:</div>
      <div class="row Line80 dataBold">
        <xsl:value-of select="CONTACTNAME" />
      </div>
      <div class="row Line80 dataBold">
        <xsl:value-of select="COMPANYNAME" />
      </div>
      <div class="row Line80 dataBold">
        <xsl:value-of select="STREETADDRESS1" />
      </div>
      <div class="row Line80 dataBold">
        <xsl:value-of select="STREETADDRESS2" />
      </div>
      <div class="row Line80 dataBold">
        <xsl:value-of select="STREETADDRESS3" />
      </div>
      <div class="row Line80 dataBold">
        <xsl:value-of select="CITY" />
      </div>
      <div class="row Line80 dataBold">
        <xsl:value-of select="PROVINCE" />
      </div>
      <div class="row Line80 dataBold">
        <xsl:value-of select="POSTCODE" />
      </div>
      <div class="row Line80 dataBold">
        <xsl:value-of select="COUNTRY" />
      </div>
    </div>

  </xsl:template>

  <!-- Template to match UK Con details section -->
  <xsl:template match="CONSIGNMENT" mode="UK">
    <xsl:param name="itemcount"/>
    <xsl:param name="Weight"/>
    <div class="UKcolumn1 bordered-right padded">
      <div class="label">
        <div class="row Line75">
          Coll. Depot:
        </div>
        <div class="row Line75">
          Sender A/c:
        </div>
        <div class="row Line75">
          Cons. No.
        </div>
        <div class="row Line75">
          Weight (kg):
        </div>
        <div class="row Line75">
          Item No.:
        </div>
        <div class="row Line75">
          Coll. Date :
        </div>
      </div>
      <div class="UKlabel">
        <div class="row Line75">
          <span class="data">
            <xsl:value-of select="HEADER/COLLECTIONDEPOTNAME" />
          </span>
          &#160;
          <span class="dataBold">
            <xsl:value-of select="HEADER/COLLECTIONDEPOTNAME/@depotCode" />
          </span>
        </div>
        <div class="row Line75">
          <span class="dataBold">
            <xsl:value-of select="format-number(HEADER/SENDER/ACCOUNT , '0000000000')" />
          </span>
        </div>
        <div class="row Line75">
          <span class="dataBold">
            <xsl:value-of select="substring(CONNUMBER, 1, 8)" />
            <xsl:value-of select="substring(CONNUMBER, 9, 1)" />
          </span>
        </div>
        <div class="row Line75">
          <span class="data">
            <xsl:value-of select="format-number($Weight,'0.000')" />
          </span>
        </div>
        <div class="row Line75">
          <span class="dataBold">
            <xsl:value-of select="format-number($itemcount,'000')" />
            of
            <xsl:value-of select="format-number(TOTALITEMS,'000')" />
          </span>
        </div>
        <div class="row Line75">
          <span class="data">
            <xsl:value-of select="HEADER/SHIPMENTDATE" />
          </span>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match UK header section -->
  <xsl:template match="CONNUMBER" mode="UK">
    <div class="UKcolumn2 padded2">
      <div class="UKphone padded-top30">
        <div class="row address tntTelephone centered">
          Telephone
        </div>
        <div class="row address tntTelephone centered">
          01827 303030
        </div>
      </div>
      <div class="UKlogo">
        <img src="{$hostName}{$images_dir}\tnt_logo.gif" width="167" height="83" border="0" />
      </div>
    </div>
  </xsl:template>

  <!-- Template to match UK service section -->
  <xsl:template match="SERVICE" mode="UK">
    <xsl:param name="Servicename"/>
    <div class="UKcolumn1 bordered-right centered padded">
      <div>
        <xsl:choose>
          <xsl:when test="SERVICE/@Premium='Y'">
            <xsl:attribute name="class">row premiumService padded-top30</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">row normalService padded-top30</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$Servicename" />
      </div>
    </div>
  </xsl:template>

  <!-- Template for international cons without packages -->
  <xsl:template match="CONSIGNMENT" mode="internationalLabel">
    <xsl:param name="itemcount" select="1"/>
    <xsl:param name="packagecount" select="TOTALITEMS"/>

    <xsl:if test="$itemcount &lt;= $packagecount">
      <script type="text/Javascript">includePageBreak();</script>

      <!--start of main table -->
      <div class="outerLabel">
        <xsl:apply-templates select="." mode="intsystem"/>
        <!-- Inner visible table -->
        <div class="row innerLabelheight bordered">
          <div class="row secondrowheight bordered">
            <!-- Sender / Collection section -->
            <div class="collection bordered-right">
              <xsl:choose>
                <xsl:when test="HEADER/COLLECTION/COMPANYNAME/text()">
                  <xsl:apply-templates select="HEADER/COLLECTION" mode="int">
                    <xsl:with-param name="Account" select="HEADER/SENDER/ACCOUNT"/>
                  </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="HEADER/SENDER" mode="int">
                    <xsl:with-param name="Account" select="HEADER/SENDER/ACCOUNT"/>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
            </div>
            <!-- Logo and Barcode section -->
            <div class="barcode">
              <xsl:apply-templates select="CONNUMBER" mode="int"/>
              <!-- References section -->
              <xsl:choose>
                <xsl:when test="CUSTOMERREF/text()">
                  <xsl:apply-templates select="CUSTOMERREF" mode="intCustref"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="CONNUMBER" mode="intCustref">
                    <xsl:with-param name="IsBlank">
                      <xsl:text>Y</xsl:text>
                    </xsl:with-param>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </div>
          <div class="row thirdrowheight bordered">
            <!-- Receiver / Delivery section -->
            <div class="delivery bordered-right">
              <xsl:choose>
                <xsl:when test="DELIVERY/COMPANYNAME/text()">
                  <xsl:apply-templates select="DELIVERY" mode="int" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="RECEIVER" mode="int" />
                </xsl:otherwise>
              </xsl:choose>
            </div>
            <!-- Date, Description, Dimensions and Payment terms -->
            <div class="goods">
              <xsl:apply-templates select="HEADER/SHIPMENTDATE" mode="int"/>
              <!-- No Package elements, so show General Description -->
              <xsl:apply-templates select="GOODSDESC1" mode="int"/>
              <!-- No dimension are printed since no PACKAGE elements exist -->
              <div class="row address">
                <font class="addressHeader">Dimensions&#160;:&#160;</font>
              </div>
              <!-- Show Payment terms only for receiver pays -->
              <xsl:apply-templates select="PAYMENTIND" mode="int">
                <xsl:with-param name="ReceiverAccount" select="RECEIVER/ACCOUNT"></xsl:with-param>
              </xsl:apply-templates>
            </div>
          </div>
          <div class="row fourthrowheight bordered">
            <!-- Special Instructions or (later) place for DG Instructions text -->
            <xsl:choose>
              <xsl:when test="DELIVERYINST/text()">
                <xsl:apply-templates select="DELIVERYINST" mode="intSpecInstr"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="CONNUMBER" mode="intSpecInstr">
                  <xsl:with-param name="IsBlank">
                    <xsl:text>Y</xsl:text>
                  </xsl:with-param>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
            <!-- Dangerous Goods text -->
            <xsl:apply-templates select="CONNUMBER" mode="intOptions">
              <xsl:with-param name="Option1" select="OPTION1"/>
              <xsl:with-param name="Option2" select="OPTION2"/>
              <xsl:with-param name="Option3" select="OPTION3"/>
              <xsl:with-param name="Option4" select="OPTION4"/>
              <xsl:with-param name="Option5" select="OPTION5"/>
            </xsl:apply-templates>
          </div>
          <div class="row fifthrowheight bordered">
            <!-- Services and Options -->
            <xsl:apply-templates select="." mode="int"/>
            <!-- Package number and weight -->
            <div class="packages bordered-right">
              <xsl:apply-templates select="TOTALITEMS" mode="int">
                <xsl:with-param name="item" select="$itemcount"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="TOTALWEIGHT" mode="int">
                <xsl:with-param name="NameOfCaller" select="name(.)"/>
              </xsl:apply-templates>
            </div>
            <!-- T&C -->
            <xsl:apply-templates select="." mode="intterms"/>
          </div>
        </div>
      </div>

      <xsl:apply-templates select="." mode="internationalLabel">
        <xsl:with-param name="itemcount" select="$itemcount + 1"/>
        <xsl:with-param name="packagecount" select="$packagecount"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <!-- Template for international cons with packages -->
  <xsl:template match="PACKAGE" mode="internationalLabel">
    <xsl:param name="itemcount" select="0 + 1" />
    <xsl:param name="sectioncount" select="0 + ITEMS" />

    <xsl:if test="$itemcount &lt;= $sectioncount">
      <script type="text/Javascript">includePageBreak();</script>

      <!--start of main table -->
      <div class="outerLabel">
        <xsl:apply-templates select="." mode="intsystem"/>
        <!-- Inner visible table -->
        <div class="row innerLabelheight bordered">
          <div class="row secondrowheight bordered">
            <!-- Sender / Collection section -->
            <div class="collection bordered-right">
              <xsl:choose>
                <xsl:when test="../HEADER/COLLECTION/COMPANYNAME/text()">
                  <xsl:apply-templates select="../HEADER/COLLECTION" mode="int">
                    <xsl:with-param name="Account" select="../HEADER/SENDER/ACCOUNT"/>
                  </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="../HEADER/SENDER" mode="int">
                    <xsl:with-param name="Account" select="../HEADER/SENDER/ACCOUNT"/>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
            </div>
            <!-- Logo and Barcode section -->
            <div class="barcode">
              <xsl:apply-templates select="../CONNUMBER" mode="int"/>
              <!-- References section -->
              <xsl:choose>
                <xsl:when test="../CUSTOMERREF/text()">
                  <xsl:apply-templates select="../CUSTOMERREF" mode="intCustref"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="../CONNUMBER" mode="intCustref">
                    <xsl:with-param name="IsBlank">
                      <xsl:text>Y</xsl:text>
                    </xsl:with-param>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </div>
          <div class="row thirdrowheight bordered">
            <!-- Receiver / Delivery section -->
            <div class="delivery bordered-right">
              <xsl:choose>
                <xsl:when test="../DELIVERY/COMPANYNAME/text()">
                  <xsl:apply-templates select="../DELIVERY" mode="int" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="../RECEIVER" mode="int" />
                </xsl:otherwise>
              </xsl:choose>
            </div>
            <!-- Date, Description, Dimensions and Payment terms -->
            <div class="goods">
              <xsl:apply-templates select="../HEADER/SHIPMENTDATE" mode="int"/>
              <!-- Show InvoiceDescription or ArticleDescription or PackageDescription or General Description in this order of selection -->
              <xsl:choose>
                <xsl:when test="ARTICLE">
                  <xsl:choose>
                    <xsl:when test="ARTICLE/INVOICEDESC/text()">
                      <xsl:apply-templates select="ARTICLE/INVOICEDESC" mode="int"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="ARTICLE/DESCRIPTION" mode="int"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="GOODSDESC">
                  <xsl:apply-templates select="GOODSDESC" mode="int"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="../GOODSDESC1" mode="int"/>
                </xsl:otherwise>
              </xsl:choose>
              <!-- Show dimensions (only on Non-Documents) -->
              <xsl:apply-templates select="." mode="int"/>
              <!-- Show Payment terms only for receiver pays -->
              <xsl:apply-templates select="../PAYMENTIND" mode="int">
                <xsl:with-param name="ReceiverAccount" select="../RECEIVER/ACCOUNT"></xsl:with-param>
              </xsl:apply-templates>
            </div>
          </div>
          <div class="row fourthrowheight bordered">
            <!-- Special Instructions or (later) place for DG Instructions text -->
            <xsl:choose>
              <xsl:when test="../DELIVERYINST/text()">
                <xsl:apply-templates select="../DELIVERYINST" mode="intSpecInstr"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="../CONNUMBER" mode="intSpecInstr">
                  <xsl:with-param name="IsBlank">
                    <xsl:text>Y</xsl:text>
                  </xsl:with-param>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
            <!-- Dangerous Goods text -->
            <xsl:apply-templates select="../CONNUMBER" mode="intOptions">
              <xsl:with-param name="Option1" select="../OPTION1"/>
              <xsl:with-param name="Option2" select="../OPTION2"/>
              <xsl:with-param name="Option3" select="../OPTION3"/>
              <xsl:with-param name="Option4" select="../OPTION4"/>
              <xsl:with-param name="Option5" select="../OPTION5"/>
            </xsl:apply-templates>
          </div>
          <div class="row fifthrowheight bordered">
            <!-- Services and Options -->
            <xsl:apply-templates select="../." mode="int"/>
            <!-- Package number and weight -->
            <div class="packages bordered-right">
              <xsl:apply-templates select="../TOTALITEMS" mode="int">
                <xsl:with-param name="item" select="$itemcount"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="WEIGHT" mode="int">
                <xsl:with-param name="NameOfCaller" select="name(.)"/>
              </xsl:apply-templates>
            </div>
            <!-- T&C -->
            <xsl:apply-templates select="." mode="intterms"/>
          </div>
        </div>
      </div>

      <xsl:apply-templates select="." mode="internationalLabel">
        <xsl:with-param name="itemcount" select="$itemcount + 1"/>
        <xsl:with-param name="sectioncount" select="$sectioncount"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <!-- Template to match international addresses -->
  <xsl:template match="SENDER | RECEIVER | COLLECTION | DELIVERY" mode ="int">
    <xsl:param name="Account" />
    <div class="row Line70">
      <xsl:choose>
        <xsl:when test="name(.) = 'SENDER' or name(.) = 'COLLECTION'">
          <div class="senderheaderrow1">
            <font class="addressHeader">
              Sender :
            </font>
          </div>
          <div class="senderheaderrow2">
            <font class="addressHeader">
              TNT Account :
            </font>
            <font class="addressData">
              &#160;
              <xsl:value-of select="$Account"/>
            </font>
          </div>
        </xsl:when>
        <xsl:when test="name(.) = 'RECEIVER' or name(.) = 'DELIVERY'">
          <div class="senderheaderrow1">
            <font class="addressHeader">
              Delivery :
            </font>
          </div>
          <div class="senderheaderrow2">
            <font class="addressHeader">
              &#160;
            </font>
          </div>
        </xsl:when>
      </xsl:choose>
    </div>
    <font class="addressData">
      <div class="row address">
        <xsl:value-of select="COMPANYNAME"/>
      </div>
      <div class="row address">
        <xsl:value-of select="STREETADDRESS1"/>
      </div>
      <div class="row address">
        <xsl:choose>
          <xsl:when test="STREETADDRESS2/text()">
            <xsl:value-of select="STREETADDRESS2"/>
          </xsl:when>
          <xsl:otherwise>
            &#160;
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="row address">
        <xsl:choose>
          <xsl:when test="STREETADDRESS3/text()">
            <xsl:value-of select="STREETADDRESS3"/>
          </xsl:when>
          <xsl:otherwise>
            &#160;
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="row address">
        <xsl:value-of select="CITY"/>&#160;&#160;&#160;
      </div>
      <div class="row address">
        <xsl:choose>
          <xsl:when test="PROVINCE/text()">
            <xsl:value-of select="PROVINCE"/>
          </xsl:when>
          <xsl:otherwise>
            &#160;
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="row address">
        <xsl:if test="POSTCODE/text()">
          <xsl:value-of select="POSTCODE"/>&#160;&#160;&#160;
        </xsl:if>
        <xsl:value-of select="COUNTRY"/>
      </div>
    </font>
    <div class="contactsrow1">
      <font class="addressHeaderRec">
        <div class="row address">
          Contact:
        </div>
        <div class="row address">
          Tel:
        </div>
      </font>
    </div>
    <div class="contactsrow2">
      <font class="addressDataRec">
        <div class="row address">
          <xsl:value-of select="CONTACTNAME"/>
        </div>
        <div class="row address">
          <xsl:value-of select="CONTACTDIALCODE"/>&#160;
          <xsl:value-of select="CONTACTTELEPHONE"/>
        </div>
      </font>
    </div>
  </xsl:template>

  <!-- Template to match Barcode section -->
  <xsl:template match="CONNUMBER" mode="int">
    <div class="row centered">
      <img class="center" src="{$hostName}{$images_dir}/logo-small.gif" />
    </div>
    <div class="row centered" >
      <img style="height : 40px; " class="center">
        <xsl:attribute name="src">
          <xsl:value-of select="concat($hostName, $code39Barcode_url, .)" />
        </xsl:attribute>
      </img>
    </div>
    <div class="row Line70 centered">
      <font class="addressHeaderCode">
        <xsl:value-of select="concat('*', ., '*')"/>
      </font>
    </div>
  </xsl:template>

  <!-- Template to match Customer Reference section -->
  <xsl:template match="node()" mode="intCustref">
    <xsl:param name="IsBlank">
      <xsl:text>N</xsl:text>
    </xsl:param>
    <div class="row custref padded2">
      <font class="addressHeader">Sender Ref&#160;:&#160;</font>
      <font class="addressData">
        &#160;
        <xsl:if test="$IsBlank = 'N'">
          <xsl:value-of select="."/>
        </xsl:if>
      </font>
    </div>
  </xsl:template>

  <!-- Template to match Shipment Date section -->
  <xsl:template match="SHIPMENTDATE" mode="int">
    <div class="row Line70">
      <font class="addressHeader">Shipping Date&#160;:&#160;</font>
      <font class="addressData">
        <xsl:value-of select="."/>
      </font>
    </div>
  </xsl:template>

  <!-- Template to match Goods description -->
  <xsl:template match="INVOICEDESC | DESCRIPTION | GOODSDESC | GOODSDESC1" mode="int">
    <div class="row Line70">
      <font class="addressHeader">
        Description of Goods&#160;:&#160;
      </font>
      <br/>
      <font class="addressData">
        <xsl:value-of select="."/>
      </font>
    </div>
  </xsl:template>

  <!-- Template to match Dimensions section -->
  <xsl:template match="PACKAGE" mode="int">
    <div class="row Line70">
      <font class="addressHeader">Dimensions&#160;:&#160;</font>
      <!-- Show dimensions only on Non-Documents -->
      <br/>
      <xsl:if test="../CONSIGNMENTTYPE = 'N'">
        <font class="addressData">
          <xsl:choose>
            <xsl:when test="LENGTH/@units = 'cm'">
              <xsl:value-of select="format-number(LENGTH, '###')"/>
              <xsl:value-of select="LENGTH/@units"/>&#160;x&#160;<xsl:value-of select="format-number(WIDTH, '###')"/>
              <xsl:value-of select="WIDTH/@units"/>&#160;x&#160;<xsl:value-of select="format-number(HEIGHT, '###')"/>
              <xsl:value-of select="HEIGHT/@units"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="LENGTH"/>
              <xsl:value-of select="LENGTH/@units"/>&#160;x&#160;<xsl:value-of select="WIDTH"/>
              <xsl:value-of select="WIDTH/@units"/>&#160;x&#160;<xsl:value-of select="HEIGHT"/>
              <xsl:value-of select="HEIGHT/@units"/>
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- Template to show Payment Indicator section -->
  <xsl:template match="PAYMENTIND" mode="int">
    <xsl:param name="ReceiverAccount"/>

    <div class="row separatorheight">
      &#160;
    </div>
    <div class="row Line70">
      <xsl:choose>
        <xsl:when test=". = 'R'">
          <font class="addressHeader">RECEIVER PAYS</font>
          <br/>
          <font class="addressData">
            Receiver Account&#160;:&#160;
            <xsl:value-of select="$ReceiverAccount" />
          </font>
        </xsl:when>
        <xsl:otherwise>
          &#160;
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- Template to match Special Instructions section -->
  <xsl:template match="node()" mode="intSpecInstr">
    <xsl:param name="IsBlank">
      <xsl:text>N</xsl:text>
    </xsl:param>
    <div class="specinstructions bordered-right">
      <div class="row Line70">
        <font class="addressHeader">Special Delivery Instructions&#160;:&#160;</font>
        <font class="addressData">
          &#160;
          <xsl:if test="$IsBlank = 'N'">
            <xsl:value-of select="."/>
          </xsl:if>
        </font>
      </div>
    </div>
  </xsl:template>

  <!-- Template to match Dangerous Goods Indicator section -->
  <xsl:template match="CONNUMBER" mode="intOptions">
    <xsl:param name="Option1"/>
    <xsl:param name="Option2"/>
    <xsl:param name="Option3"/>
    <xsl:param name="Option4"/>
    <xsl:param name="Option5"/>

    <!-- Variable used with DG functionality -->
    <xsl:variable name="DG-Option1">
      <xsl:apply-templates select="$options-table">
        <xsl:with-param name="look-for">
          <xsl:choose>
            <xsl:when test="contains($Option1, ' ')">
              <xsl:value-of select="substring-before($Option1, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$Option1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="DG-Option2">
      <xsl:apply-templates select="$options-table">
        <xsl:with-param name="look-for">
          <xsl:choose>
            <xsl:when test="contains($Option2, ' ')">
              <xsl:value-of select="substring-before($Option2, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$Option2"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="DG-Option3">
      <xsl:apply-templates select="$options-table">
        <xsl:with-param name="look-for">
          <xsl:choose>
            <xsl:when test="contains($Option3, ' ')">
              <xsl:value-of select="substring-before($Option3, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$Option3"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="DG-Option4">
      <xsl:apply-templates select="$options-table">
        <xsl:with-param name="look-for">
          <xsl:choose>
            <xsl:when test="contains($Option4, ' ')">
              <xsl:value-of select="substring-before($Option4, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$Option4"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="DG-Option5">
      <xsl:apply-templates select="$options-table">
        <xsl:with-param name="look-for">
          <xsl:choose>
            <xsl:when test="contains($Option5, ' ')">
              <xsl:value-of select="substring-before($Option5, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$Option5"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>

    <div class="dgsection centered">
      <font class="addressDataRec">
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
  </xsl:template>

  <!-- Template to match the Services section -->
  <xsl:template match="CONSIGNMENT" mode="int">
    <div class="services bordered-right">
      <div class="row Line70">
        <font class="addressHeader">
          Service &amp; Options<br/>
        </font>
        <font class="addressData">
          <xsl:choose>
            <xsl:when test="contains(SERVICE, ' ')">
              <xsl:value-of select="concat('(', substring-before(SERVICE, ' '), ')&#160;', substring-after(SERVICE, ' '))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('(', SERVICE, ')&#160;')"/>
            </xsl:otherwise>
          </xsl:choose>
        </font>
      </div>
      <font class="addressDatasmall">
        <div class="row Line40">
          <xsl:if test="string-length(normalize-space(OPTION1)) != 0">
            <xsl:choose>
              <xsl:when test="contains(OPTION1, ' ')">
                <xsl:value-of select="concat('(', substring-before(OPTION1, ' '), ')&#160;', substring-after(OPTION1, ' '))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('(', OPTION1, ')&#160;')"/>
              </xsl:otherwise>
            </xsl:choose>
            <br/>
          </xsl:if>
          <xsl:if test="string-length(normalize-space(OPTION2)) != 0">
            <xsl:choose>
              <xsl:when test="contains(OPTION2, ' ')">
                <xsl:value-of select="concat('(', substring-before(OPTION2, ' '), ')&#160;', substring-after(OPTION2, ' '))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('(', OPTION2, ')&#160;')"/>
              </xsl:otherwise>
            </xsl:choose>
            <br/>
          </xsl:if>
          <xsl:if test="string-length(normalize-space(OPTION3)) != 0">
            <xsl:choose>
              <xsl:when test="contains(OPTION3, ' ')">
                <xsl:value-of select="concat('(', substring-before(OPTION3, ' '), ')&#160;', substring-after(OPTION3, ' '))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('(', OPTION3, ')&#160;')"/>
              </xsl:otherwise>
            </xsl:choose>
            <br/>
          </xsl:if>
          <xsl:if test="string-length(normalize-space(OPTION4)) != 0">
            <xsl:choose>
              <xsl:when test="contains(OPTION4, ' ')">
                <xsl:value-of select="concat('(', substring-before(OPTION4, ' '), ')&#160;', substring-after(OPTION4, ' '))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('(', OPTION4, ')&#160;')"/>
              </xsl:otherwise>
            </xsl:choose>
            <br/>
          </xsl:if>
          <xsl:if test="string-length(normalize-space(OPTION5)) != 0">
            <xsl:choose>
              <xsl:when test="contains(OPTION5, ' ')">
                <xsl:value-of select="concat('(', substring-before(OPTION5, ' '), ')&#160;', substring-after(OPTION5, ' '))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('(', OPTION5, ')&#160;')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </div>
      </font>
    </div>
  </xsl:template>

  <!-- Template to match totals -->
  <xsl:template match="TOTALITEMS" mode="int">
    <xsl:param name="item"/>

    <div class="row Line70">
      <font class="addressHeader">
        No. of Pieces
      </font>
    </div>
    <div class="row Line70">
      <font class="addressDataWeight">
        <xsl:value-of select="$item" />&#160;
        of
        <xsl:value-of select="." />
      </font>
    </div>
  </xsl:template>

  <!-- Template to match totals -->
  <xsl:template match="WEIGHT | TOTALWEIGHT" mode="int">
    <xsl:param name="NameOfCaller"/>

    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />

    <div class="row Line70">
      <font class="addressHeader">
        <xsl:value-of select="concat(substring($NameOfCaller, 1, 1), translate(substring($NameOfCaller, 2), $uppercase, $lowercase), ' Weight')"/>
      </font>
    </div>
    <div class="row Line70">
      <font class="addressDataWeight">
        <xsl:value-of select="format-number(., '####0.000')"/>&#160;
        <xsl:value-of select="./@units"/>
      </font>
    </div>
  </xsl:template>

  <!-- Template to match Terms and Conditions section -->
  <xsl:template match="CONSIGNMENT | PACKAGE" mode="intterms">
    <div class="TandC fifthrowmargin">
      <font class="addressSmallPrint">
        <div class="row Line30">
          OUR LIABILITY FOR LOSS, DAMAGE AND DELAY IS LIMITED BY THE CMR CONVENTION OR THE WARSAW CONVENTION WHICHEVER IS APPLICABLE. THE SENDER AGREES THAT CARRIAGE OF THIS CONSIGNMENT IS SUBJECT TO THE TERMS AND CONDITIONS WHICH CAN BE VIEWED AT
          <br/>
          <a href="WWW.TNT.COM">WWW.TNT.COM</a>,
          <br/>
          IF NO SERVICES OR BILLING OPTIONS ARE SELECTED THE FASTEST AVAILABLE SERVICE WILL BE CHARGED TO THE SENDER.
        </div>
      </font>
    </div>
  </xsl:template>

  <!-- Template to match Origin system row -->
  <xsl:template match="CONSIGNMENT | PACKAGE" mode="intsystem">
    <div class="row firstrowheight">
      <font class="addressSmallPrint">
        <div class="row Line30">
          ExpressConnect 3.0
        </div>
      </font>
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

</xsl:stylesheet>
