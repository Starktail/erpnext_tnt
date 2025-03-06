<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="RestOfWorldHtml">

<div id="box">
  <!--Logo-->
  <div id="logo">
    <img src='logo_orig.jpg' alt='logo' id="tntLogo" />
  </div>
  
  <!--Market & Transport Type-->
  <div id="marketAndTransportType">
    <xsl:value-of select="../consignmentLabelData/marketDisplay"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="../consignmentLabelData/transportDisplay"/>
  </div>
  
  <!--Hazardous-->
  <div id="hazardous">
      <xsl:for-each select="../consignmentLabelData/option">
          <xsl:if test="@id='HZ'">
             <xsl:text>HAZARDOUS</xsl:text>
          </xsl:if>
      </xsl:for-each>
  </div>
  
  <!--X-RAY-->
  <xsl:if test="string-length(../consignmentLabelData/xrayDisplay)>0">
    <div id="xray">
      <xsl:value-of select="../consignmentLabelData/xrayDisplay"/>
    </div>
  </xsl:if>

  <!--Free Circulation Display--> 
  <xsl:choose>
    <xsl:when test="string-length(../consignmentLabelData/freeCirculationDisplay)>0">
      <div id="freeCirculationIndicator" style="background-color: #000000;color: #FFFFFF;">
        <xsl:value-of select="../consignmentLabelData/freeCirculationDisplay"/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <div id="freeCirculationIndicator" style="background-color: #000000;color: #000000;">
      <xsl:text> </xsl:text>
      </div>
    </xsl:otherwise>
  </xsl:choose>

  <!--Sort Split Indicator-->
  <xsl:choose>
    <xsl:when test="string-length(../consignmentLabelData/sortSplitText)>0">
        <div id="sortSplitIndicator">
            <xsl:value-of select="../consignmentLabelData/sortSplitText" />
        </div>
    </xsl:when>
    <xsl:otherwise>
        <div id="sortSplitIndicator">
            <xsl:text> </xsl:text>
        </div>
    </xsl:otherwise>
  </xsl:choose>

  <!--Consignment Number-->
  <div id="conNumber">
    <div id="conNumberHeader">Con No.</div>
    <div id="conNumberDetail"><xsl:value-of select="../consignmentLabelData/consignmentNumber"/></div>
  </div>

  <!--Service-->
  <div id="service">
    <div id="serviceHeader">Service</div>
    <xsl:choose>
        <xsl:when test="string-length(../consignmentLabelData/product)>15">
            <span id="serviceDetail" style="font-size: 17px;">
                <xsl:value-of select="../consignmentLabelData/product" />
            </span>
        </xsl:when>
        <xsl:otherwise>
            <span id="serviceDetail" style="font-size: 20px;">
                <xsl:value-of select="../consignmentLabelData/product" />
            </span>
        </xsl:otherwise>
    </xsl:choose>
  </div>

  <!--Pieces-->
  <div id="piece">
    <span id="pieceHeader">
        Piece
        <br />
    </span>

    <span id="pieceDetail"><xsl:value-of select="pieceNumber"/> of <xsl:value-of select="../consignmentLabelData/totalNumberOfPieces"/></span>
  </div>
  
  <!--Weight-->
  <div id="weight">
    <span id="weightHeader">
        Weight
        <br />
    </span>
    <xsl:choose>
        <xsl:when test="weightDisplay/@renderInstructions='highlighted'">
            <span id="weightDetailHighlighted">
                <xsl:value-of select="weightDisplay" />
            </span>
        </xsl:when>
        <xsl:otherwise>
            <span id="weightDetail">
                <xsl:value-of select="weightDisplay" />
            </span>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
  </div>
  
  <!--Options-->
  <div id="option">
    <span id="optionHeader">Option</span>
    <br />
    <xsl:variable name="numberOptions" select="count(../consignmentLabelData/option)" />    
        <xsl:choose>
            <!--If there are multiple options then display option id only-->
            <xsl:when test="$numberOptions >1">
              <xsl:for-each select="../consignmentLabelData/option">
                <span id="optionDetail">
                    <xsl:value-of select="@id" />
                    <xsl:text>  </xsl:text>
                </span>
              </xsl:for-each>
            </xsl:when>
            <!--If there is only one option then display the option description-->
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length(../consignmentLabelData/option)>0">
                      <span id="optionDetail">
                        <xsl:value-of select="../consignmentLabelData/option" />
                      </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span id="optionDetail">
                            <xsl:text> </xsl:text>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>   
  </div>

  <!--Customer Reference & Account Number-->
  <div id="customerReference">
      <div id="customerReferenceHeader">Customer Reference</div>
      <div id="customerReferenceDetail"><xsl:value-of select="pieceReference" disable-output-escaping="yes" /></div>
  </div>
  <div id="accountNumber">
      <span id="accountNumberHeader">S/R Account No</span>
      <span id="accountNumberDetail"><xsl:value-of select="../consignmentLabelData/account/accountNumber" /></span>
  </div>

  <!--Origin Depot & Pickup Date-->
  <div id="originDepot">
    <span id="originDepotHeader">Origin</span>
    <span id="originDepotDetail"><xsl:value-of select="../consignmentLabelData/originDepot/depotCode" /></span>
  </div>
  <div id="pickupDate">
    <span id="pickupDateHeader">Pickup Date</span>
    <br />
    <span id="pickupDateDetail">
      <xsl:call-template name="FormatDate">    
                <xsl:with-param name="DateTime" select="../consignmentLabelData/collectionDate"/> 
        </xsl:call-template>    
    </span>
  </div>


  <!--Origin Address & Delivery Address-->
  <div id="originAddress">
      <span id="originAddressHeader">Sender Address</span>
      <br />
      <div id="originAddressDetail">
      <xsl:value-of select="../consignmentLabelData/sender/name" disable-output-escaping="yes"/><br />
      <xsl:value-of select="../consignmentLabelData/sender/addressLine1" disable-output-escaping="yes"/><br />
      <xsl:value-of select="../consignmentLabelData/sender/addressLine2" disable-output-escaping="yes"/><br />
      <xsl:value-of select="../consignmentLabelData/sender/town" disable-output-escaping="yes"/><xsl:text>  </xsl:text>   
      <xsl:value-of select="../consignmentLabelData/sender/postcode"/><br />
      <xsl:value-of select="../consignmentLabelData/sender/country"/>       
      </div>
  </div>
  <div id="deliveryAddress" style="clear:left">
      <span id="deliveryAddressHeader">Delivery Address</span>
      <br />
      <div id="deliveryAddressDetail">
      <xsl:value-of select="../consignmentLabelData/delivery/name" disable-output-escaping="yes"/><br />
      <xsl:value-of select="../consignmentLabelData/delivery/addressLine1" disable-output-escaping="yes"/><br />
      <xsl:value-of select="../consignmentLabelData/delivery/addressLine2" disable-output-escaping="yes"/><br />
      <xsl:value-of select="../consignmentLabelData/delivery/town" disable-output-escaping="yes"/><xsl:text>  </xsl:text>   
      <xsl:value-of select="../consignmentLabelData/delivery/postcode"/><br />
      <xsl:value-of select="../consignmentLabelData/delivery/country"/> 
      </div>
  </div>

  <!-- Route Details-->
  <div id="routing">
    <span id="routingHeader">Routing</span>
    <div id="routingDetail">
    
         <!-- Check if route includes any transit depots-->
         <xsl:if test="count(../consignmentLabelData/transitDepots/*)=0">
             <xsl:text> </xsl:text>
         </xsl:if>
         
        <xsl:for-each select="../consignmentLabelData/transitDepots/*">

            <xsl:if test="name(self::node()[position()])='transitDepot'">
                <xsl:value-of select="depotCode" />
                <br />
            </xsl:if>

            <xsl:if test="name(self::node()[position()])='actionDepot'">
                <xsl:value-of select="depotCode" />
                <xsl:text>-</xsl:text>
                <xsl:value-of select="actionDayOfWeek" />
                <br />
            </xsl:if>

            <xsl:if test="name(self::node()[position()])='sortDepot'">
                <xsl:value-of select="depotCode" />
                <xsl:text>-</xsl:text>
                <xsl:value-of select="sortCellIndicator" />
                <br />
            </xsl:if>

        </xsl:for-each>
    </div>
  </div>
  

  <!--Sort Details-->
  <div id="sort">
      <span id="sortHeader">Sort</span>
      <span id="sortDetail">
        <xsl:value-of select="../consignmentLabelData/transitDepots/sortDepot/depotCode" />
        <xsl:text> </xsl:text>
      </span>
  </div>
  
  <!--Postcode/Cluster code-->
  <div id="postcodeHeader">Postcode /
      <br />
      Cluster Code
  </div>
  <div id="postcode">
    <xsl:choose>
    <!--If the length of the Cluster code is greater than 3 then the post code is being displayed
    instead, so different rendering applies-->
      <xsl:when test="string-length(../consignmentLabelData/clusterCode)>3">
        <span id="postcodeDetail"><xsl:value-of select="../consignmentLabelData/delivery/postcode"/></span>
      </xsl:when>
      <xsl:otherwise>
        <span id="clustercodeDetail"><xsl:value-of select="../consignmentLabelData/clusterCode"/></span>
      </xsl:otherwise>
    </xsl:choose>
  </div>
  
  <!--Destination Depot-->
  <div id="destinationDepotHeader">
      Dest
      <br />
      Depot
  </div>
  <div id="destinationDepotDetail"> 
    <xsl:choose> 
      <xsl:when test="../consignmentLabelData/destinationDepot/dueDayOfWeek/@renderInstructions='highlighted'">
        <xsl:value-of select="../consignmentLabelData/destinationDepot/depotCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="../consignmentLabelData/destinationDepot/dueDayOfMonth"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="../consignmentLabelData/destinationDepot/depotCode"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="../consignmentLabelData/destinationDepot/dueDayOfMonth"/>
      </xsl:otherwise>   
    </xsl:choose>
  </div>
  
  <!--Barcode-->
  <xsl:variable name="barcode_url" select='"https://express.tnt.com/barbecue/barcode?type=Code128C&amp;height=140&amp;width=2&amp;data="' />
  <div id="barcode" name="barcode">
    <img>
       <xsl:attribute name="src">
         <xsl:value-of select="concat($barcode_url,barcode)" />
       </xsl:attribute> 
    </img>
  </div>
  <div id="barcodeLabel">
     <xsl:value-of select="barcode" />
  </div>
