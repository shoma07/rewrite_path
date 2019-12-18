require 'optparse'

options = {
  tag: %w[img link script],
  exts: %w[html]
}
opt = OptionParser.new
opt.on('-t[=VAL]', '--tag[=VAL]', Array, "default: #{options[:tag].join(',')}") do |v|
  options[:tag] = v
end
opt.on('-e[=VAL]', '--ext[=VAL]', Array, "default: #{options[:exts].join(',')}") do |v|
  options[:exts] = v
end
opt.parse!(ARGV)
targets = ARGV

targets.each do |dir|
  Dir[*options[:exts].map { |ext| "#{dir}/**/*.#{ext}" }].each do |path|
    b = ""
    f = File.open(path)
    f.each_line do |line|
      if options[:tag].include? 'link'
        if line =~ /<link\s[^(href=)]?href=("|')[^"']("|')/
          relative_path = line.slice(/href=("|')[^"']+("|')/)[6..-2]
          if relative_path !~ /^\// && relative_path !~ /^http/
            expand_path = File.expand_path(relative_path,
                                           path.split("/")[0..-2].join("/"))
                              .sub(/#{Dir.pwd}\/#{dir}/, '')
            line = line.sub(relative_path, expand_path)
          end
        end
      end
      if options[:tag].include? 'script'
        if line =~ /<script\s[^(src=)]?src=("|')[^"']+("|')/
          relative_path = line.slice(/src=("|')[^"']+("|')/)[5..-2]
          if relative_path !~ /^\// && relative_path !~ /^http/
            expand_path = File.expand_path(relative_path,
                                           path.split("/")[0..-2].join("/"))
                              .sub(/#{Dir.pwd}\/#{dir}/, '')
            line = line.sub(relative_path, expand_path)
          end
        end
      end
      if options[:tag].include? 'img'
        if line =~ /<img\s[^(src=)]?src=("|')[^"']+("|')/
          relative_path = line.slice(/src=("|')[^"']+("|')/)[5..-2]
          if relative_path !~ /^\// && relative_path !~ /^http/
            expand_path = File.expand_path(relative_path,
                                           path.split("/")[0..-2].join("/"))
                              .sub(/#{Dir.pwd}\/#{dir}/, '')
            line = line.sub(relative_path, expand_path)
          end
        end
      end
      b << line
    end
    File.write(path, b)
  end
end
