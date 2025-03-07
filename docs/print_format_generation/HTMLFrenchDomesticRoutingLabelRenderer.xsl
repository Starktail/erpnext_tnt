<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:template name="FrenchDomesticHtml">

<div id="boxFR">

  <!--Logo-->
  <div id="logoFR">
    <img src='{$images_dir}/logo.jpg' alt='logo' id="tntLogo" />
  </div>
  
    <!--Contact Details-->
    <div id="contactDetailsFR">
      <table id="contactDetailsTableFR">
        <tr>
          <td>Service Client </td>
          <td>: +33(0)825 033 033</td>
        </tr>
        <tr>
          <td>Fax </td>
          <td>: +33(0)825 031 021</td>
        </tr>
        <tr>
          <td>Web </td>
          <td>: www.tnt.fr</td>
        </tr>
      </table>
    </div>

    <!--Legal Comments-->
    <div id="legalCommentsFR">
      <xsl:value-of select="../consignmentLabelData/legalComments"/>
    </div>

  <!--Consignment Number-->
  <div id="conNumberFR">
    <div id="conNumberDetailFR"><xsl:value-of select="../consignmentLabelData/consignmentNumber"/></div>
  </div>

  <!--Service-->
  <div id="serviceFR">
    <xsl:choose>
        <xsl:when test="string-length(../consignmentLabelData/product)>15">
            <span id="serviceDetailFR" style="font-size: 17px;">
                <xsl:value-of select="../consignmentLabelData/product" />
            </span>
        </xsl:when>
        <xsl:otherwise>
            <span id="serviceDetailFR" style="font-size: 20px;">
                <xsl:value-of select="../consignmentLabelData/product" />
            </span>
        </xsl:otherwise>
    </xsl:choose>
  </div>

  <!--Pieces-->
  <div id="pieceFR">
    <span id="pieceDetailFR"><xsl:value-of select="pieceNumber"/> sur <xsl:value-of select="../consignmentLabelData/totalNumberOfPieces"/></span>
  </div>
  
  <!--Weight-->
  <div id="weightFR">
    <xsl:choose>
        <xsl:when test="weightDisplay/@renderInstructions='highlighted'">
            <span id="weightDetailHighlightedFR">
                <xsl:value-of select="weightDisplay" />
            </span>
        </xsl:when>
        <xsl:otherwise>
            <span id="weightDetailFR">
                <xsl:value-of select="weightDisplay" />
            </span>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
  </div>
  
  <!--Options-->
  <div id="optionFR">
    <xsl:variable name="numberOptions" select="count(../consignmentLabelData/option)" />    
        <xsl:choose>
            <!--If there are multiple options then display option id only-->
            <xsl:when test="$numberOptions > 1">
              <xsl:for-each select="../consignmentLabelData/option">
                <span id="optionDetailFR">
                    <xsl:value-of select="@id" />
                    <xsl:text>  </xsl:text>
                </span>
              </xsl:for-each>
            </xsl:when>
            <!--If there is only one option then display the option description-->
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length(../consignmentLabelData/option)>0">
                      <span id="optionDetailFR">
                        <xsl:value-of select="../consignmentLabelData/option" />
                      </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span id="optionDetailFR">
                            <xsl:text> </xsl:text>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>   
  </div>
  
  <!-- Customer Reference Barcode -->
  <div id="customerReferenceBarcodeFR" name="customerReferenceBarcodeFR">
      <img width="240px" height="13px">
          <xsl:if test="string-length(barcodeForCustomer) > 0">
			  <xsl:attribute name="src">
			      <xsl:value-of select="concat($code128Bbarcode_url,barcodeForCustomer)" />
              </xsl:attribute>
          </xsl:if> 
      </img>
  </div>

  <!--Customer Reference & Account Number-->
  <div id="customerReferenceFR">
      <span id="customerReferenceHeaderFR">Ref: </span>
      <span id="customerReferenceDetailFR"><xsl:value-of select="pieceReference" disable-output-escaping="yes" /></span>
  </div>
  <div id="accountNumberFR">
      <span id="accountNumberHeaderFR">Cpt: </span>
      <span id="accountNumberDetailFR"><xsl:value-of select="../consignmentLabelData/account/accountNumber" /></span>
  </div>
  
  <!-- Delivery Depot -->
  <div id="deliveryDepotFR">
    <xsl:if test="string-length(../consignmentLabelData/delivery/postcode) >= 2">
        <xsl:value-of select="substring(../consignmentLabelData/delivery/postcode,1,2)"/>
    </xsl:if>
  </div>

  <!--Origin Address & Delivery Address-->
  <div id="originAddressLabelFR">Exp:</div>
  <div id="originAddressFR" style="clear:left">
      <div id="originAddressDetailFR">
	      <xsl:value-of select="../consignmentLabelData/sender/name" disable-output-escaping="yes"/><br />
	      <xsl:value-of select="../consignmentLabelData/sender/addressLine1" disable-output-escaping="yes"/><br />
	      <xsl:if test="string-length(../consignmentLabelData/sender/addressLine2) > 0">
	          <xsl:value-of select="../consignmentLabelData/sender/addressLine2" disable-output-escaping="yes"/><br />
	      </xsl:if>
	      <xsl:value-of select="../consignmentLabelData/sender/postcode"/><xsl:text>  </xsl:text>   
	      <xsl:value-of select="../consignmentLabelData/sender/town" disable-output-escaping="yes"/><br />
	      <xsl:value-of select="../consignmentLabelData/sender/country"/>       
      </div>
  </div>
  <div id="deliveryAddressLabelFR">Dest:</div>
  <div id="deliveryAddressFR" style="clear:left">
      <!--span id="deliveryAddressHeaderFR">Dest:</span-->
      <div id="deliveryAddressDetailFR">
      <xsl:value-of select="../consignmentLabelData/delivery/name" disable-output-escaping="yes"/><br />
      <xsl:value-of select="../consignmentLabelData/delivery/addressLine1" disable-output-escaping="yes"/><br />
      <xsl:if test="string-length(../consignmentLabelData/delivery/addressLine2) > 0">
        <xsl:value-of select="../consignmentLabelData/delivery/addressLine2" disable-output-escaping="yes"/><br />
      </xsl:if>
      <xsl:value-of select="../consignmentLabelData/delivery/postcode"/><xsl:text>  </xsl:text>   
      <xsl:value-of select="../consignmentLabelData/delivery/town" disable-output-escaping="yes"/><br />
      <xsl:value-of select="../consignmentLabelData/delivery/country"/> 
      </div>
  </div>

  <!--Special Instructions-->
  <div id="specialInstructionsFR">
    <xsl:if test="string-length(../consignmentLabelData/specialInstructions) > 0">
        <xsl:value-of select="substring(../consignmentLabelData/specialInstructions,1,65)" />
    </xsl:if>
  </div>
  
  <!-- Contact Name -->
  <div id="contactNameFR">
      <span id="contactNameHeaderFR">Nom du Contact: </span>
      <span id="contactNameDetailFR">
          <xsl:if test="string-length(../consignmentLabelData/contact) > 0">
		      <xsl:value-of select="../consignmentLabelData/contact/name" />
		  </xsl:if>
      </span>
  </div>
  
  <!-- Contact Phone -->
  <div id="contactPhoneFR">
      <span id="contactPhoneHeaderFR">Tel: </span>
      <span id="contactPhoneDetailFR">
          <xsl:if test="string-length(../consignmentLabelData/contact) > 0">
              <xsl:value-of select="../consignmentLabelData/contact/telephoneNumber" />
          </xsl:if>
      </span>
  </div>
  
  <!--Postcode/Cluster code-->
  <div id="postcodeHeaderFR">Code Postal /
      <br />
      Code Satellite
  </div>
  <div id="postcodeFR">
      <span id="postcodeDetailFR"><xsl:value-of select="../consignmentLabelData/delivery/postcode"/></span>
  </div>
  
  <!--Pickup Date-->
  <div id="pickupDateFR">
    <span id="pickupDateHeaderFR">Date Ramassage: </span>
    <span id="pickupDateDetailFR">
      <xsl:call-template name="FormatDateFrenchDomestic">    
                <xsl:with-param name="DateTime" select="../consignmentLabelData/collectionDate"/> 
        </xsl:call-template>    
    </span>
  </div>
  
  <!--CashAmount-->
  <div id="cashAmountFR">
	  <xsl:for-each select="../consignmentLabelData/option">
	      <xsl:if test="@id='CO' or @id='RP'">
	         <xsl:value-of select="../cashAmount"/>
	      </xsl:if>
	  </xsl:for-each>
  </div>
    
  <!--Barcode-->
  <div id="barcodeFR" name="barcodeFR">
    <img>
       <xsl:attribute name="src">
         <xsl:value-of select="concat($int2of5barcode_url,barcode)" />
       </xsl:attribute> 
    </img>
  </div>
  <div id="barcodeLabelFR">
     <xsl:value-of select="barcode" />
  </div>
</div> 
<br style="page-break-before:always"/>

</xsl:template>

<xsl:template name="FormatDateFrenchDomestic">
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
        <xsl:when test="$mo = '1' or $mo = '01'">01</xsl:when>
        <xsl:when test="$mo = '2' or $mo = '02'">02</xsl:when>
        <xsl:when test="$mo = '3' or $mo = '03'">03</xsl:when>
        <xsl:when test="$mo = '4' or $mo = '04'">04</xsl:when>
        <xsl:when test="$mo = '5' or $mo = '05'">05</xsl:when>
        <xsl:when test="$mo = '6' or $mo = '06'">06</xsl:when>
        <xsl:when test="$mo = '7' or $mo = '07'">07</xsl:when>
        <xsl:when test="$mo = '8' or $mo = '08'">08</xsl:when>
        <xsl:when test="$mo = '9' or $mo = '09'">09</xsl:when>
        <xsl:when test="$mo = '10'">10</xsl:when>
        <xsl:when test="$mo = '11'">11</xsl:when>
        <xsl:when test="$mo = '12'">12</xsl:when>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$year" />
</xsl:template>
    
</xsl:stylesheet>