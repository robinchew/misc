<h1>Clients > Update Client</h1>
<script>
    function loadType(val) {
        $(".price-type").hide();
        $("#type-" + val).show();
    }    
    

    
    function validateClient() {
            var clientName = $("#client-name").val();
            var clientDomain = $("#client-domain").val();
            var clientEmail = $("#client-email").val();
            
            
            var totalTable = 0;
            
            $("table#stock-list tbody tr").each(function(key,data) {
                totalTable = totalTable + 1;
            });
            
            
            var subscriptionType = $("#subscription-type").val();
            var dataType = $("#data-type").val();
            var stockCode = $("#stock-code").val();
            
            $(".field-error").remove();
            var valid = true;
            
            if (clientName == '') {
                applyError('client-name','Client name cannot be empty');
                valid = false;
            }
            
            if (clientDomain == '') {
                applyError('client-domain','Client domain cannot be empty');
                valid = false;
            }
            

            
            if (subscriptionType == "bronze") {
                if (dataType == "stock-price") {
                    if (stockCode == "") {
                        applyError('stock-code','Stock code cannot be empty');
                        valid = false;
                    }
                }
            } else {
                if (totalTable == 0) {
                    applyError('table-error','You have no stock codes');
                    valid = false;
                }
            }
            
            if (valid == false) {
                return false
            } else {
                return true;
            }
    }
    
    function applyError(id,msg) {
        $("#" + id).after('<span class="form-error">' + msg + '</span>');
    }
</script>

