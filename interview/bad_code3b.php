<?php
    public function getLadder($competition, $widget = false) {
        $cache = Cache::instance();
        
        $cache_ladder = $cache->get("ladder-obj-by-competition-" . $competition);
        
        if (!$cache_ladder) {
        $all = 1;
        $competitionId = $competition;
        $count = 1;
        $arr = Array();
        $ladderArr = Array();
        $countNum = 1;


        $result = $this->db->select()->from("tippingComp")->where("id", $competitionId)->get()->current();
        $season = $result->season_id;

        $get = mysql_query("select * from usersTippingComp where tippingComp_id = $competitionId");
        while ($result = mysql_fetch_array($get)) {
            $users_id = $result["users_id"];

            $subArr = Array();

            $check = mysql_query("select * from users where id = $users_id and verified > 0");
            $res = mysql_fetch_array($check);
            if ($res["email"] != "") {
                $endDate = tipping::currentDate();
                $rounds = mysql_query("select * from rounds where endDate < '$endDate' and season_id = $season");

                $subArr["id"] = $res["id"];
                $subArr["name"] = $res["screenName"];
                $subArr["email"] = $res["email"];
                
                $ladder_total = 0;
                $ladder_margin = 0;
                $total_margin = 0;
                $countNum++;

                while ($result = mysql_fetch_array($rounds)) {
                    $user_total = 0;
                    $user_margin = 0;

                    $round_id = $result["id"];

                    $query = "select * from roundsApproved where roundid = $round_id and tippingCompId = " . $competitionId;

                    $check = mysql_query($query);
                    $result_check = mysql_num_rows($check);

                    if ($result_check > 0) {

                        $fixtures = mysql_query("select * from fixtures where rounds_id = " . $result["id"] . " order by id");
                        while ($fixtures_result = mysql_fetch_array($fixtures)) {

                            $fixture_id = $fixtures_result["id"];
                            $winner = $fixtures_result["winner"];

                            if ($winner != 0) {
                                $query = "select * from tips where fixtures_id = $fixture_id and tippingComp_id = $competitionId and users_id = $users_id";
                                $get_tips = mysql_query($query);

                                if (mysql_num_rows($get_tips) > 0) {
                                    $res_tips = mysql_fetch_array($get_tips);
                                    $tip_team = $res_tips["teams_id"];
                                    $tip_margin = $res_tips["margin"];

                                    if ($tip_team == $winner) {
                                        $user_total = $user_total + 1;
                                        $set_margin = $tip_margin - $fixtures_result["margin"];
                                    } else {
                                        $set_margin = $fixtures_result["margin"] + $tip_margin;
                                    }


                                    $user_margin = 0;
                                    if ($tip_margin > 0 && $fixtures_result["isMarginGame"] == 1) {
                                        $user_margin = str_replace('-', '', ($set_margin));
                                    } else if ($tip_margin == 0 && $fixtures_result["isMarginGame"] == 1 && $res_tips["isAuto"] == 1) {
                                        $user_margin = $fixtures_result["margin"];
                                    } else if ($tip_margin == 0 && $fixtures_result["isMarginGame"] == 1 && $res_tips["isAuto"] == 0) {
                                        $user_margin = $fixtures_result["margin"];
                                    } else if ($tip_margin == $fixtures_result["margin"] && $fixtures_result["isMarginGame"] == 1 && $res_tips["isAuto"] == "") {
                                        $user_margin = 0;
                                    }
                                    $total_margin = $total_margin + $user_margin;
                                }
                            } else {
                                $user_total = $user_total + 1;
                            }
                        }

                        if ($all == 1) {
                            $user_margin = $total_margin;
                        }

                        $ladder_total = $ladder_total + $user_total;
                        $ladder_margin = $user_margin;
                    }
                }

                $subArr["tips"] = $ladder_total;
                $subArr["margin"] = $ladder_margin;
            }

            if (!empty($subArr)) {
                $ladderArr[] = $subArr;
            }
        }

        $id = array();
        $tips = array();
        $margin = array();
        foreach ($ladderArr as $key => $row) {
            $id[$key] = $row["id"];
            $tips[$key] = $row["tips"];
            $margin[$key] = $row["margin"];
        }

        array_multisort($tips, SORT_DESC, $margin, SORT_ASC, $id, SORT_ASC, $ladderArr);

        $ladderNew = Array();
        $start = 0;
        $limit = 6000;

        if ($widget) {
            $limit = 10;
        }

        $current_user = login::currentId();

        $found_me = false;
        foreach ($ladderArr as $ladderLine) {
            if ($start < $limit) {
                $ladderObj = new stdClass;
                $ladderObj->users_id = $ladderLine["id"];

                $ladderObj->correctTips = $ladderLine["tips"];
                $ladderObj->currentMargin = $ladderLine["margin"];
                $ladderObj->screenName = $ladderLine["name"];
                $ladderObj->email = $ladderLine["email"];

                $ladderNew[] = $ladderObj;
                $start++;
            }
        }

        $cache->set("ladder-obj-by-competition-" . $competition, $ladderNew);
        return $ladderNew;
        } else {
            return $cache_ladder;   
        }
    }
