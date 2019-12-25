require 'optparse'

options = {
  exts: %w[html]
}
opt = OptionParser.new
opt.on('-e[=VAL]', '--ext[=VAL]', Array, "default: #{options[:exts].join(',')}") do |v|
  options[:exts] = v
end
opt.parse!(ARGV)
targets = ARGV

targets.each do |target|
  Dir[*options[:exts].map { |ext| "#{target}/**/*.#{ext}" }].each do |file_path|
    b = ""
    File.open(file_path).each_line do |line|
      res = /<(".*?"|'.*?'|[^'"])*?>/.match(line)
      unless res
        b << line
        next
      end

      path = /(src|SRC|href|HREF)=("[^"]*"|'[^']*')/.match(res[0])
      unless path
        b << line
        next
      end

      relative_path = path[2][1..-2].strip

      if relative_path =~ /^[^(javascript:)(mailto:)(tel:)(http)\/#(<\?=)(<%=)]/ ||
         relative_path == ''
        b << line
        next
      end

      expand_path = File.expand_path(relative_path,
                                     file_path.split('/')[0..-2].join('/'))
                        .sub(/#{Dir.pwd}/, '')
      line = line.sub(/#{path[1]}=("|')#{relative_path}("|')/,
                      "#{path[1]}=\"#{expand_path}\"")
      b << line
    end
    File.write(file_path, b)
  end
end
