<?php

/**
 * Share Link Database Model
 * 
 * @author Chris Darby
 * @version 1.0
 *  
 */
class Sharelink_Model extends Model {

    /**
     * Adds a new client
     * 
     * @return boolean 
     */
    public function addClient() {
        $name = $_POST["client-name"];
        $domain = $_POST["client-domain"];
        $email = $_POST["client-email"];
        $subscription = $_POST["subscription-type"];
        if (isset($_POST["stock-data"])) {
            $stocks = $_POST["stock-data"];
        }
        $type = $_POST["data-type"];
        $market = $_POST["data-market"];

        $stock_code = $_POST["stock-code"];
        $commodity_code = $_POST["commodity-code"];
        $client_announcements = $_POST["client-announcements"];
        $client_notification = $_POST["client-notification"];

        $license = $this->generateLicense($name, $domain);

        $insert = Array(
            "name" => $name,
            "domain" => $domain,
            "license" => $license,
            "email" => $email,
            "timezone" => "GMT+8"
        );

        $result = $this->db->insert("clients", $insert);
        $client = $result->insert_id();

        if ($subscription == "bronze") {
            if ($type == "stock-price") {
                $existing = $this->checkIfStockExists($stock_code, $market);

                if (!$existing) {
                    $existing = $this->addNewStock($stock_code, $market);
                }

                $client_stocks = Array(
                    "clients_id" => $client,
                    "stocks_id" => $existing
                );

                $this->db->insert("clients_stocks", $client_stocks);
            } else if ($type == "commodity") {
                $client_commodities = Array(
                    "clients_id" => $client,
                    "commodities_indicies_id" => $commodity_code
                );

                $this->db->insert("clients_commodities", $client_commodities);
            }
        } else if ($subscription == "silver") {
            $this->addClientStocks($client, $stocks);
        } else if ($subscription == "gold") {
            $this->addClientStocks($client, $stocks);
        }

        $this->setPermissions($client, $subscription);
        
        if ($client_announcements != "") {
            $this->db->insert("clients_announcements", Array( "clients_id" => $client, "symbol" => $client_announcements, "notification_emails" => $client_notification));
        }
        
        return true;
    }

    /**
     *
     * @param type $client
     * @return type 
     */
    public function getPermissions($client) {
        return $this->db->select()->from("clients_features")->where("clients_id", $client)->get()->current();
    }

    /**
     *
     * @param type $permissions
     * @return string 
     */
    public function getLevel($permissions) {
        if (!empty($permissions)) {
        if ($permissions->has_announcements == 1) {
            return "gold";
        } else if ($permissions->has_announcements == 0 && $permissions->has_graph == 1) {
            return "silver";
        } else if ($permissions->has_announcements == 0 && $permissions->has_graph == 0) {
            return "bronze";
        }
        } else {
            return "";
        }
    }

    /**
     *
     * @param type $client
     * @param type $type 
     */
    public function setPermissions($client, $type) {
        $array = Array(
            "has_graph" => 0,
            "has_announcements" => 0,
            "has_xml" => 0,
            "has_secure_xml" => 0,
            "has_commodities" => 0,
            "has_currency" => 0,
            "has_share" => 0
        );

        if ($type == "bronze") {
            $array["has_share"] = 1;
            $array["has_commodities"] = 1;
        } else if ($type == "silver") {
            $array["has_share"] = 1;
            $array["has_commodities"] = 1;
            $array["has_graph"] = 1;
        } else if ($type == "gold") {
            $array["has_share"] = 1;
            $array["has_commodities"] = 1;
            $array["has_graph"] = 1;
            $array["has_announcements"] = 1;
        }

        $array["clients_id"] = $client;

        $this->db->delete("clients_features", Array("clients_id" => $client));
        $this->db->insert("clients_features", $array);
    }

    /**
     *
     * @param type $client
     * @param type $stocks 
     */
    public function addClientStocks($client, $stocks) {
        foreach ($stocks as $stock) {
            list($type, $market, $stock_code) = explode("|", $stock);

            if ($type == "stock-price") {
                $existing = $this->checkIfStockExists($stock_code, $market);

                if (!$existing) {
                    $existing = $this->addNewStock($stock_code, $market);
                }

                $client_stocks = Array(
                    "clients_id" => $client,
                    "stocks_id" => $existing
                );

                $this->db->insert("clients_stocks", $client_stocks);
            } else if ($type == "commodity") {

                $commodity_code = $this->getCommodityByCode($stock_code);
                $client_commodities = Array(
                    "clients_id" => $client,
                    "commodities_indicies_id" => $commodity_code
                );

                $this->db->insert("clients_commodities", $client_commodities);
            } else if ($type == "currency") {
                list($currency_from,$currency_to) = explode("/",$stock_code);
                $clients_currency = Array(
                    "clients_id" => $client,
                    "currency_from" => $currency_from,
                    "currency_to" => $currency_to
                );

                $this->db->insert("clients_currency", $clients_currency);
            }
        }
    }