</div> 

 <br> 
 <xsl:choose>
	<xsl:when test="pieceNumber = (../consignmentLabelData/totalNumberOfPieces)">
    <xsl:call-template name="LastPage">                    
    </xsl:call-template>    
	<xsl:text>Last Page</xsl:text>
 </xsl:when>
	<xsl:otherwise>
	<xsl:call-template name="PageBreak">                    
    </xsl:call-template>    
	<xsl:text>Not Last Page</xsl:text>
	</xsl:otherwise>
 </xsl:choose>
</br>
<!-- 	<xsl:choose>
        on the last page 
        <xsl:when test="pieceNumber = (../consignmentLabelData/totalNumberOfPieces)"/>
		<xsl:when test="$page = (../consignmentLabelData/totalNumberOfPieces)"/>
			<br style="page-break-after:never;"/>
		</xsl:when>
		
		<xsl:otherwise>
			<br style="page-break-after:always;"/>
		</xsl:otherwise>
    </xsl:choose> -->


    
</xsl:template>

<xsl:template name="PageBreak">
<br style="page-break-before:always;"/>
</xsl:template>
<xsl:template name="LastPage">
<br style="page-break-before:always"/>
</xsl:template>

<xsl:template name="FormatDate">
    <!-- expected date format 2008 06 16 -->
    <xsl:param name="DateTime" />
    <!-- new date format 20 June 2007 -->
    <xsl:variable name="year">
        <xsl:value-of select="substring-before($DateTime,'-')" />
    </xsl:variable>
    <xsl:variable name="mo-temp">
        <xsl:value-of select="substring-after($DateTime,'-')" />
    </xsl:variable>
    <xsl:variable name="mo">
        <xsl:value-of select="substring-before($mo-temp,'-')" />
    </xsl:variable>
    <xsl:variable name="day">
        <xsl:value-of select="substring-after($mo-temp,'-')" />
    </xsl:variable>

    <xsl:value-of select="$day" />
    <xsl:text> </xsl:text>
    <xsl:choose>
        <xsl:when test="$mo = '1' or $mo = '01'">Jan</xsl:when>
        <xsl:when test="$mo = '2' or $mo = '02'">Feb</xsl:when>
        <xsl:when test="$mo = '3' or $mo = '03'">Mar</xsl:when>
        <xsl:when test="$mo = '4' or $mo = '04'">Apr</xsl:when>
        <xsl:when test="$mo = '5' or $mo = '05'">May</xsl:when>
        <xsl:when test="$mo = '6' or $mo = '06'">Jun</xsl:when>
        <xsl:when test="$mo = '7' or $mo = '07'">Jul</xsl:when>
        <xsl:when test="$mo = '8' or $mo = '08'">Aug</xsl:when>
        <xsl:when test="$mo = '9' or $mo = '09'">Sep</xsl:when>
        <xsl:when test="$mo = '10'">Oct</xsl:when>
        <xsl:when test="$mo = '11'">Nov</xsl:when>
        <xsl:when test="$mo = '12'">Dec</xsl:when>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$year" />
</xsl:template>

</xsl:stylesheet>