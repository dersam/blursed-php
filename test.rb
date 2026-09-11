require "open3"
require "rbconfig"
require "tmpdir"

HARNESS = File.expand_path("php.rb", __dir__)

def verify_polyglot(label, directory)
  ruby_out, ruby_err, ruby_status = Open3.capture3(RbConfig.ruby, HARNESS, chdir: directory)
  php_out, php_err, php_status = Open3.capture3("php", "rb.php", chdir: directory)

  if ruby_status.success? && php_status.success? && ruby_out == php_out
    puts "PASS: #{label} (#{ruby_out.bytesize} bytes)"
    return
  end

  warn "FAIL: #{label}"
  warn "--- ruby php.rb ---"
  warn ruby_out
  warn ruby_err unless ruby_err.empty?
  warn "--- php rb.php ---"
  warn php_out
  warn php_err unless php_err.empty?
  exit 1
end

verify_polyglot("rb.php", __dir__)

Dir.mktmpdir do |directory|
  File.write(File.join(directory, "rb.php"), <<~'PHP')
    #<?php
    $noise = "unused";
    $flag = true;

    function greet($who) {
      return $who;
    }

    function identity($flag) {
      return $flag;
    }

    printf("%s".PHP_EOL, greet("world"));
    printf("%s".PHP_EOL, identity(false) ? "true" : "false");
  PHP

  verify_polyglot("function parameter detection", directory)
end