<form action="<?php echo url::base(); ?>admin/clients_edit" onsubmit="return validateClient()" method="post">
    <input type="hidden" name="update-client" />
    <input type="hidden" name="client-id" value="<?php echo $client->id; ?>" />
    
    <h2>Client Details</h2>
    <label>Client Name</label>
    <input type="text" name="client-name" id="client-name" size="20" value="<?php echo $client->name; ?>" /><br />

    <label>Domain</label>
    <input type="text" name="client-domain" id="client-domain" size="20" value="<?php echo $client->domain; ?>" /> <span style="float: left; display: block; padding: 7px;">E.g: yourdomain.com.au, seperate multiple domains using commas</span><br />

    <input type="hidden" name="client-email" id="client-email" size="20" value="<?php echo $client->email; ?>" /><br />

    <script>
        function setPlan() {
            var plan = $("#subscription-type").val();
            
            if (plan != 'gold') {
                $("#announcements").hide();
            } else {
                $("#announcements").show();
            }
            

        }
        
    </script>
    
    <label>Subscription Type</label>
    <select name="subscription-type" id="subscription-type" size="1" onchange="setPlan()">
        <option value="bronze" <?php if ($permissions == "bronze") { ?>selected="selected"<?php } ?>>Bronze</option>
        <option value="silver" <?php if ($permissions == "silver") { ?>selected="selected"<?php } ?>>Silver</option>
        <option value="gold" <?php if ($permissions == "gold") { ?>selected="selected"<?php } ?>>Gold</option>
    </select><br />

    <hr />
    <h2>Stocks and Commodities</h2>
    <label>Type</label>
    <select id="data-type" name="data-type" size="1" onchange="loadType(this.value)">
        <option value=""></option>
        <option value="stock-price">Stock Price</option>
        <option value="commodity">Commodity/Index</option>
        <option value="currency">Currency</option>
    </select><br />

    <div id="type-stock-price" class="hidden price-type">
        <label>Market</label>
        <select id="data-market" name="data-market" size="1">
            <?php foreach ($markets as $market) { ?>
                <option value="<?php echo $market->id; ?>|<?php echo $market->name; ?>"><?php echo $market->name; ?></option>
            <?php } ?>
        </select><br />
        
        

        <label>Stock Code</label>
        <input type="text" id="stock-code" name="stock-code" size="20" /><br />

        <label></label><input type="button" id="add-stock" value="Add Stock" onclick="addStock()" />

        <script>
            function addStock() {
                var level = "<?php echo $permissions; ?>";
                var count = $("#stock-list tbody tr").length;
                
                if (count == 1) {
                    if (level == "bronze") {
                        alert('This client is only at bronze level, and cannot add more stocks');
                        return false;
                    }
                }
                
                var data_type = $("#data-type").val();
                var data_type_details;
                
                if (data_type == "stock-price") {
                    data_type_details = "Stock Price";
                } else if (data_type == "commodity") {
                    data_type_details = "Commodity";
                } else if (data_type == "currency") {
                    data_type_details = "Currency";
                }
                
                var data_market = $("#data-market").val();
                var data_market_details = data_market.split("|");
                var stock_code = $("#stock-code").val();
                
                var newDate = new Date;
                var id = newDate.getTime();
                 
                var html = "<tr id=\"" + id + "\"><td>" + data_type_details + "</td><td>" + data_market_details[1] + "</td><td>" + stock_code + "";
                html += "<input type=\"hidden\" name=\"stock-data[]\" value=\"" + data_type + "|" + data_market_details[0] + "|" + stock_code + "\" /></td><td><a href=\"#\" onclick=\"$('#" + id + "').remove()\">Remove</a></tr>";
                
                $("#stock-list tbody").append(html);
            }

        </script>
        <br /><br />
    </div>

    <div id="type-commodity" class="hidden price-type">
        <label>Commodity Code</label>
        <select name="commodity-code" id="commodity-code" size="1">
            <?php foreach ($commodities as $commodity) { ?>
                <option value="<?php echo $commodity->symbol; ?>"><?php echo $commodity->name; ?></option>
            <?php } ?>
        </select><br />
        

        <label></label><input type="button" id="commodity-button" value="Add Commodity" onclick="addCommodity()" />
    </div>
    
    <script>
        
        function doesCommodityExist(commodity) {
            var found = false;
            $("table#stock-list tbody tr").each(function(key,data) {
               var item = $(key).find("<td>");
               
               var td = item[2];
               
               if (td == commodity) {
                   found = true;
               }
            });
            
            return found;
        }
        
        function addCommodity() {
            var data_type = $("#data-type").val();
            var stock_code = $("#commodity-code").val();
            
            if (!doesCommodityExist(stock_code)){ 
                var newDate = new Date;
                var id = newDate.getTime();

                var html = "<tr id=\"" + id + "\"><td>Commodity</td><td></td><td>" + stock_code + "";
                html += "<input type=\"hidden\" name=\"stock-data[]\" value=\"" + data_type + "||" +  stock_code + "\" /></td><td><a href=\"#\" onclick=\"$('#" + id + "').remove()\">Remove</a></tr>";

                $("#stock-list tbody").append(html);
            }
        }
        
        
        function addCurrency() {
            var data_type = $("#data-type").val();
            var cur_from = $("#currency-from").val();
            var cur_to = $("#currency-to").val();
            
                var newDate = new Date;
                var id = newDate.getTime();

                var html = "<tr id=\"" + id + "\"><td>" + data_type + "</td><td></td><td>" + cur_from + "/" + cur_to + "";
                html += "<input type=\"hidden\" name=\"stock-data[]\" value=\"" + data_type + "||" + cur_from + "/" + cur_to + "\" /></td><td><a href=\"#\" onclick=\"$('#" + id + "').remove()\">Remove</a></tr>";

                $("#stock-list tbody").append(html);
            
        }
    </script>
    
    <div id="type-currency" class="hidden price-type">
        <?php
            $currencies = file_get_contents("data/currencies.json");
            $data = json_decode($currencies);
            
            
            
        ?>
        <label>Currency</label>
        <select id="currency-from" size="1">
            <?php foreach ($data->rates as $key => $val) { ?>
                <option value="<?php echo $key; ?>"><?php echo $key; ?></option>
            <?php } ?>
        </select>
        <span style="float: left;">to</span>
        <select id="currency-to" size="1">
            <?php foreach ($data->rates as $key => $val) { ?>
                <option value="<?php echo $key; ?>"><?php echo $key; ?></option>
            <?php } ?>
        </select>
        <br />
        <div class="clear"></div>
        <label></label><input type="button" value="Add Currency" onclick="addCurrency()" />
    </div>
    <table id="stock-list" width="100%" class="grid stock-list">
        <thead>
            <tr>
                <th>Type</th>
                <th>Market</th>
                <th>Code</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($entries as $entry) { ?>
            <?php $uid = uniqid(); ?>
                <tr id="<?php echo $uid; ?>">
                    <td><?php echo $entry["type"]; ?></td>
                    <?php
                        if ($entry["type"] == "Stock Price") {
                            $type = "stock-price";
                        } else if ($entry["type"] == "Commodity") {
                            $type = "commodity";
                        }
                    ?>
                    <?php if ($entry["market"] == "") { ?>
                        <?php $market = ""; ?>
                        <td></td>
                    <?php } else { ?>
                        <td><?php echo $entry["market"]->name; ?></td>
                        <?php $market = $entry["market"]->id; ?>
                    <?php } ?>
                    <td><?php echo $entry["code"]; ?></td>
                    <td>
                        <a href="#" onclick="$('#<?php echo $uid; ?>').remove()">Remove</a>
                        <input type="hidden" name="stock-data[]" value="<?php echo $type; ?>|<?php echo $market; ?>|<?php echo $entry["code"]; ?>" />
                    </td>
                </tr>
            <?php } ?>
        </tbody>
    </table>
    <div id="table-error"></div>


    <hr />

    <div id="announcements" class="<?php if ($permissions != "gold") { ?>hidden<?php } ?>">
    <h2>ASX Announcements</h2>
    <label>ASX Stock Symbol</label>
    <input type="text" name="client-announcements" size="20" value="<?php echo $client->announcement; ?>" /><br />

    <label>Notification Email</label>
    <input type="text" name="client-notification" size="20" value="<?php echo $client->notification; ?>" /><br />
    </div>
    
    <label></label><input type="submit" value="Update Client" />
</form>

