#<?php

$name  = "Ada Lovelace";
$role  = "Engineer";
$langs = array("Ruby", "PHP", "Assembly");

printf("Hello %s" . PHP_EOL, $name);
printf("Role: %s" . PHP_EOL, $role);

function greet($who) {
  return implode(" ", ["Sup,", $who]);
}

echo greet($name) . PHP_EOL;

$x = null;
echo isset($x) ? "set" : "not";
echo PHP_EOL;

