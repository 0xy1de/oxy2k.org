<?php
// counter.js.php — plain PHP hit counter that outputs JS
header('Content-Type: application/javascript; charset=UTF-8');

$file = __DIR__ . '/counter.txt';
$tries = 0;

// Ensure file exists
if (!file_exists($file)) {
  file_put_contents($file, "0\n");
}

$fp = fopen($file, 'c+');
if ($fp) {
  // simple retry loop for lock contention
  while (!flock($fp, LOCK_EX) && $tries++ < 10) { usleep(20000); }
  $count = (int)trim(stream_get_contents($fp));
  $count++;
  ftruncate($fp, 0);
  rewind($fp);
  fwrite($fp, $count . "\n");
  fflush($fp);
  flock($fp, LOCK_UN);
  fclose($fp);

  // Output JS that writes the number into your HTML
  echo "document.write('". $count ."');";
} else {
  // Fallback: don't break the page
  echo "document.write('[offline]');";
}