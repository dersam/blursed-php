#<?php

$name  = "Ada Lovelace";
$role  = "Engineer";
$langs = array("Ruby", "PHP", "Assembly");

printf("Hello %s".PHP_EOL, $name);
echo implode(" ", ["Role:", $role]);
printf(PHP_EOL);

function greet($who) {
  return implode(" ", ["Sup,", $who]);
}

echo greet("world");
echo PHP_EOL;

$x = null;
echo isset($x) ? "set" : "not";
echo PHP_EOL;

