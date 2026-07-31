Dir["test/controllers/*_test.rb"].each do |f|
  next if File.read(f).include?("post login_url")
  content = File.read(f)
  content.sub!(/(require "test_helper"\n\nclass)/, "require \"test_helper\"\n\n\\1")
  content.sub!(/class/, "class") # no-op, just reference
  insert = "  setup do\n    post login_url, params: { email: \"admin@ratf.test\", password: \"password\" }\n  end\n\n"
  content.sub!(/\nclass (\w+)/, "\nclass \\1\n#{insert}")
  File.write(f, content)
  puts "Fixed #{f}"
end
puts "Done"
