<?php
$user_margin = 0;
if ($tip_margin >== 0 && $fixture->isMarginGame == 1) {
    $user_margin = str_replace('-', '', ($set_margin));
} else if ($tip_margin == 0 && $fixture->isMarginGame == 1 && $tips->isAuto == 1) {
    $user_margin = $fixture->margin;
} else if ($tip_margin == 0 && $fixture->isMarginGame == 1 && $tips->isAuto == 0) {
    $user_margin = $fixture->margin;
} else if ($tip_margin == $fixture->margin && $fixture->isMarginGame == 1 && $tips->isAuto == 0) {
    $user_margin = 0;
}
