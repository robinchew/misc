<?php

/**
 * Handles access to share link elements
 * 
 * @author Chris Darby
 * @version 1.0
 * @package sharelink
 */

class Clients {
    
    /**
     * Checks if client has access to certain share link features
     * 
     * @param string $has Share link feature such as graph, share, xml, announcements etc
     * @param string $clientid MD5 hash of the client ID
     * @return boolean
     */
    public function hasAccess($has,$clientid) {
        $get = mysql_query("select has_".$has." from clients_features where md5(clients_id) = '".$clientid."'");
        $result = mysql_fetch_array($get);
            $type = $result["has_".$has];
            
            if ($type == 1) {
                return true;
            } else {
                return false;
            }
    }
    
    /**
     * Checks if client has access to certain symbols
     * 
     * @param string $has Share link feature such as graph, share, xml, announcements etc
     * @param string $clientid MD5 hash of the client ID
     * @return boolean
     */
    public function hasSymbol($clientid,$symbol) {
        $query = "select id from clients_stocks where md5(clients_id) = '".$clientid."' and stocks_id in (select id from stocks where symbol = '".$symbol."') limit 1";
        
        $get = mysql_query($query);
        $num = mysql_num_rows($get);
            if ($num == 1) {
                return true;
            } else {
                $query = "select id from clients_commodities where md5(clients_id) = '".$clientid."' and commodities_indicies_id in (select id from commodities_indicies where symbol = '".$symbol."')";

                $get = mysql_query($query);
                $num = mysql_num_rows($get);
                if ($num == 1) {
                    return true;
                } else {
                    return false;
                }
            }
    }
    
}
?>