    public function getClients() {
        return $this->db->select()->from("clients")->get();
    }

    public function getClientById($id) {
        $data = $this->db->select()->from("clients")->where("id", $id)->get()->current();
        
        $announcement = $this->db->select()->from("clients_announcements")->where("clients_id",$id)->get()->current();
        
        if ($announcement) {
            $data->announcement = $announcement->symbol;
            $data->notification = $announcement->notification_emails;
        } else {
            $data->announcement = "";
            $data->notification = "";
        }
        return $data;
    }

    public function getCommodityByCode($code) {
        $result = $this->db->select()->from("commodities_indicies")->where("symbol", $code)->get()->current();

        return $result->id;
    }


    public function checkIfStockExists($stock_code, $market) {
        $result = $this->db->select()->from("stocks")->where("symbol", $stock_code)->where("stock_markets_id", $market)->get()->current();

        if ($result) {
            return $result->id;
        } else {
            return false;
        }
    }

    public function getEntriesByClient($client) {
        $stocks = $this->db->select()->from("clients_stocks")->where("clients_id", $client)->get();
        $commodities = $this->db->select()->from("clients_commodities")->where("clients_id", $client)->get();

        $result = Array();

        foreach ($stocks as $stock_client) {
            $stock = $this->getStockById($stock_client->stocks_id);
            $sub = Array(
                "type" => "Stock Price",
                "market" => $this->getMarketById($stock->stock_markets_id),
                "code" => $stock->symbol,
                "id" => $stock->id
            );

            $result[] = $sub;
        }

        foreach ($commodities as $commodity_client) {
            $commodity = $this->getCommodityById($commodity_client->commodities_indicies_id);
            $sub = Array(
                "type" => "Commodity",
                "market" => "",
                "code" => $commodity->symbol,
                "id" => $commodity->id
            );

            $result[] = $sub;
        }

        return $result;
    }

    public function getStockById($id) {
        return $this->db->select()->from("stocks")->where("id", $id)->get()->current();
    }

    public function getCommodityById($id) {
        return $this->db->select()->from("commodities_indicies")->where("id", $id)->get()->current();
    }
    
    public function getCommoditySymbolBySource($id) {
        $data = $this->db->select()->from("commodities_indicies")->where("id", $id)->get()->current();
        $symbol = $this->db->select()->from("commodities_indicies_source_symbols")->where("commodities_indicies_id",$id)->get()->current();
        $source = $this->db->select()->from("sources")->where("id",$symbol->sources_id)->get()->current();
        
        return Array(
            "symbol" => $symbol->symbol,
            "source" => $source->id
        );
    }

    public function getMarketById($id) {
        return $this->db->select()->from("stocks_markets")->where("id", $id)->get()->current();
    }

    public function addNewStock($stock_code, $market) {
        $insert = Array(
            "symbol" => $stock_code,
            "name" => $stock_code,
            "stock_markets_id" => $market
        );

        $result = $this->db->insert("stocks", $insert);
        return $result->insert_id();
    }

    public function generateLicense($name, $domain) {
        return md5($name . $domain . rand(0, 9999) . strtotime("now"));
    }

    public function getSources() {
        $result = $this->db->select()->from("sources")->get();
        $return = Array();
        
        foreach ($result as $item) {
            $market = $this->getMarketById($item->stock_markets_id);
            $market_name = $market->name;
            
            $item->market = $market_name;
            $return[] = $item;
        }
        
        return $return;
    }

    public function getCommodities() {
        return $this->db->select()->from("commodities_indicies")->orderby("name")->get();
    }

    public function getMarkets() {
        return $this->db->select()->from("stocks_markets")->get();
    }

    public function deleteStocksAndCommoditiesByClient($id) {
        $this->db->delete("clients_stocks", Array("clients_id" => $id));
        $this->db->delete("clients_commodities", Array("clients_id" => $id));
        $this->db->delete("clients_currency", Array("clients_id" => $id));
    }
    
