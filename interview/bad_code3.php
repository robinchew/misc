<?php
    public function getResultsByRoundNumber($round, $season = 0, $competition = 0, $all = 0) {
        if ($season == 0) {
            $season = tipping::currentSeason();
        }

        if ($competition == 0) {
            $competition = tipping::currentCompetition();
        }

        ########################################
        # GET ROUND AND CHECK IF IT'S APPROVED #
        ########################################

        $get_round = $this->db->query("select * from rounds where name = 'Round " . $round . "' and season_id = $season")->current();
        $round_id = $get_round->id;
        $round_is_approved = $this->db->select()->from('roundsApproved')->where('roundid',$round_id)->where('tippingCompId',$competition)->get()->count();

        ##########################################
        # NO RESULTS                             #
        # if the round has not yet been approved #
        ##########################################

        if( ! $round_is_approved ){
            return array();
        }

        ##################################
        # GET CACHED OR GENERATE RESULTS #
        ##################################
        
        $name = "results_by_round_and_comp_".$round."_".$competition."_".$season;
        
        $cache = Cache::instance();
        
        $cached = $cache->get($name);
        if ( ! $cached) {

        $fixtures = $this->db->query("select * from fixtures where rounds_id = $round_id");

        $result_array = Array();
        $result = $this->db->query("select * from usersTippingComp where tippingComp_id = $competition");
        $is_winner = 0;

        $user_array = Array();
        foreach ($result as $user) {
            $user_id = $user->users_id;

            $check_exists = $this->db->select()->from("users")->where("id", $user_id)->where("verified >", 0)->get()->current();
            $total_margin = 0;

            if ($check_exists) {
                $tipid = 0;
                $user_total = 0;
                $user_margin = 0;
                
                $query = "select * from tips where tippingComp_id = $competition and users_id = $user_id and fixtures_id in (select id from fixtures where rounds_id = $round_id)";
                
                $tips_of_user = $this->db->query($query);

                foreach ($fixtures as $fixture) {
                    $fixture_id = $fixture->id;
                    $winner = $fixture->winner;

                    if ($winner != 0) {
                        $is_winner++;
                        $tips = false;
                        
                        foreach ($tips_of_user as $tips_item) {
                            if ($tips_item->fixtures_id == $fixture_id) {
                                $tips = $tips_item; 
                            }
                        }    
                        
                        if ($tips) {
                            $user_array[$user_id] = $tips->id;
                            $tip_team = $tips->teams_id;
                            $tip_margin = $tips->margin;

                            if ($tip_team == $winner) {
                                $user_total = $user_total + 1;
                                $set_margin = $tip_margin - $fixture->margin;
                            } else {
                                $set_margin = $fixture->margin + $tip_margin;
                            }


                            $user_margin = 0;
                            if ($tip_margin > 0 && $fixture->isMarginGame == 1) {
                                $user_margin = str_replace('-', '', ($set_margin));
                            } else if ($tip_margin == 0 && $fixture->isMarginGame == 1 && $tips->isAuto == 1) {
                                $user_margin = $fixture->margin;
                            } else if ($tip_margin == 0 && $fixture->isMarginGame == 1 && $tips->isAuto == 0) {
                                $user_margin = $fixture->margin;
                            } else if ($tip_margin == $fixture->margin && $fixture->isMarginGame == 1 && $tips->isAuto == 0) {
                                $user_margin = 0;
                            }
         
                            $total_margin = $total_margin + $user_margin;
                            
                        }
                    } else {
                        $user_total = $user_total + 1;
                    }
                }
            }

                            
            if ($all == 1) {
                $user_margin = $total_margin;
            }

            if ($is_winner > 0) {
                if ($user_id != 0) {
                    if (array_key_exists($user_id, $user_array)) {
                        $result_array[] = Array('tipid' => $user_array[$user_id], 'id' => $user_id, 'total' => $user_total, 'margin' => $total_margin);
                    }
                }
            }
        }

        if ($is_winner > 0) {

            $array = $this->multiSort($result_array, 'total', 'margin', 'id', 'tipid');

            $return_array = Array();
            foreach ($array as $array_item) {
                $user = $this->screenName($array_item['id']);
                if ($user != "") {
                    $return_array[] = Array('tipid' => $user_array[$array_item['id']], 'user' => $user, 'total' => $array_item['total'], 'margin' => $array_item['margin']);
                }
            }
            $total = Array();
            $margin = Array();
            $tipsid = Array();

            foreach ($return_array as $key => $row) {
                $tipsid[$key] = $row['tipid'];
                $total[$key] = $row['total'];
                $margin[$key] = $row['margin'];
            }


            array_multisort($total, SORT_DESC, $margin, SORT_ASC, $tipsid, SORT_ASC, $return_array);
        } else {

            $return_array = Array();
        }

            $cache->set($name,$return_array);
            
            return $return_array;
        } else {
            return $cached; 
        }
    }
?>
