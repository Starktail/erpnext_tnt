<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="ItalianDomesticHtml">

<div id="boxIT">

  <!--Logo-->
  <div id="logoIT">
    <img src='{$images_dir}/logo.jpg' alt='logo' id="tntLogo" />
  </div>
  
  <!--Market & Transport Type-->
  <div id="marketAndTransportTypeIT">
    <xsl:value-of select="../consignmentLabelData/marketDisplay"/>
    <xsl:text> / </xsl:text>
    <xsl:value-of select="../consignmentLabelData/transportDisplay"/>
  </div>
  
  <!--Hazardous-->
  <div id="hazardousIT">
      <xsl:for-each select="../consignmentLabelData/option">
          <xsl:if test="@id='HZ'">
             <xsl:text>HAZARDOUS</xsl:text>
          </xsl:if>
      </xsl:for-each>
  </div>
  
  <!--X-RAY-->
  <xsl:if test="string-length(../consignmentLabelData/xrayDisplay)>0">
    <div id="xrayIT">
      <xsl:value-of select="../consignmentLabelData/xrayDisplay"/>
    </div>
  </xsl:if>

  <!--Free Circulation Display--> 
  <xsl:choose>
    <xsl:when test="string-length(../consignmentLabelData/freeCirculationDisplay)>0">
      <div id="freeCirculationIndicatorIT" style="background-color: #000000;color: #FFFFFF;">
        <xsl:value-of select="../consignmentLabelData/freeCirculationDisplay"/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <div id="freeCirculationIndicatorIT" style="background-color: #000000;color: #000000;">
      <xsl:text> </xsl:text>
      </div>
    </xsl:otherwise>
  </xsl:choose>

  <!--Sort Split Indicator-->
  <xsl:choose>
    <xsl:when test="string-length(../consignmentLabelData/sortSplitText)>0">
        <div id="sortSplitIndicatorIT">
            <xsl:value-of select="../consignmentLabelData/sortSplitText" />
        </div>
    </xsl:when>
    <xsl:otherwise>
        <div id="sortSplitIndicatorIT">
            <xsl:text> </xsl:text>
        </div>
    </xsl:otherwise>
  </xsl:choose>

  <!--Consignment Number-->
  <div id="conNumberIT">
    <div id="conNumberHeaderIT">L.V.</div>
    <div id="conNumberDetailIT"><xsl:value-of select="../consignmentLabelData/consignmentNumber"/></div>
  </div>

  <!--Service-->
  <div id="serviceIT">
    <div id="serviceHeaderIT">Servizio</div>
    <xsl:choose>
        <xsl:when test="string-length(../consignmentLabelData/product)>15">
            <span id="serviceDetailIT" style="font-size: 15px;">
                <xsl:value-of select="../consignmentLabelData/product" />
            </span>
        </xsl:when>
        <xsl:otherwise>
            <span id="serviceDetailIT" style="font-size: 20px;">
                <xsl:value-of select="../consignmentLabelData/product" />
            </span>
        </xsl:otherwise>
    </xsl:choose>
  </div>
  
  <!--Options-->
  <div id="optionIT">
    <span id="optionHeaderIT">Opzione</span>
    <br />
    <xsl:variable name="numberOptions" select="count(../consignmentLabelData/option)" />    
        <xsl:choose>
            <!--If there are multiple options then display option id only-->
            <xsl:when test="$numberOptions >1">
              <xsl:for-each select="../consignmentLabelData/option">
                <span id="optionDetailIT">
                    <xsl:value-of select="@id" />
                    <xsl:text>  </xsl:text>
                </span>
              </xsl:for-each>
            </xsl:when>
            <!--If there is only one option then display the option description-->
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length(../consignmentLabelData/option)>0">
                      <span id="optionDetailIT">
                        <xsl:value-of select="../consignmentLabelData/option" />
                      </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span id="optionDetailIT">
                            <xsl:text> </xsl:text>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>   
  </div>

  <!--Pieces-->
  <div id="pieceIT">
    <span id="pieceHeaderIT">
        Collo
        <br />
    </span>

    <span id="pieceDetailIT"><xsl:value-of select="pieceNumber"/> of <xsl:value-of select="../consignmentLabelData/totalNumberOfPieces"/></span>
  </div>
  
  <!--Weight-->
  <div id="weightIT">
    <span id="weightHeaderIT">
        Paso
        <br />
    </span>
    <xsl:choose>
        <xsl:when test="weightDisplay/@renderInstructions='highlighted'">
            <span id="weightDetailHighlightedIT">
                <xsl:value-of select="weightDisplay" />
            </span>
        </xsl:when>
        <xsl:otherwise>
            <span id="weightDetailIT">
                <xsl:value-of select="weightDisplay" />
            </span>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
  </div>

  <!--Customer Info & Account Number-->
  <div id="contactInfoIT">
      <span id="contactInfoHeaderIT">Mitt: </span>
      <span id="contactInfoDetailIT"><xsl:value-of select="../consignmentLabelData/contact/name" disable-output-escaping="yes" /></span>
  </div>
  <div id="referenceIT">
      <span id="referenceHeaderIT">Rif.Cli.: </span>
      <span id="referenceDetailIT"><xsl:value-of select="pieceReference" disable-output-escaping="yes" /></span>
  </div>
  <div id="accountNumberIT">
      <span id="accountNumberHeaderIT">Codica Cliente Mittente</span>
      <span id="accountNumberDetailIT"><xsl:value-of select="../consignmentLabelData/account/accountNumber" /></span>
  </div>

  <!--Origin Depot & Pickup Date-->
  <div id="originDepotIT">
    <span id="originDepotHeaderIT">Filiali Partenza</span>
    <br />
    <span id="originDepotDetailIT"><xsl:value-of select="../consignmentLabelData/originDepot/depotCode" /></span>
  </div>
  <div id="pickupDateIT">
    <span id="pickupDateHeaderIT">Data Partenza</span>
    <br />
    <span id="pickupDateDetailIT">
      <xsl:call-template name="FormatDate">    
                <xsl:with-param name="DateTime" select="../consignmentLabelData/collectionDate"/> 
        </xsl:call-template>    
    </span>
  </div>


  <!--Origin Address & Delivery Address-->
  <div id="originAddressIT">
      <span id="originAddressHeaderIT"></span>
      <div id="originAddressDetailIT">      
      </div>
  </div>
  <div id="deliveryAddressIT" style="clear:left">
      <span id="deliveryAddressHeaderIT">Indirizzo di consegna</span>
      <br />
      <div id="deliveryAddressDetailIT">
      <xsl:value-of select="../consignmentLabelData/delivery/name" disable-output-escaping="yes"/><br />
      <xsl:value-of select="../consignmentLabelData/delivery/addressLine1" disable-output-escaping="yes"/><br />
      <xsl:value-of select="../consignmentLabelData/delivery/addressLine2" disable-output-escaping="yes"/><br />
      <xsl:value-of select="../consignmentLabelData/delivery/town" disable-output-escaping="yes"/><xsl:text>  </xsl:text>   
      <xsl:value-of select="../consignmentLabelData/delivery/postcode"/><br />
      <xsl:value-of select="../consignmentLabelData/delivery/country"/> 
      </div>
  </div>

  <!-- Route Details-->
  <div id="routingIT">
    <span id="routingHeaderIT">Instradamento</span>
    <div id="routingDetailIT">
    
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
  <div id="sortIT">
      <span id="sortDetailIT">
        <xsl:value-of select="../consignmentLabelData/transitDepots/sortDepot/depotCode" />
        <xsl:text> </xsl:text>
      </span>
  </div>
  
  <!--Microzona code-->
  <div id="microzonaHeaderIT">
    Microzona
  </div>
  <div id="microzonaIT">
    <span id="microzonaDetailIT">
      <xsl:value-of select="../consignmentLabelData/microzone"/>
    </span>
  </div>
  
  <!-- Bulk Shipment flag -->
  <div id="bulkShipmentHeaderIT">
  </div>
  <div id="bulkShipmentIT">
    <xsl:if test="../consignmentLabelData/bulkShipment/@renderInstructions='yes'">
       <span id="bulkShipmentDetailIT">
        P
       </span>
    </xsl:if>
  </div>
  
  <!--Destination Depot-->
  <div id="destinationDepotHeaderIT">
      Filiali
      <br />
      Arrivo
  </div>
  <div id="destinationDepotDetailIT"> 
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
  <div id="barcodeIT" name="barcodeIT">
    <img>
       <xsl:attribute name="src">
         <xsl:value-of select="concat($barcode_url,barcode)" />
       </xsl:attribute> 
    </img>
  </div>
  <div id="barcodeLabelIT">
     <xsl:value-of select="barcode" />
  </div>
</div> 
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