    public function addCommodity() {
        $name = addslashes($_POST["commodity-name"]);
        $code = addslashes($_POST["commodity-code"]);
        $symbol = addslashes($_POST["commodity-symbol"]);
        
        if (isset($_POST["commodity-future"])) {
            $future = 1;
        } else {
            $future = 0;
        }
        
        if (isset($_POST["commodity-history"])) {
            $history = 1;
        } else {
            $history = 0;
        }
        
        $sources = addslashes($_POST["sources"]);
        
        
        $insert = Array(
            "symbol" => $code,
            "name" => $name,
            "has_history" => $history,
            "is_future" => $future,
        );
        
        if (!$result = $this->db->insert("commodities_indicies", $insert)) {
            return false;
        }
        
        $id = $result->insert_id();
        
        $sources_insert = Array(
            "symbol" => $symbol,
            "commodities_indicies_id" => $id,
            "sources_id" => $sources
        );
        
        if ($this->db->insert("commodities_indicies_source_symbols", $sources_insert)) {
            return true;
        } else {
            return false;
        }
        
    }
    
    public function updateCommodity($editid) {
        $name = addslashes($_POST["commodity-name"]);
        $code = addslashes($_POST["commodity-code"]);
        $symbol = addslashes($_POST["commodity-symbol"]);
        
        if (isset($_POST["commodity-future"])) {
            $future = 1;
        } else {
            $future = 0;
        }
        
        if (isset($_POST["commodity-history"])) {
            $history = 1;
        } else {
            $history = 0;
        }
        
        $sources = addslashes($_POST["sources"]);
        
        
        $update = Array(
            "symbol" => $code,
            "name" => $name,
            "has_history" => $history,
            "is_future" => $future,
        );
        
        if (!$result = $this->db->update("commodities_indicies", $update, Array("id" => $editid))) {
            return false;
        }
        
        $id = $editid;
        
        $sources_insert = Array(
            "symbol" => $symbol,
            "sources_id" => $sources
        );
        
        if ($this->db->update("commodities_indicies_source_symbols", $sources_insert, Array("commodities_indicies_id" => $id))) {
            return true;
        } else {
            return false;
        }
        
    }
    
    public function deleteCommodity($id) {
        $this->db->query("delete from clients_commodities where commodities_indicies_id = ".$id);
        $this->db->query("delete from commodities_indicies_source_symbols where commodities_indicies_id = ".$id);
        $this->db->query("delete from commodities_indicies where id = ".$id);        
    }

    public function updateClient() {
        $client_id = $_POST["client-id"];
        $name = $_POST["client-name"];
        $domain = $_POST["client-domain"];
        $email = $_POST["client-email"];
        $subscription = $_POST["subscription-type"];

        if (isset($_POST["stock-data"])) {
            $stocks = $_POST["stock-data"];
        }

        $type = $_POST["data-type"];
        $market = $_POST["data-market"];

        $stock_code = $_POST["stock-code"];
        $commodity_code = $_POST["commodity-code"];
        $client_announcements = $_POST["client-announcements"];
        $client_notification = $_POST["client-notification"];

        $insert = Array(
            "name" => $name,
            "domain" => $domain,
            "email" => $email,
            "timezone" => "GMT+8"
        );

        $result = $this->db->update("clients", $insert, Array("id" => $client_id));
        $client = $client_id;

        $this->deleteStocksAndCommoditiesByClient($client_id);

        if ($subscription == "bronze") {
            if ($type == "stock-price") {
                $existing = $this->checkIfStockExists($stock_code, $market);

                if (!$existing) {
                    $existing = $this->addNewStock($stock_code, $market);
                }

                $client_stocks = Array(
                    "clients_id" => $client,
                    "stocks_id" => $existing
                );

                $this->db->insert("clients_stocks", $client_stocks);
            } else if ($type == "commodity") {
                $client_commodities = Array(
                    "clients_id" => $client,
                    "commodities_indicies_id" => $commodity_code
                );

                $this->db->insert("clients_commodities", $client_commodities);
            }
        } else if ($subscription == "silver") {
            $this->addClientStocks($client, $stocks);
        } else if ($subscription == "gold") {
            $this->addClientStocks($client, $stocks);
        }

        $this->setPermissions($client, $subscription);
        
        $this->db->update("clients_announcements", Array("symbol" => $client_announcements, "notification_emails" => $client_notification),Array("clients_id" => $client));
        return true;
    }

}

?>
